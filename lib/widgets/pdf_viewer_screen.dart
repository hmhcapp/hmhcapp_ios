// lib/widgets/pdf_viewer_screen.dart
//
// Mobile-only PDF viewer using Syncfusion (pure Flutter composition).
// Two visible save controls so users can't miss it:
//  - AppBar Save icon
//  - Bottom "Save PDF" button
// Saving uses flutter_file_dialog to open the native "Save to Files" / system picker.
//
// Requirements in pubspec.yaml:
//   flutter_file_dialog: ^3.0.2
//   syncfusion_flutter_pdfviewer: ^29.1.33
//
// IMPORTANT: There is intentionally NO import of `flutter_pdfview` in this file.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String assetPath;
  final String screenTitle;

  const PdfViewerScreen({
    super.key,
    required this.assetPath,
    required this.screenTitle,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _controller = PdfViewerController();
  bool _isReady = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _savePdf() async {
    _toast('Preparing file…');
    try {
      final byteData = await rootBundle.load(widget.assetPath);
      final Uint8List bytes = byteData.buffer.asUint8List();

      final safe = widget.screenTitle
          .replaceAll(RegExp(r'[^\w\s.-]+'), '')
          .replaceAll(' ', '_')
          .replaceAll('.pdf', '')
          .trim();

      final resultPath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: bytes,
          fileName: '$safe.pdf',
          mimeTypesFilter: const ['application/pdf'],
        ),
      );

      if (resultPath == null || resultPath.isEmpty) {
        _toast('Save cancelled.');
      } else {
        _toast('Saved.');
      }
    } catch (e) {
      _toast('Save failed: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _isReady && _error == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.screenTitle, style: GoogleFonts.raleway(color: Colors.white)),
        backgroundColor: const Color(0xFF333333),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white),
            tooltip: canSave ? 'Save to device' : 'Preparing…',
            onPressed: canSave ? _savePdf : null,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download_for_offline_outlined),
              label: const Text('Save PDF'),
              onPressed: canSave ? _savePdf : null,
            ),
          ),
        ),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(color: Colors.red),
                ),
              ),
            )
          : SfPdfViewer.asset(
              widget.assetPath,
              controller: _controller,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableDoubleTapZooming: true,
              onDocumentLoaded: (details) => setState(() => _isReady = true),
              onDocumentLoadFailed: (details) => setState(() {
                _error = 'Error: Could not load PDF.\n${details.error}';
                _isReady = false;
              }),
            ),
    );
  }
}
