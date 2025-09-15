import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

/// -------------------- MODELS --------------------

class PdfInfo {
  /// Can be a full gs:// or https URL, or a relative storage path like:
  /// "INSTRUCTIONS/PKM/Heat-Mat-PKM-110W-heating-mat-instructions.pdf"
  final String name;
  final String pathOrUrl;
  const PdfInfo(this.name, this.pathOrUrl);
}

abstract class ContentItem {}

class SubCategoryItem extends ContentItem {
  final String title;
  final List<PdfInfo> pdfs;
  SubCategoryItem(this.title, this.pdfs);
}

class PdfItem extends ContentItem {
  final PdfInfo info;
  PdfItem(this.info);
}

class CategoryData {
  final String title;
  final List<ContentItem> items;
  CategoryData(this.title, this.items);
}

/// -------------------- INSTRUCTIONS DATA --------------------
/// TIP: Prefer using RELATIVE paths (no gs://), e.g.
/// "INSTRUCTIONS/PKM/Heat-Mat-PKM-110W-heating-mat-instructions.pdf"
/// so the default bucket is used automatically.
///
/// Double-check EXACT folder/filenames in Firebase Storage (case-sensitive!)

final List<CategoryData> underfloorHeatingInstructionsData = [
  CategoryData("Heating Mats", [
    SubCategoryItem("Heat Mat Pro", [
      PdfInfo("PKM Heating Mat Instructions",
          "INSTRUCTIONS/PKM/Heat-Mat-PKM-heating-mat-instructions.pdf"),
    ]),
    SubCategoryItem("Heat My Home", [
      PdfInfo("HMH160W instructions",
          "INSTRUCTIONS/HMHMAT/Heat-My-Home-HMHMAT-instructions.pdf"),
    ]),
  ]),
  CategoryData("Heating Cables", [
    SubCategoryItem("Heat Mat Pro", [
      PdfInfo("PKC-3.0 instructions",
          "INSTRUCTIONS/PKC/Heat-Mat-PKC-3mm-cable-instructions.pdf"),
      PdfInfo("PKC-5.0 instructions",
          "INSTRUCTIONS/PKC/Heat-Mat-PKC-5mm-cable-instructions.pdf"),
    ]),
    SubCategoryItem("Heat My Home", [
      PdfInfo("HMHCAB instructions",
          "INSTRUCTIONS/HMHCAB/Heat-My-Home-HMHCAB-instructions.pdf"),
    ]),
  ]),
  CategoryData("Thermostats", [
    PdfItem(PdfInfo("HMT5 instructions",
        "INSTRUCTIONS/THERMOSTATS/HMT5/Heat-Mat-HMT5-thermostat-instructions.pdf")),
    PdfItem(PdfInfo("HMH200 instructions",
        "INSTRUCTIONS/THERMOSTATS/HMH200/Heat-My-Home-HMH200-instructions.pdf")),
    PdfItem(PdfInfo("HMH100 instructions",
        "INSTRUCTIONS/THERMOSTATS/HMH100/Heat-My-Home-HMH100-instructions.pdf")),
    PdfItem(PdfInfo("NGTouch instructions",
        "INSTRUCTIONS/THERMOSTATS/NGT/Heat-Mat-NGTouch-thermostat-instructions.pdf")),
    PdfItem(PdfInfo("NGTouch user manual",
        "INSTRUCTIONS/THERMOSTATS/NGT/Heat-Mat-NGTouch-thermostat-user-manual.pdf")),
    PdfItem(PdfInfo("NGTouch quick start guide",
        "INSTRUCTIONS/THERMOSTATS/NGT/Heat-Mat-NGTouch-thermostat-quick-start-guide.pdf")),
    PdfItem(PdfInfo("NGTWifi instructions",
        "INSTRUCTIONS/THERMOSTATS/NGTWIFI/Heat-Mat-NGTouch-3-0-wifi-thermostat-instructions.pdf")),
    PdfItem(PdfInfo("NGTWifi user manual",
        "INSTRUCTIONS/THERMOSTATS/NGTWIFI/Heat-Mat-NGTouch-3-0-wifi-thermostat-user-manual.pdf")),
    PdfItem(PdfInfo("TPS32 instructions",
        "INSTRUCTIONS/THERMOSTATS/TPS/Heat-Mat-TPS32-thermostat-user-manual.pdf")),
  ]),
];

final List<CategoryData> frostProtectionInstructionsData = [
  // Pipe Protection Cables
  CategoryData("Pipe Protection Cables", [
    PdfItem(PdfInfo(
      "PipeGuard instructions",
      "INSTRUCTIONS/ICEANDSNOW/PipeGuard-instructions.pdf",
    )),
    PdfItem(PdfInfo(
      "Trace Heating instructions",
      "INSTRUCTIONS/ICEANDSNOW/Trace-Cable-Installation-Guide.pdf",
    )),
  ]),

  // Gutter & Roof Heating
  CategoryData("Gutter & Roof Heating", [
    PdfItem(PdfInfo(
      "Roof Heating generic instructions",
      "INSTRUCTIONS/ICEANDSNOW/Heat-Mat-Ice-and-Snow-Systems-Roof-Heating-Installation-Instructions-Generic.pdf",
    )),
  ]),

  // Driveway & Ramp Heating
  CategoryData("Driveway & Ramp Heating", [
    PdfItem(PdfInfo(
      "50W Driveway heating cable instructions",
      "INSTRUCTIONS/ICEANDSNOW/Driveway-Heating-Cable-Instructions.pdf",
    )),
  ]),

  // Controllers & Sensors with subcategories
  CategoryData("Controllers & Sensors", [
    SubCategoryItem("Controllers/Thermostats", [
      PdfInfo("FRO-10A-STAT thermostat instructions",
          "INSTRUCTIONS/ICEANDSNOW/FRO-10A-STAT-Instructions.pdf"),
      // PdfInfo("FRO-16A-GSTA thermostat instructions", "INSTRUCTIONS/ICEANDSNOW/<missing>.pdf"), // (left commented as in your source)
      PdfInfo("FRO-16A-STAT thermostat instructions",
          "INSTRUCTIONS/ICEANDSNOW/FRO-16A-STAT-Instructions.pdf"),
      PdfInfo("FRO-48A-STAT thermostat instructions",
          "INSTRUCTIONS/ICEANDSNOW/FRO-48A-STAT-Instructions.pdf"),
      PdfInfo("TRA-20A-STAT thermostat instructions",
          "INSTRUCTIONS/ICEANDSNOW/TRA-20A-STAT-Instructions.pdf"),
    ]),
    SubCategoryItem("Sensors", [
      PdfInfo("FRO-GRO-SENS ground sensor instructions",
          "INSTRUCTIONS/ICEANDSNOW/FRO-GRO-SENS-Instructions.pdf"),
      PdfInfo("FRO-GRO-TEMP ground/pipe sensor instructions",
          "INSTRUCTIONS/ICEANDSNOW/FRO-GRO-TEMP-instructions.pdf"),
      PdfInfo("FRO-TEM-SENS air sensor instructions",
          "INSTRUCTIONS/ICEANDSNOW/FRO-TEM-SENS-instructions.pdf"),
      PdfInfo("FRO-GUT-SENS gutter moisture sensor instructions",
          "INSTRUCTIONS/ICEANDSNOW/FRO-GUT-SENS-instructions.pdf"),
    ]),
  ]),
];

/// -------------------- HELPERS --------------------

Reference _resolveRef(PdfInfo pdf) {
  final u = pdf.pathOrUrl.trim();
  if (u.startsWith('gs://') || u.startsWith('http')) {
    return FirebaseStorage.instance.refFromURL(u);
  }
  // Treat as relative path under default bucket
  return FirebaseStorage.instance.ref(u);
}

Future<File> _downloadToTemp(PdfInfo pdf) async {
  final dir = await getTemporaryDirectory();
  final safeName = pdf.name.replaceAll(RegExp(r'[^\w\-\.\(\) ]'), '_');
  final file = File('${dir.path}/$safeName.pdf');

  final ref = _resolveRef(pdf);

  try {
    // Will throw if object does not exist; helpful for a clear message
    await ref.getDownloadURL();
  } catch (e) {
    throw Exception(
      'File not found in Storage at "${pdf.pathOrUrl}". '
      'Please verify folder/filename & case in Firebase Console.',
    );
  }

  await ref.writeToFile(file);
  return file;
}

// =================== THIS FUNCTION IS UPDATED ===================
Future<void> _shareFile(BuildContext context, PdfInfo pdf, void Function(String) toast) async {
  try {
    toast('Preparing file...'); // <-- ADDED THIS LINE
    final f = await _downloadToTemp(pdf);
    await Share.shareXFiles([XFile(f.path)], text: pdf.name);
  } catch (e) {
    toast('Share failed: $e');
  }
}
// ================================================================

// =================== THIS FUNCTION IS UPDATED ===================
Future<void> _downloadAndOpenFile(BuildContext context, PdfInfo pdf, void Function(String) toast) async {
  try {
    toast('Downloading to open...'); // <-- ADDED THIS LINE
    final f = await _downloadToTemp(pdf);
    final result = await OpenFilex.open(f.path);
    if (result.type != ResultType.done) {
      toast('Could not open file (${result.message ?? 'unknown error'}).');
    }
  } catch (e) {
    toast('Open failed: $e');
  }
}
// ================================================================


/// -------------------- REUSABLE UI --------------------

class Category extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget Function() content;

  const Category({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                  ),
                  Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          if (expanded)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: content(),
            ),
        ],
      ),
    );
  }
}

class SubCategory extends StatelessWidget {
  final String title;
  final Widget Function() content;
  const SubCategory({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFf85c37),
              )),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: content(),
          ),
        ],
      ),
    );
  }
}

class PdfLink extends StatelessWidget {
  final PdfInfo pdfInfo;
  final VoidCallback onShare;
  final VoidCallback onDownloadAndOpen;

  const PdfLink({
    super.key,
    required this.pdfInfo,
    required this.onShare,
    required this.onDownloadAndOpen,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.raleway(fontSize: 14);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
          const SizedBox(width: 8),
          // Clicking the name performs Download & Open (no visual underline)
          Expanded(
            child: InkWell(
              onTap: onDownloadAndOpen,
              child: Text(pdfInfo.name, style: textStyle),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Share',
            onPressed: onShare,
          ),
          // Standard download icon (does Download & Open)
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download',
            onPressed: onDownloadAndOpen,
          ),
        ],
      ),
    );
  }
}

/// -------------------- INSTRUCTIONS SCREEN --------------------

class ProductInstructionsScreen extends StatefulWidget {
  final String categoryTitle;
  final Color appBarColor;
  final List<CategoryData> instructionData;
  const ProductInstructionsScreen({
    super.key,
    required this.categoryTitle,
    required this.appBarColor,
    required this.instructionData,
  });

  @override
  State<ProductInstructionsScreen> createState() => _ProductInstructionsScreenState();
}

class _ProductInstructionsScreenState extends State<ProductInstructionsScreen> {
  String searchQuery = '';
  Set<String> expanded = {};

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered(widget.instructionData, searchQuery);

    if (searchQuery.isNotEmpty) {
      expanded = filtered.map((e) => e.title).toSet();
    }

    return Scaffold(
      backgroundColor: widget.appBarColor,
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: GoogleFonts.raleway(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.menu_book, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SearchField(
              hint: 'Search Instructions (e.g., PKM-160, Thermostats...)',
              value: searchQuery,
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: filtered.isEmpty && searchQuery.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Text('No results found.', style: GoogleFonts.raleway(color: Colors.grey)),
                        ),
                      )
                    : Column(
                        children: [
                          for (final cat in filtered)
                            Category(
                              title: cat.title,
                              expanded: expanded.contains(cat.title),
                              onToggle: () {
                                setState(() {
                                  if (expanded.contains(cat.title)) {
                                    expanded.remove(cat.title);
                                  } else {
                                    expanded.add(cat.title);
                                  }
                                });
                              },
                              content: () {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final item in cat.items)
                                      if (item is SubCategoryItem)
                                        SubCategory(
                                          title: item.title,
                                          content: () => Column(
                                            children: [
                                              for (final pdf in item.pdfs)
                                                PdfLink(
                                                  pdfInfo: pdf,
                                                  onShare: () => _shareFile(context, pdf, _toast),
                                                  onDownloadAndOpen: () =>
                                                      _downloadAndOpenFile(context, pdf, _toast),
                                                ),
                                            ],
                                          ),
                                        )
                                      else if (item is PdfItem)
                                        PdfLink(
                                          pdfInfo: item.info,
                                          onShare: () => _shareFile(context, item.info, _toast),
                                          onDownloadAndOpen: () =>
                                              _downloadAndOpenFile(context, item.info, _toast),
                                        ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  List<CategoryData> _filtered(List<CategoryData> data, String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return data;

    final List<CategoryData> out = [];
    for (final cat in data) {
      final titleMatch = cat.title.toLowerCase().contains(query);
      final List<ContentItem> items = [];

      for (final item in cat.items) {
        if (item is SubCategoryItem) {
          final subMatch = item.title.toLowerCase().contains(query);
          final matches = item.pdfs.where((p) => p.name.toLowerCase().contains(query)).toList();
          if (subMatch) {
            items.add(item);
          } else if (matches.isNotEmpty) {
            items.add(SubCategoryItem(item.title, matches));
          }
        } else if (item is PdfItem) {
          if (item.info.name.toLowerCase().contains(query)) {
            items.add(item);
          }
        }
      }

      if (titleMatch) {
        out.add(cat);
      } else if (items.isNotEmpty) {
        out.add(CategoryData(cat.title, items));
      }
    }
    return out;
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.hint, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      style: GoogleFonts.raleway(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.raleway(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        suffixIcon: value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () => onChanged(''),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
    );
  }
}