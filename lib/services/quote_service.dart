// lib/services/quote_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/quote.dart';

class QuoteService {
  QuoteService._();
  static final instance = QuoteService._();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // In-memory cache
  final List<Quote> _cache = [];
  bool _loaded = false;

  /// Refresh saved quotes for a user (filters by userId if provided).
  /// We filter out soft-deleted client-side to avoid extra composite indexes.
  Future<void> refresh({String? userUid}) async {
    Query query = _db.collection('quote_requests');

    if (userUid != null) {
      query = query.where('userId', isEqualTo: userUid);
    }

    query = query.orderBy('timestamp', descending: true).limit(100);
    final snap = await query.get();

    // Cast each doc.data() to Map<String, dynamic>
    final all = snap.docs.map((d) {
      final m = d.data() as Map<String, dynamic>;
      return _fromMap(m);
    }).toList();

    final visible = all.where((q) => q.deleted == false).toList();

    _cache
      ..clear()
      ..addAll(visible);
    _loaded = true;
  }

  /// Backwards-compatible sync getter used by your UI.
  List<Quote> getQuotes() {
    // Return only non-deleted in case something slipped into cache
    return List.unmodifiable(_cache.where((q) => q.deleted == false));
  }

  /// Backwards-compatible sync getter by ID from cache.
  Quote? getById(String id) {
    for (final q in _cache) {
      if (q.id == id) return q;
    }
    return null;
  }

  /// Submit a quote and optional image.
  /// Writes Storage: QUOTE_DATA/{id}/plan.jpg  (if imageFile != null)
  /// Writes Firestore: quote_requests/{id}
  ///
  /// NOTE: matches your call site:
  ///   submitQuote(quote, imageFile: imageFile, userId: uid)
  Future<void> submitQuote(Quote quote, {File? imageFile, String? userId}) async {
    String? storagePath;

    if (imageFile != null) {
      storagePath = 'QUOTE_DATA/${quote.id}/plan.jpg';
      final ref = _storage.ref().child(storagePath);
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
    }

    final data = _toMap(
      quote,
      storagePath: storagePath,
      userId: userId,
      deleted: false,
    );

    await _db.collection('quote_requests').doc(quote.id).set(data);

    // Update local cache optimistically
    final saved = _fromMap(data);
    final idx = _cache.indexWhere((q) => q.id == saved.id);
    if (idx >= 0) {
      _cache[idx] = saved;
    } else {
      _cache.insert(0, saved);
    }
  }

  /// Soft delete a quote (sets deleted=true).
  Future<void> deleteQuote(String id) async {
    await _db.collection('quote_requests').doc(id).update({'deleted': true});

    final idx = _cache.indexWhere((q) => q.id == id);
    if (idx >= 0) {
      // Remove from cache immediately so UI updates
      _cache.removeAt(idx);
    }
  }

  /// Restore a soft-deleted quote (sets deleted=false).
  /// Note: If it's not in cache anymore, we fetch it and re-add if needed.
  Future<void> restoreQuote(String id) async {
    await _db.collection('quote_requests').doc(id).update({'deleted': false});

    final doc = await _db.collection('quote_requests').doc(id).get();
    if (doc.exists) {
      final m = doc.data() as Map<String, dynamic>;
      final q = _fromMap(m);
      final idx = _cache.indexWhere((x) => x.id == id);
      if (q.deleted == false) {
        if (idx >= 0) {
          _cache[idx] = q;
        } else {
          _cache.insert(0, q);
        }
      }
    }
  }

  // ---------- mapping helpers ----------

  Map<String, dynamic> _toMap(
    Quote q, {
    String? storagePath,
    String? userId,
    bool? deleted,
  }) {
    return {
      'id': q.id,
      'categoryTitle': q.categoryTitle,
      'distributor': q.distributor,
      'name': q.name,
      'company': q.company,
      'email': q.email,
      'telephone': q.telephone,
      'postcode': q.postcode,
      'projectName': q.projectName,
      'projectStage': q.projectStage,
      'itemsNeededDate': q.itemsNeededDate,
      'additionalInfo': q.additionalInfo,
      // Cloud Function expects a Storage path (not a public URL)
      'imageUrl': storagePath ?? q.imageUrl,
      'timestamp': q.timestamp,
      'userId': userId ?? q.userId,
      'deleted': deleted ?? q.deleted, // ensure it's persisted
    };
  }

  Quote _fromMap(Map<String, dynamic> m) {
    return Quote(
      id: m['id'] ?? '',
      categoryTitle: m['categoryTitle'] ?? '',
      distributor: m['distributor'] ?? '',
      name: m['name'] ?? '',
      company: m['company'] ?? '',
      email: m['email'] ?? '',
      telephone: m['telephone'] ?? '',
      postcode: m['postcode'] ?? '',
      projectName: m['projectName'] ?? '',
      projectStage: m['projectStage'] ?? '',
      itemsNeededDate: m['itemsNeededDate'] ?? '',
      additionalInfo: m['additionalInfo'] ?? '',
      imageUrl: m['imageUrl'],
      timestamp: (m['timestamp'] is int)
          ? m['timestamp']
          : (m['timestamp'] is Timestamp)
              ? (m['timestamp'] as Timestamp).millisecondsSinceEpoch
              : DateTime.now().millisecondsSinceEpoch,
      userId: m['userId'],
      deleted: (m['deleted'] == true),
    );
  }
}
