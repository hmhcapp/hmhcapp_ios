import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// =======================
/// Data Models
/// =======================

class PdfInfo {
  final String name;
  final String url; // can be gs:// or https
  const PdfInfo(this.name, this.url);
}

abstract class ContentItem {
  const ContentItem();
}

class ContentItemSubCategory extends ContentItem {
  final String title;
  final List<PdfInfo> pdfs;
  const ContentItemSubCategory(this.title, this.pdfs);
}

class ContentItemPdf extends ContentItem {
  final PdfInfo info;
  const ContentItemPdf(this.info);
}

class CategoryData {
  final String title;
  final List<ContentItem> items;
  const CategoryData(this.title, this.items);
}

/// =======================
/// Data (exported)
/// =======================

const List<CategoryData> underfloorHeatingFactsheets = [
  CategoryData("Heating Mats", [
    ContentItemSubCategory("Heat Mat Pro", [
      // PdfInfo("PKM-065 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-065W-heating-mat-factsheet.pdf"),
      PdfInfo("PKM-110 factsheet",
          "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-110W-heating-mat-factsheet.pdf"),
      PdfInfo("PKM-160 factsheet",
          "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-160W-heating-mat-factsheet.pdf"),
      PdfInfo("PKM-200 factsheet",
          "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-200W-heating-mat-factsheet.pdf"),
      PdfInfo("PKM-240 factsheet",
          "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-240W-heating-mat-factsheet.pdf"),
    ]),
    ContentItemSubCategory("Heat My Home", [
      PdfInfo("HMH160W factsheet",
          "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/HMHMAT/Heat-My-Home-HMHMAT-factsheet.pdf"),
    ]),
  ]),
  CategoryData("Heating Cables", [
    ContentItemSubCategory("Heat Mat Pro", [
      PdfInfo("PKC-3.0 factsheet",
          "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKC/Heat-Mat-PKC-3mm-cable-factsheet.pdf"),
      PdfInfo("PKC-5.0 factsheet",
          "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKC/Heat-Mat-PKC-5mm-cable-factsheet.pdf"),
    ]),
    ContentItemSubCategory("Heat My Home", [
      PdfInfo("HMHCAB factsheet",
          "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/HMHCAB/Heat-My-Home-HMHCAB-factsheet.pdf"),
    ]),
  ]),
  CategoryData("Combymat/Foil Heating", [
    ContentItemPdf(PdfInfo("CBM-150 factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/CBM/Heat-Mat-CBM-Combymat-factsheet.pdf")),
    ContentItemPdf(PdfInfo("CBM-OVE factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/CBM/Heat-Mat-CBM-Combymat-overlay-boards-factsheet.pdf")),
  ]),
  CategoryData("Thermostats", [
    ContentItemPdf(PdfInfo("HMT5 factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/HMT5/Heat-Mat-HMT5-thermostat-factsheet.pdf")),
    ContentItemPdf(PdfInfo("HMH200 factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/HMH200/Heat-My-Home-HMH200-Wifi-Thermostat-Factsheet.pdf")),
    ContentItemPdf(PdfInfo("HMH100 factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/HMH100/Heat-My-Home-HMH100-Wifi-Thermostat-Factsheet.pdf")),
    ContentItemPdf(PdfInfo("NGTouch factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/NGT/Heat-Mat-NGTouch-thermostat-factsheet.pdf")),
    ContentItemPdf(PdfInfo("NGTWifi factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/NGTWIFI/Heat-Mat-NGTouch-wifi-thermostat-factsheet.pdf")),
    ContentItemPdf(PdfInfo("TPS32 factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/TPS/Heat-Mat-TPS31-thermostat-factsheet.pdf")),
  ]),
  CategoryData("Insulation Boards", [
    ContentItemPdf(PdfInfo("TTB Insulation factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/TTB/Heat-Mat-TTB-insulation-board-factsheet.pdf")),
  ]),
];

const List<CategoryData> frostProtectionFactsheets = [
  CategoryData("Trace Heating", [
    ContentItemPdf(PdfInfo("Trace Heating Cable factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/Trace-Heating-Factsheet.pdf")),
  ]),
  CategoryData("Pipe Protection", [
    ContentItemPdf(PdfInfo("PipeGuard factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/PipeGuard_Factsheet.pdf")),
  ]),
  CategoryData("Gutter & Roof Heating", [
    ContentItemPdf(PdfInfo("Gutter and Roof Heating Cable factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/Roof-and-gutter-heating-factsheet.pdf")),
  ]),
  CategoryData("Driveway & Ramp Heating", [
    ContentItemPdf(PdfInfo("Driveway Heating Cable factsheet",
        "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/Heat-Mat-50W-Snow-Melting-Cable-Factsheet.pdf")),
  ]),
];

/// =======================
/// Screen
/// =======================

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
  final Set<String> expanded = {};

  @override
  Widget build(BuildContext context) {
    final filtered = _filterData(widget.factsheetData, searchQuery);

    return Scaffold(
      backgroundColor: widget.appBarColor,
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        elevation: 0,
        title: Text(widget.categoryTitle, style: GoogleFonts.raleway(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.description, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search on colored area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _SearchField(
              value: searchQuery,
              onChanged: (v) {
                setState(() {
                  searchQuery = v;
                  if (v.isNotEmpty) {
                    // expand all categories that have matches
                    expanded
                      ..clear()
                      ..addAll(filtered.map((e) => e.title));
                  }
                });
              },
              onClear: () => setState(() => searchQuery = ''),
            ),
          ),
          // White rounded surface with the content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: filtered.isEmpty && searchQuery.isNotEmpty
                  ? Center(
                      child: Text('No results found.', style: GoogleFonts.raleway(color: Colors.grey)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final cat = filtered[i];
                        final isOpen = expanded.contains(cat.title);
                        return _CategorySection(
                          title: cat.title,
                          expanded: isOpen,
                          onToggle: () {
                            setState(() {
                              if (isOpen) {
                                expanded.remove(cat.title);
                              } else {
                                expanded.add(cat.title);
                              }
                            });
                          },
                          child: Column(
                            children: cat.items.map((item) {
                              if (item is ContentItemSubCategory) {
                                return _SubcategoryBlock(title: item.title, pdfs: item.pdfs);
                              } else if (item is ContentItemPdf) {
                                return _PdfRow(info: item.info);
                              }
                              return const SizedBox.shrink();
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<CategoryData> _filterData(List<CategoryData> data, String query) {
    if (query.trim().isEmpty) return data;
    final q = query.toLowerCase();

    return data.map((cat) {
      final catTitleMatch = cat.title.toLowerCase().contains(q);

      final filteredItems = <ContentItem>[];
      for (final item in cat.items) {
        if (item is ContentItemSubCategory) {
          final subMatch = item.title.toLowerCase().contains(q);
          final pdfs = item.pdfs.where((p) => p.name.toLowerCase().contains(q)).toList();
          if (subMatch || pdfs.isNotEmpty) {
            filteredItems.add(ContentItemSubCategory(item.title, subMatch ? item.pdfs : pdfs));
          }
        } else if (item is ContentItemPdf) {
          if (item.info.name.toLowerCase().contains(q)) {
            filteredItems.add(item);
          }
        }
      }

      if (catTitleMatch || filteredItems.isNotEmpty) {
        return CategoryData(cat.title, catTitleMatch ? cat.items : filteredItems);
      }
      return null;
    }).whereType<CategoryData>().toList();
  }
}

/// =======================
/// Widgets
/// =======================

class _SearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.value,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      style: GoogleFonts.raleway(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Search factsheets (e.g. PKM-160, Thermostats...)',
        hintStyle: GoogleFonts.raleway(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        suffixIcon: value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _CategorySection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.raleway(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: child,
            ),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _SubcategoryBlock extends StatelessWidget {
  final String title;
  final List<PdfInfo> pdfs;
  const _SubcategoryBlock({required this.title, required this.pdfs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.raleway(
                color: const Color(0xFFf85c37),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 6),
          ...pdfs.map((p) => _PdfRow(info: p)).toList(),
        ],
      ),
    );
  }
}

class _PdfRow extends StatelessWidget {
  final PdfInfo info;
  const _PdfRow({required this.info});

  Future<String> _resolveUrl(String url) async {
    if (url.startsWith('gs://')) {
      final ref = FirebaseStorage.instance.refFromURL(url);
      return await ref.getDownloadURL();
    }
    return url;
  }

  Future<void> _openPdf(BuildContext context) async {
    try {
      final httpsUrl = await _resolveUrl(info.url);
      final uri = Uri.parse(httpsUrl);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        throw 'Could not launch URL';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening ${info.name}: $e')),
      );
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final httpsUrl = await _resolveUrl(info.url);
      await Share.shareUri(Uri.parse(httpsUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing ${info.name}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(info.name, style: GoogleFonts.raleway(fontSize: 15)),
      leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
      trailing: Wrap(
        spacing: 8,
        children: [
          IconButton(
            tooltip: 'Open',
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _openPdf(context),
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(context),
          ),
        ],
      ),
      onTap: () => _openPdf(context),
    );
  }
}
