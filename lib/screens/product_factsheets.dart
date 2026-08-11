// product_factsheets.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_svg/flutter_svg.dart';

// --- IMPORT YOUR NEW PDF VIEWER SCREEN ---
import '../widgets/pdf_viewer_screen.dart'; // Adjust the path if you place it elsewhere
import '../widgets/classic_share_icon.dart';
import '../widgets/atmospheric_dark_background.dart';

/// -------------------- MODELS --------------------

class PdfInfo {
  final String name;
  // --- UPDATED: We now use a local asset path, not a URL ---
  final String assetPath;
  const PdfInfo(this.name, this.assetPath);
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

/// -------------------- FACTSHEETS DATA --------------------
// --- UPDATED: All Firebase URLs are replaced with local asset paths ---
final List<CategoryData> underfloorHeatingFactsheetsData = [
  CategoryData("Heating Mats", [
    SubCategoryItem("Heat Mat Pro", [
      PdfInfo(
        "PKM-110 factsheet",
        "assets/pdfs/FACTSHEETS/PKM/Heat-Mat-PKM-110W-heating-mat-factsheet.pdf",
      ),
      PdfInfo(
        "PKM-160 factsheet",
        "assets/pdfs/FACTSHEETS/PKM/Heat-Mat-PKM-160W-heating-mat-factsheet.pdf",
      ),
      PdfInfo(
        "PKM-200 factsheet",
        "assets/pdfs/FACTSHEETS/PKM/Heat-Mat-PKM-200W-heating-mat-factsheet.pdf",
      ),
      PdfInfo(
        "PKM-240 factsheet",
        "assets/pdfs/FACTSHEETS/PKM/Heat-Mat-PKM-240W-heating-mat-factsheet.pdf",
      ),
    ]),
    SubCategoryItem("Heat My Home", [
      PdfInfo(
        "HMH160W factsheet",
        "assets/pdfs/FACTSHEETS/HMHMAT/Heat-My-Home-HMHMAT-factsheet.pdf",
      ),
    ]),
  ]),
  CategoryData("Heating Cables", [
    SubCategoryItem("Heat Mat Pro", [
      PdfInfo(
        "PKC-3.0 factsheet",
        "assets/pdfs/FACTSHEETS/PKC/Heat-Mat-PKC-3mm-cable-factsheet.pdf",
      ),
      PdfInfo(
        "PKC-5.0 factsheet",
        "assets/pdfs/FACTSHEETS/PKC/Heat-Mat-PKC-5mm-cable-factsheet.pdf",
      ),
    ]),
    SubCategoryItem("Heat My Home", [
      PdfInfo(
        "HMHCAB factsheet",
        "assets/pdfs/FACTSHEETS/HMHCAB/Heat-My-Home-HMHCAB-factsheet.pdf",
      ),
    ]),
  ]),
  CategoryData("Combymat/Foil Heating", [
    PdfItem(
      PdfInfo(
        "CBM-150 factsheet",
        "assets/pdfs/FACTSHEETS/CBM/Heat-Mat-CBM-Combymat-factsheet.pdf",
      ),
    ),
    PdfItem(
      PdfInfo(
        "CBM-OVE factsheet",
        "assets/pdfs/FACTSHEETS/CBM/Heat-Mat-CBM-Combymat-overlay-boards-factsheet.pdf",
      ),
    ),
  ]),
  CategoryData("Thermostats", [
    PdfItem(
      PdfInfo(
        "HMT5 factsheet",
        "assets/pdfs/FACTSHEETS/THERMOSTATS/HMT5/Heat-Mat-HMT5-thermostat-factsheet.pdf",
      ),
    ),
    PdfItem(
      PdfInfo(
        "HMH200 factsheet",
        "assets/pdfs/FACTSHEETS/THERMOSTATS/HMH200/Heat-My-Home-HMH200-Wifi-Thermostat-Factsheet.pdf",
      ),
    ),
    PdfItem(
      PdfInfo(
        "HMH100 factsheet",
        "assets/pdfs/FACTSHEETS/THERMOSTATS/HMH100/Heat-My-Home-HMH100-Wifi-Thermostat-Factsheet.pdf",
      ),
    ),
    PdfItem(
      PdfInfo(
        "NGTouch factsheet",
        "assets/pdfs/FACTSHEETS/THERMOSTATS/NGT/Heat-Mat-NGTouch-thermostat-factsheet.pdf",
      ),
    ),
    PdfItem(
      PdfInfo(
        "NGTWifi factsheet",
        "assets/pdfs/FACTSHEETS/THERMOSTATS/NGTWIFI/Heat-Mat-NGTouch-wifi-thermostat-factsheet.pdf",
      ),
    ),
    PdfItem(
      PdfInfo(
        "TPS32 factsheet",
        "assets/pdfs/FACTSHEETS/THERMOSTATS/TPS/Heat-Mat-TPS31-thermostat-factsheet.pdf",
      ),
    ),
  ]),
  CategoryData("Insulation Boards", [
    PdfItem(
      PdfInfo(
        "TTB Insulation factsheet",
        "assets/pdfs/FACTSHEETS/TTB/Heat-Mat-TTB-insulation-board-factsheet.pdf",
      ),
    ),
  ]),
];

final List<CategoryData> frostProtectionFactsheetsData = [
  CategoryData("Trace Heating", [
    PdfItem(
      PdfInfo(
        "Trace Heating Cable factsheet",
        "assets/pdfs/FACTSHEETS/ICEANDSNOW/Trace-Heating-Factsheet.pdf",
      ),
    ),
  ]),
  CategoryData("Pipe Protection", [
    PdfItem(
      PdfInfo(
        "PipeGuard factsheet",
        "assets/pdfs/FACTSHEETS/ICEANDSNOW/PipeGuard_Factsheet.pdf",
      ),
    ),
  ]),
  CategoryData("Gutter & Roof Heating", [
    PdfItem(
      PdfInfo(
        "Gutter and Roof Heating Cable factsheet",
        "assets/pdfs/FACTSHEETS/ICEANDSNOW/Roof-and-gutter-heating-factsheet.pdf",
      ),
    ),
  ]),
  CategoryData("Driveway & Ramp Heating", [
    PdfItem(
      PdfInfo(
        "Driveway Heating Cable factsheet",
        "assets/pdfs/FACTSHEETS/ICEANDSNOW/Heat-Mat-50W-Snow-Melting-Cable-Factsheet.pdf",
      ),
    ),
  ]),
];

/// -------------------- HELPERS --------------------
// --- REWRITTEN HELPER FUNCTIONS TO WORK OFFLINE WITH ASSETS ---

/// A helper to copy a bundled asset to a temporary file.
/// This is needed for sharing and saving, as those plugins require a file path.
Future<File> _copyAssetToTempFile(String assetPath) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${assetPath.split('/').last}');

  // Copy from assets to the temporary file.
  final byteData = await rootBundle.load(assetPath);
  await file.writeAsBytes(
    byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
  );
  return file;
}

/// Shares the PDF by copying it to a temp file first.
Future<void> shareFile(
  BuildContext context,
  PdfInfo pdf,
  void Function(String) toast,
) async {
  try {
    toast('Preparing to share...');
    final tempFile = await _copyAssetToTempFile(pdf.assetPath);
    await Share.shareXFiles([XFile(tempFile.path)], text: pdf.name);
  } catch (e) {
    toast('Share failed: $e');
  }
}

/// Saves the PDF to the device's public "Downloads" folder.
Future<void> downloadFile(
  BuildContext context,
  PdfInfo pdf,
  void Function(String) toast,
) async {
  try {
    toast('Preparing file...');
    // Load the asset data directly into memory
    final byteData = await rootBundle.load(pdf.assetPath);
    final Uint8List bytes = byteData.buffer.asUint8List();

    // Sanitize the filename for saving
    final sanitizedFileName = pdf.name
        .replaceAll(RegExp(r'[^\w\s.-]+'), '')
        .replaceAll(' ', '_');

    // Use FileSaver to save the bytes
    await FileSaver.instance.saveFile(
      name: sanitizedFileName,
      bytes: bytes,
      ext: 'pdf',
      mimeType: MimeType.pdf,
    );

    toast('File save dialog opened.');
  } catch (e) {
    toast('Save failed: $e');
  }
}

/// Opens the PDF in the dedicated viewer screen. This is now the primary action.
void openPdf(BuildContext context, PdfInfo pdf) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          PdfViewerScreen(assetPath: pdf.assetPath, screenTitle: pdf.name),
    ),
  );
}

/// -------------------- REUSABLE UI --------------------
// ... (Category and SubCategory widgets are unchanged)
class Category extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? svgAsset;
  final Color accentColor;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget Function() content;

  const Category({
    super.key,
    required this.title,
    required this.icon,
    this.svgAsset,
    required this.accentColor,
    required this.expanded,
    required this.onToggle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF171818), Color(0xFF242525)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            HSLColor.fromColor(accentColor)
                                .withLightness(
                                  (HSLColor.fromColor(accentColor).lightness -
                                          0.12)
                                      .clamp(0.0, 1.0),
                                )
                                .toColor(),
                            accentColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: svgAsset == null
                          ? Icon(icon, color: Colors.white, size: 27)
                          : Center(
                              child: SvgPicture.asset(
                                svgAsset!,
                                width: 27,
                                height: 27,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: accentColor,
                      size: 29,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.white.withValues(alpha: 0.10),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: content(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SubCategory extends StatelessWidget {
  final String title;
  final Color accentColor;
  final Widget Function() content;
  const SubCategory({
    super.key,
    required this.title,
    required this.accentColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 7, 2, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.raleway(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          content(),
        ],
      ),
    );
  }
}

class PdfLink extends StatelessWidget {
  final PdfInfo pdfInfo;
  final Color accentColor;
  final VoidCallback onShare;
  // --- UPDATED: The main tap action is now just 'onView' ---
  final VoidCallback onView;
  // --- ADDED: A specific callback for the download button ---
  final VoidCallback onDownload;

  const PdfLink({
    super.key,
    required this.pdfInfo,
    required this.accentColor,
    required this.onShare,
    required this.onView,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 5, 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF141515), Color(0xFF202121)],
            ),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pdfInfo.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _PdfActionButton(
                icon: ClassicShareIcon(color: accentColor, size: 21),
                tooltip: 'Share',
                accentColor: accentColor,
                onPressed: onShare,
              ),
              _PdfActionButton(
                icon: Icon(
                  Icons.download_rounded,
                  color: accentColor,
                  size: 21,
                ),
                tooltip: 'Save to Device',
                accentColor: accentColor,
                onPressed: onDownload,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PdfActionButton extends StatelessWidget {
  final Widget icon;
  final String tooltip;
  final Color accentColor;
  final VoidCallback onPressed;

  const _PdfActionButton({
    required this.icon,
    required this.tooltip,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: icon,
      style: IconButton.styleFrom(
        side: BorderSide(color: accentColor.withValues(alpha: 0.85)),
        shape: const CircleBorder(),
      ),
    );
  }
}

/// -------------------- FACTSHEETS SCREEN --------------------

class ProductFactsheetsScreen extends StatefulWidget {
  final String categoryTitle;
  final Color appBarColor;
  final List<CategoryData> factsheetData;
  const ProductFactsheetsScreen({
    super.key,
    required this.categoryTitle,
    required this.appBarColor,
    required this.factsheetData,
  });

  @override
  State<ProductFactsheetsScreen> createState() =>
      _ProductFactsheetsScreenState();
}

class _ProductFactsheetsScreenState extends State<ProductFactsheetsScreen> {
  String searchQuery = '';
  Set<String> expanded = {};

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered(widget.factsheetData, searchQuery);

    if (searchQuery.isNotEmpty) {
      expanded = filtered.map((e) => e.title).toSet();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: const Color(0xFF101111),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: widget.appBarColor,
            size: 30,
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.categoryTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Browse technical product information',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.raleway(
                color: const Color(0xFFB7B7B7),
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(
              Icons.description_outlined,
              color: widget.appBarColor,
              size: 27,
            ),
          ),
        ],
      ),
      body: AtmosphericDarkBackground(
        accentColor: widget.appBarColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _SearchField(
                hint: 'Search factsheets (e.g. PKM-160, Thermostat)',
                value: searchQuery,
                accentColor: widget.appBarColor,
                onChanged: (v) => setState(() => searchQuery = v),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: filtered.isEmpty && searchQuery.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Text(
                          'No results found.',
                          style: GoogleFonts.raleway(
                            color: const Color(0xFFB7B7B7),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (final cat in filtered)
                            Category(
                              title: cat.title,
                              icon: _categoryIcon(cat.title),
                              svgAsset: _usesNestTrueRadiant(cat.title)
                                  ? 'assets/images/nest_true_radiant.svg'
                                  : null,
                              accentColor: widget.appBarColor,
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
                                          accentColor: widget.appBarColor,
                                          content: () => Column(
                                            children: [
                                              for (final pdf in item.pdfs)
                                                // --- UPDATED: Pass correct functions to PdfLink ---
                                                PdfLink(
                                                  pdfInfo: pdf,
                                                  accentColor:
                                                      widget.appBarColor,
                                                  onShare: () => shareFile(
                                                    context,
                                                    pdf,
                                                    _toast,
                                                  ),
                                                  onView: () =>
                                                      openPdf(context, pdf),
                                                  onDownload: () =>
                                                      downloadFile(
                                                        context,
                                                        pdf,
                                                        _toast,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        )
                                      else if (item is PdfItem)
                                        // --- UPDATED: Pass correct functions to PdfLink ---
                                        PdfLink(
                                          pdfInfo: item.info,
                                          accentColor: widget.appBarColor,
                                          onShare: () => shareFile(
                                            context,
                                            item.info,
                                            _toast,
                                          ),
                                          onView: () =>
                                              openPdf(context, item.info),
                                          onDownload: () => downloadFile(
                                            context,
                                            item.info,
                                            _toast,
                                          ),
                                        ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('mat')) return Icons.waves_rounded;
    if (normalized.contains('cable')) return Icons.cable_rounded;
    if (normalized.contains('comby') || normalized.contains('foil')) {
      return Icons.layers_outlined;
    }
    if (normalized.contains('thermostat')) return Icons.thermostat_rounded;
    if (normalized.contains('insulation')) return Icons.layers;
    if (normalized.contains('trace')) return Icons.waves_rounded;
    if (normalized.contains('pipe')) return Icons.cable_rounded;
    if (normalized.contains('gutter') || normalized.contains('roof')) {
      return Icons.roofing_rounded;
    }
    if (normalized.contains('driveway') || normalized.contains('ramp')) {
      return Icons.directions_car;
    }
    return Icons.description_outlined;
  }

  bool _usesNestTrueRadiant(String title) {
    final normalized = title.toLowerCase();
    return normalized.contains('mat') || normalized.contains('trace');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide previous toasts
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- Search logic remains unchanged and will work perfectly ---
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
          final matches = item.pdfs
              .where((p) => p.name.toLowerCase().contains(query))
              .toList();
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

// --- Search field widget is unchanged ---
class _SearchField extends StatelessWidget {
  final String hint;
  final String value;
  final Color accentColor;
  final ValueChanged<String> onChanged;
  const _SearchField({
    required this.hint,
    required this.value,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      style: GoogleFonts.raleway(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.raleway(
          color: const Color(0xFF8F8F8F),
          fontSize: 14,
        ),
        prefixIcon: Icon(Icons.search_rounded, color: accentColor),
        suffixIcon: value.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, color: accentColor),
                onPressed: () => onChanged(''),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentColor.withValues(alpha: 0.65)),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentColor, width: 1.2),
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: const Color(0xFF1B1C1C),
      ),
    );
  }
}
