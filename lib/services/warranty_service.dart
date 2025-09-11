// lib/services/warranty_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/warranty.dart';

class WarrantyService {
  WarrantyService._();
  static final instance = WarrantyService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// In-memory cache for "Saved Warranties" tab
  final List<Warranty> _cache = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  List<Warranty> get warranties => List.unmodifiable(_cache);

  /// Begin listening to this user's warranties (soft-deleted excluded)
  Future<void> startListening({String? userId}) async {
    await _sub?.cancel();
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) {
      _cache.clear();
      return;
    }

    // NOTE: Requires composite index: where userId == uid, orderBy timestamp desc, orderBy __name__
    _sub = _db
        .collection('warranties')
        .where('userId', isEqualTo: uid)
        .where('deleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _cache
        ..clear()
        ..addAll(snapshot.docs.map((d) => Warranty.fromMap(d.data())));
    });
  }

  Future<void> stopListening() async {
    await _sub?.cancel();
    _sub = null;
  }

  /// Soft delete
  Future<void> deleteWarranty(String id) async {
    await _db.collection('warranties').doc(id).set({'deleted': true}, SetOptions(merge: true));
  }

  /// Submit a new warranty. We also set the `pdfStoragePath` which your Cloud Function
  /// will use to write "CREATED_WARRANTY_PDF/{id}.pdf" and then update the doc with `pdfUrl`.
  Future<void> submitWarranty(Warranty w) async {
    final data = w.copyWith(
      pdfStoragePath: 'CREATED_WARRANTY_PDF/${w.id}.pdf',
    ).toMap();

    await _db.collection('warranties').doc(w.id).set(data);
    // If you have a callable function to force PDF creation, call it here (optional).
    // Otherwise your existing onCreate Firestore trigger will pick this up.
  }

  /// Generate a new unique ID (client-side)
  String newId() => _db.collection('warranties').doc().id;
}
