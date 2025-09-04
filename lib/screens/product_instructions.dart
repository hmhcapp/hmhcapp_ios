import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'product_factsheets.dart'
    show
        PdfInfo,
        ContentItem,
        SubCategoryItem,
        PdfItem,
        CategoryData,
        Category,
        SubCategory,
        PdfLink,
        shareFile,
        downloadFile,
        downloadAndOpenFile;

/// -------------------- INSTRUCTIONS DATA --------------------

final List<CategoryData> underfloorHeatingInstructionsData = [
  CategoryData("Heating Mats", [
    SubCategoryItem("Heat Mat Pro", [
      PdfInfo("PKM heating mat Instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/PKM/Heat-Mat-PKM-heating-mat-instructions.pdf"),
    ]),
    SubCategoryItem("Heat My Home", [
      PdfInfo("HMH heating mat instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/HMHMAT/Heat-My-Home-HMHMAT-instructions.pdf"),
    ]),
  ]),
  CategoryData("Heating Cables", [
    SubCategoryItem("Heat Mat Pro", [
      PdfInfo("PKC-3.0 instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/PKC/Heat-Mat-PKC-3mm-cable-instructions.pdf"),
      PdfInfo("PKC-5.0 instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/PKC/Heat-Mat-PKC-5mm-cable-instructions.pdf"),
    ]),
    SubCategoryItem("Heat My Home", [
      PdfInfo("HMH heating cable instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/HMHCAB/Heat-My-Home-HMHCAB-instructions.pdf"),
    ]),
  ]),
  CategoryData("Combymat/Foil Heating", [
    PdfItem(PdfInfo("CBM Combymat instructions",
        "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/CBM/Heat-Mat-CBM-Combymat-instructions.pdf")),
  ]),
  CategoryData("Thermostats", [
    SubCategoryItem("HMT5", [
      PdfInfo("HMT5 instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/THERMOSTATS/HMT5/Heat-Mat-HMT5-thermostat-instructions.pdf"),
    ]),
    SubCategoryItem("HMH200", [
      PdfInfo("HMH200 instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/THERMOSTATS/HMH200/Heat-My-Home-HMH200-instructions.pdf"),
    ]),
    SubCategoryItem("HMH100", [
      PdfInfo("HMH100 instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/THERMOSTATS/HMH100/Heat-My-Home-HMH100-instructions.pdf"),
    ]),
    SubCategoryItem("NGTouch", [
      PdfInfo("NGT user manual",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/THERMOSTATS/NGT/Heat-Mat-NGTouch-thermostat-user-manual.pdf"),
      PdfInfo("NGT install instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/THERMOSTATS/NGT/Heat-Mat-NGTouch-thermostat-instructions.pdf"),
      PdfInfo("NGT quick start guide",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/THERMOSTATS/NGT/Heat-Mat-NGTouch-thermostat-quick-start-guide.pdf"),
    ]),
    SubCategoryItem("NGT WiFi", [
      PdfInfo("NGT WiFI install instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/THERMOSTATS/NGTWIFI/Heat-Mat-NGTouch-3-0-wifi-thermostat-instructions.pdf"),
      PdfInfo("NGT WiFI user manual",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/THERMOSTATS/NGTWIFI/Heat-Mat-NGTouch-3-0-wifi-thermostat-user-manual.pdf"),
    ]),
    SubCategoryItem("TPS32", [
      PdfInfo("TPS32 user manual",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/THERMOSTATS/TPS/Heat-Mat-TPS32-thermostat-user-manual.pdf"),
    ]),
  ]),
];

final List<CategoryData> frostProtectionInstructionsData = [
  CategoryData("Pipe Protection Cables", [
    PdfItem(PdfInfo("PipeGuard instructions",
        "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/PipeGuard-instructions.pdf")),
    PdfItem(PdfInfo("Trace Heating instructions",
        "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/Trace Cable Installation Guide.pdf")),
  ]),
  CategoryData("Gutter & Roof Heating", [
    PdfItem(PdfInfo("Roof Heating generic instructions",
        "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/Heat-Mat-Ice-and-Snow-Systems-Roof-Heating-Installation-Instructions-Generic.pdf")),
  ]),
  CategoryData("Driveway & Ramp Heating", [
    PdfItem(PdfInfo("50W Driveway heating cable instructions",
        "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/Driveway-Heating-Cable-Instructions.pdf")),
  ]),
  CategoryData("Controllers & Sensors", [
    SubCategoryItem("Controllers/Thermostats", [
      PdfInfo("FRO-10A-STAT thermostat instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/FRO-10A-STAT-Instructions.pdf"),
      PdfInfo("FRO-16A-STAT thermostat instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/FRO-16A-STAT-Instructions.pdf"),
      PdfInfo("FRO-48A-STAT thermostat instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/FRO-48A-STAT-Instructions.pdf"),
      PdfInfo("TRA-20A-STAT thermostat instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/TRA-20A-STAT-Instructions.pdf"),
    ]),
    SubCategoryItem("Sensors", [
      PdfInfo("FRO-GRO-SENS ground sensor instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/FRO-GRO-SENS-Instructions.pdf"),
      PdfInfo("FRO-GRO-TEMP ground/pipe sensor instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/FRO-GRO-TEMP-instructions.pdf"),
      PdfInfo("FRO-TEM-SENS air sensor instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/FRO-TEM-SENS-instructions.pdf"),
      PdfInfo("FRO-GUT-SENS gutter moisture sensor instructions",
          "gs://hm-hc-app.firebasestorage.app/INSTRUCTIONS/ICEANDSNOW/FRO-GUT-SENS-instructions.pdf"),
    ]),
  ]),
];

/// -------------------- SCREEN --------------------

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
              hint: 'Search Instructions (e.g., NGT WiFi, Heating Cables...)',
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
