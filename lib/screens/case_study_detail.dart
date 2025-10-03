// case_study_detail.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/file_saver_adapter.dart';
import 'package:shimmer/shimmer.dart';

import 'case_studies.dart';
import '../widgets/pdf_viewer_screen.dart';

/// --- HELPER FUNCTIONS FOR OFFLINE ASSETS ---

Future<File> _copyAssetToTempFile(String assetPath) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${assetPath.split('/').last}');
  final byteData = await rootBundle.load(assetPath);
  await file.writeAsBytes(byteData.buffer.asUint8List(
    byteData.offsetInBytes,
    byteData.lengthInBytes,
  ));
  return file;
}

Future<void> _shareAsset(BuildContext context, CaseStudy study, void Function(String) toast) async {
  try {
    toast('Preparing to share...');
    final tempFile = await _copyAssetToTempFile(study.pdfAssetPath);
    await Share.shareXFiles([XFile(tempFile.path)], text: study.title);
  } catch (e) {
    toast('Share failed: $e');
  }
}

// --- THIS IS THE CORRECTED FUNCTION ---
Future<void> _saveAsset(BuildContext context, CaseStudy study, void Function(String) toast) async {
  try {
    toast('Preparing file...');
    final byteData = await rootBundle.load(study.pdfAssetPath);
    final sanitizedFileName = study.title.replaceAll(RegExp(r'[^\w\s.-]+'), '').replaceAll(' ', '_');
    
    await FileSaver.instance.saveFile(
      name: sanitizedFileName,
      bytes: byteData.buffer.asUint8List(),
      ext: 'pdf',
      mimeType: MimeType.pdf,
    );
  } catch (e) {
    toast('Save failed: $e');
  }
}

void _viewAsset(BuildContext context, CaseStudy study) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PdfViewerScreen(
        assetPath: study.pdfAssetPath,
        screenTitle: study.title,
      ),
    ),
  );
}

class CaseStudyDetailScreen extends StatelessWidget {
  final String? caseStudyId;
  const CaseStudyDetailScreen({super.key, required this.caseStudyId});

  @override
  Widget build(BuildContext context) {
    void showToast(String msg) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }

    final study = allCaseStudies.firstWhere(
      (e) => e.id == caseStudyId,
      orElse: () => const CaseStudy(
        id: 'missing',
        title: 'Case Study Not Found',
        imageAssetPath: 'assets/images/front_image.jpg',
        summary: '',
        categories: [],
        projectDetails: 'The requested case study could not be found.',
        challenge: '',
        solution: '',
        pdfAssetPath: '',
      ),
    );

    final titleColor = study.categories.contains('Ice & Snow')
        ? const Color(0xFF009ADC)
        : const Color(0xFFf89f37);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          study.title,
          style: GoogleFonts.raleway(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFFf89f37),
        foregroundColor: Colors.white,
        actions: [
          if (study.pdfAssetPath.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share PDF',
              onPressed: () => _shareAsset(context, study, showToast),
            ),
        ],
      ),
      body: ListView(
        children: [
          if (study.imageAssetPath.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                study.imageAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _ShimmerPlaceholder();
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _DetailSection(
                  title: 'The Project',
                  content: study.projectDetails,
                  titleColor: titleColor,
                ),
                if (study.challenge.isNotEmpty)
                  _DetailSection(
                    title: 'The Challenge',
                    content: study.challenge,
                    titleColor: titleColor,
                  ),
                if (study.solution.isNotEmpty)
                  _DetailSection(
                    title: 'The Solution',
                    content: study.solution,
                    titleColor: titleColor,
                  ),
                const SizedBox(height: 24),
                
                if (study.pdfAssetPath.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _viewAsset(context, study),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text('View Full Case Study PDF', style: GoogleFonts.raleway(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf89f37),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _saveAsset(context, study, showToast),
                      icon: const Icon(Icons.download_for_offline_outlined),
                      label: Text('Save PDF to Device', style: GoogleFonts.raleway(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFf89f37),
                        side: const BorderSide(color: Color(0xFFf89f37)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ] else
                  Text(
                    'No PDF available for this case study.',
                    style: GoogleFonts.raleway(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;
  final Color titleColor;

  const _DetailSection({
    required this.title,
    required this.content,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.raleway(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: titleColor,
              )),
          const SizedBox(height: 8),
          Text(content,
              style: GoogleFonts.raleway(
                fontSize: 16,
                color: Colors.black87,
                height: 1.45,
              )),
        ],
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black12,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              color: Colors.black26,
            ),
          ),
        ),
        Opacity(
          opacity: 0.7,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white),
          ),
        ),
      ],
    );
  }
}