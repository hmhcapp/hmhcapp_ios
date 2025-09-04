import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'case_studies.dart';
import 'product_factsheets.dart' show PdfInfo, shareFile, downloadFile, downloadAndOpenFile;

class CaseStudyDetailScreen extends StatelessWidget {
  final String? caseStudyId;
  const CaseStudyDetailScreen({super.key, required this.caseStudyId});

  @override
  Widget build(BuildContext context) {
    final study = allCaseStudies.firstWhere(
      (e) => e.id == caseStudyId,
      orElse: () => const CaseStudy(
        id: 'missing',
        title: 'Case Study',
        imageUrl: '',
        summary: '',
        categories: [],
        projectDetails: 'Not found.',
        challenge: '',
        solution: '',
        pdfPath: '',
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
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => shareFile(
              context,
              PdfInfo(study.title, study.pdfPath),
              _toast,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => downloadFile(
              context,
              PdfInfo(study.title, study.pdfPath),
              _toast,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (study.imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                study.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
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
                _DetailSection(
                  title: 'The Challenge',
                  content: study.challenge,
                  titleColor: titleColor,
                ),
                _DetailSection(
                  title: 'The Solution',
                  content: study.solution,
                  titleColor: titleColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'The details above are just a summary. To view the full case study, please use the buttons below.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => shareFile(
                          context,
                          PdfInfo(study.title, study.pdfPath),
                          _toast,
                        ),
                        icon: const Icon(Icons.share),
                        label: Text('Share', style: GoogleFonts.raleway()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => downloadFile(
                          context,
                          PdfInfo(study.title, study.pdfPath),
                          _toast,
                        ),
                        icon: const Icon(Icons.download),
                        label: Text('Save PDF', style: GoogleFonts.raleway()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    // handled inside shareFile/downloadFile via ScaffoldMessenger
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.raleway(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
