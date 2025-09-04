import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

/// -------------------- MODELS --------------------

class PdfInfo {
  final String name;
  final String url; // can be gs:// or https
  const PdfInfo(this.name, this.url);
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

final List<CategoryData> underfloorHeatingFactsheetsData = [
  CategoryData("Heating Mats", [
    SubCategoryItem("Heat Mat Pro", [
      PdfInfo("PKM-110 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-110W-heating-mat-factsheet.pdf"),
      PdfInfo("PKM-160 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-160W-heating-mat-factsheet.pdf"),
      PdfInfo("PKM-200 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-200W-heating-mat-factsheet.pdf"),
      PdfInfo("PKM-240 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-240W-heating-mat-factsheet.pdf"),
    ]),
    SubCategoryItem("Heat My Home", [
      PdfInfo("HMH160W factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/HMHMAT/Heat-My-Home-HMHMAT-factsheet.pdf"),
    ]),
  ]),
  CategoryData("Heating Cables", [
    SubCategoryItem("Heat Mat Pro", [
      PdfInfo("PKC-3.0 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKC/Heat-Mat-PKC-3mm-cable-factsheet.pdf"),
      PdfInfo("PKC-5.0 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKC/Heat-Mat-PKC-5mm-cable-factsheet.pdf"),
    ]),
    SubCategoryItem("Heat My Home", [
      PdfInfo("HMHCAB factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/HMHCAB/Heat-My-Home-HMHCAB-factsheet.pdf"),
    ]),
  ]),
  CategoryData("Combymat/Foil Heating", [
    PdfItem(PdfInfo("CBM-150 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/CBM/Heat-Mat-CBM-Combymat-factsheet.pdf")),
    PdfItem(PdfInfo("CBM-OVE factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/CBM/Heat-Mat-CBM-Combymat-overlay-boards-factsheet.pdf")),
  ]),
  CategoryData("Thermostats", [
    PdfItem(PdfInfo("HMT5 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/HMT5/Heat-Mat-HMT5-thermostat-factsheet.pdf")),
    PdfItem(PdfInfo("HMH200 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/HMH200/Heat-My-Home-HMH200-Wifi-Thermostat-Factsheet.pdf")),
    PdfItem(PdfInfo("HMH100 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/HMH100/Heat-My-Home-HMH100-Wifi-Thermostat-Factsheet.pdf")),
    PdfItem(PdfInfo("NGTouch factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/NGT/Heat-Mat-NGTouch-thermostat-factsheet.pdf")),
    PdfItem(PdfInfo("NGTWifi factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/NGTWIFI/Heat-Mat-NGTouch-wifi-thermostat-factsheet.pdf")),
    PdfItem(PdfInfo("TPS32 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/TPS/Heat-Mat-TPS31-thermostat-factsheet.pdf")),
  ]),
  CategoryData("Insulation Boards", [
    PdfItem(PdfInfo("TTB Insulation factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/TTB/Heat-Mat-TTB-insulation-board-factsheet.pdf")),
  ]),
];

final List<CategoryData> frostProtectionFactsheetsData = [
  CategoryData("Trace Heating", [
    PdfItem(PdfInfo("Trace Heating Cable factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/Trace-Heating-Factsheet.pdf")),
  ]),
  CategoryData("Pipe Protection", [
    PdfItem(PdfInfo("PipeGuard factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/PipeGuard_Factsheet.pdf")),
  ]),
  CategoryData("Gutter & Roof Heating", [
    PdfItem(PdfInfo("Gutter and Roof Heating Cable factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/Roof-and-gutter-heating-factsheet.pdf")),
  ]),
  CategoryData("Driveway & Ramp Heating", [
    PdfItem(PdfInfo("Driveway Heating Cable factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/Heat-Mat-50W-Snow-Melting-Cable-Factsheet.pdf")),
  ]),
];

/// -------------------- HELPERS --------------------

Future<File> _downloadToTemp(PdfInfo pdf) async {
  // Use Firebase Storage for gs://; otherwise treat as direct URL not implemented here
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${pdf.name.replaceAll(' ', '_')}.pdf');

  final ref = FirebaseStorage.instance.refFromURL(pdf.url);
  await ref.writeToFile(file);
  return file;
}

Future<void> shareFile(BuildContext context, PdfInfo pdf, void Function(String) toast) async {
  try {
    final f = await _downloadToTemp(pdf);
    await Share.shareXFiles([XFile(f.path)], text: pdf.name);
  } catch (e) {
    toast('Share failed: $e');
  }
}

Future<void> downloadFile(BuildContext context, PdfInfo pdf, void Function(String) toast) async {
  try {
    await _downloadToTemp(pdf);
    toast('Downloaded ${pdf.name}');
  } catch (e) {
    toast('Download failed: $e');
  }
}

Future<void> downloadAndOpenFile(BuildContext context, PdfInfo pdf, void Function(String) toast) async {
  try {
    final f = await _downloadToTemp(pdf);
    await OpenFilex.open(f.path);
  } catch (e) {
    toast('Open failed: $e');
  }
}

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
                      style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.bold),
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
  final VoidCallback onDownload;
  final VoidCallback onDownloadAndOpen;

  const PdfLink({
    super.key,
    required this.pdfInfo,
    required this.onShare,
    required this.onDownload,
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
          Expanded(child: Text(pdfInfo.name, style: textStyle)),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Share',
            onPressed: onShare,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download',
            onPressed: onDownload,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Download & Open',
            onPressed: onDownloadAndOpen,
          ),
        ],
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
  State<ProductFactsheetsScreen> createState() => _ProductFactsheetsScreenState();
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
      backgroundColor: widget.appBarColor,
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: GoogleFonts.raleway(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.description, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SearchField(
              hint: 'Search Factsheets (e.g., PKM-160, Thermostats...)',
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
                                                  onShare: () => shareFile(context, pdf, _toast),
                                                  onDownload: () => downloadFile(context, pdf, _toast),
                                                  onDownloadAndOpen: () => downloadAndOpenFile(context, pdf, _toast),
                                                ),
                                            ],
                                          ),
                                        )
                                      else if (item is PdfItem)
                                        PdfLink(
                                          pdfInfo: item.info,
                                          onShare: () => shareFile(context, item.info, _toast),
                                          onDownload: () => downloadFile(context, item.info, _toast),
                                          onDownloadAndOpen: () => downloadAndOpenFile(context, item.info, _toast),
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
