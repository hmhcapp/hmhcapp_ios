import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quote.dart';

class QuoteDetailScreen extends StatefulWidget {
  final String quoteId;
  const QuoteDetailScreen({super.key, required this.quoteId});

  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> {
  Quote? _quote;
  String? _imageDownloadUrl;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('quote_requests')
          .doc(widget.quoteId)
          .get();

      if (!doc.exists) {
        setState(() {
          _error = 'Quote not found';
          _loading = false;
        });
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      final quote = _fromMap(data);

      String? imageUrl;
      if (quote.imageUrl != null && (quote.imageUrl as String).isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.ref(quote.imageUrl);
          imageUrl = await ref.getDownloadURL();
        } catch (_) {
          imageUrl = null;
        }
      }

      if (!mounted) return;
      setState(() {
        _quote = quote;
        _imageDownloadUrl = imageUrl;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading quote: $e';
        _loading = false;
      });
    }
  }

  // Local mapping (same as service)
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
          : (m['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
    );
  }

  Color _catColor(String t) {
    if (t.contains('Underfloor')) return const Color(0xFFF8B637);
    if (t.contains('Frost')) return const Color(0xFF009ADC);
    if (t.contains('Mirror')) return const Color(0xFF8BC34A);
    if (t.contains('Other')) return const Color(0xFFE88A2B);
    return const Color(0xFF666666);
  }

  void _openFullScreen() {
    if (_imageDownloadUrl == null || _quote == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImageViewerPage(
          imageUrl: _imageDownloadUrl!,
          heroTag: 'quote_img_${_quote!.id}',
          title: 'Quote ${_quote!.id} Attachment',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Quote Details', style: GoogleFonts.raleway(color: Colors.white)),
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/diagonalpatternbg.jpg',
                fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.4),
                    const Color(0xFF333333).withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(color: Colors.red),
                ),
              ),
            )
          else if (_quote == null)
            Center(
              child: Text(
                'No quote data.',
                style: GoogleFonts.raleway(),
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header card
                  Card(
                    color: _catColor(_quote!.categoryTitle),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_quote!.categoryTitle,
                              style: GoogleFonts.raleway(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                          const SizedBox(height: 6),
                          Text('Ref: ${_quote!.id}',
                              style: GoogleFonts.raleway(
                                  color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Details
                  _DetailCard(
                    title: 'Your Details',
                    children: [
                      _row('Name', _quote!.name),
                      _row('Company', _quote!.company),
                      _row('Email', _quote!.email),
                      _row('Phone', _quote!.telephone),
                      _row('Postcode', _quote!.postcode),
                      _row('Distributor', _quote!.distributor),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Project Details
                  _DetailCard(
                    title: 'Project Details',
                    children: [
                      _row('Project Name', _quote!.projectName),
                      _row('Project Stage', _quote!.projectStage),
                      _row('Items Needed By', _quote!.itemsNeededDate),
                      _row(
                        'Submitted On',
                        DateTime.fromMillisecondsSinceEpoch(_quote!.timestamp)
                            .toLocal()
                            .toString()
                            .split(' ')
                            .first,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Additional Info
                  _DetailCard(
                    title: 'Additional Information',
                    children: [
                      if (_quote!.additionalInfo.trim().isEmpty)
                        Text('No additional information provided.',
                            style: GoogleFonts.raleway(color: Colors.grey))
                      else
                        Text(_quote!.additionalInfo,
                            style: GoogleFonts.raleway(fontSize: 16)),
                    ],
                  ),

                  // Submitted Plan Image + View button
                  if (_imageDownloadUrl != null) ...[
                    const SizedBox(height: 16),
                    _DetailCard(
                      title: 'Submitted Plan',
                      children: [
                        GestureDetector(
                          onTap: _openFullScreen,
                          child: Hero(
                            tag: 'quote_img_${_quote!.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _imageDownloadUrl!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _openFullScreen,
                            icon: const Icon(Icons.fullscreen),
                            label: Text('View attachment',
                                style: GoogleFonts.raleway()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 140,
              child: Text(label,
                  style: GoogleFonts.raleway(
                      fontWeight: FontWeight.w600, color: Colors.black54))),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: GoogleFonts.raleway())),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.raleway(
                  fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(height: 20),
          ...children,
        ]),
      ),
    );
  }
}

class _ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final String title;

  const _ImageViewerPage({
    required this.imageUrl,
    required this.heroTag,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, style: GoogleFonts.raleway(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.7,
          maxScale: 5,
          child: Hero(
            tag: heroTag,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
