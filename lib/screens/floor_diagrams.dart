//lib/screens/floor_diagrams.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/classic_share_icon.dart';
import '../widgets/atmospheric_dark_background.dart';

/// --- DATA MODELS ---

class FloorBuildUp {
  final int id;
  final String title;
  final String imageUrl;
  final String description;
  const FloorBuildUp(this.id, this.title, this.imageUrl, this.description);
}

class HeatingSystemCategory {
  final String name;
  final List<FloorBuildUp> floorBuildUps;
  const HeatingSystemCategory(this.name, this.floorBuildUps);
}

/// --- DATA (mirrors your Kotlin data) ---

const List<HeatingSystemCategory> allHeatingSystems = [
  HeatingSystemCategory("Heating Mats", [
    FloorBuildUp(
      1,
      "Heating Mat All Wattages – Insulation on Concrete – Tiled Finish",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Heating-Mat-All-Wattages-Insulation-on-Concrete-Tiled-Finish-2400-x-2000.jpg",
      "Diagram showing heating mat installation over insulated concrete subfloors with a tiled finish.",
    ),
    FloorBuildUp(
      2,
      "Heating Mat All Wattages – Insulation on Timber – Tiled Finish",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Heating-Mat-All-Wattages-Insulation-on-Timber-Tiled-Finish-2400-x-2000.jpg",
      "Diagram showing heating mat installation over insulated timber subfloors with a tiled finish.",
    ),
    FloorBuildUp(
      3,
      "Heating Mat 160W and Levelling Compound – Insulation on Timber – LVT Flooring Finish",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Heating-Mat-160W-and-Levelling-Compound-Insulation-on-Timber-LVT-Flooring-Finish-2400-x-2000.jpg",
      "Diagram for installing a 160W heating mat and levelling compound for a final LVT floor finish.",
    ),
    FloorBuildUp(
      4,
      "Heating Mat 160W and Levelling Compound – Insulation on Timber – Floating Laminate",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Heating-Mat-160W-and-Levelling-Compound-Insulation-on-Timber-Floating-Laminate-Finish-2400-x-2000.jpg",
      "Diagram for installing a 160W heating mat and levelling compound for a floating laminate floor.",
    ),
    FloorBuildUp(
      5,
      "Heating Mat 160W and Levelling Compound – Insulation on Timber – Engineered Wood",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Heating-Mat-160W-and-Levelling-Compound-Insulation-on-Timber-Engineered-Wood-Finish-2400-x-2000.jpg",
      "Diagram for installing a 160W heating mat and levelling compound for an engineered wood floor.",
    ),
    FloorBuildUp(
      6,
      "Heating Mat 160W and Levelling Compound – Insulation on Timber – Carpet Finish",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Heating-Mat-160W-and-Levelling-Compound-Insulation-on-Timber-Carpet-Finish-2400-x-2000.jpg",
      "Diagram for installing a 160W heating mat and levelling compound for a carpeted floor finish.",
    ),
    FloorBuildUp(
      7,
      "Heating Mat 160W and Levelling Compound – Insulation on Timber – Any Floor Finish",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Heating-Mat-160W-and-Levelling-Compound-Insulation-on-Timber-Any-Floor-Finish-2400-x-2000.jpg",
      "A versatile build-up using a 160W heating mat suitable for multiple floor finishes.",
    ),
  ]),
  HeatingSystemCategory("Heating Cable with Decoupling Membrane", [
    FloorBuildUp(
      8,
      "Heating Cable and Decoupling Membrane – Insulation on Timber – Tiled Finish",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Heating-Cable-and-Decoupling-Membrane-Insulation-on-Timber-Tiled-Finish-2400-x-2000.jpg",
      "Diagram showing a heating cable and decoupling membrane system over insulated timber for a tiled floor.",
    ),
    FloorBuildUp(
      9,
      "Heating Cable and Decoupling Membrane – Insulation on Timber – Any Floor Finish",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Heating-Cable-and-Decoupling-Membrane-Insulation-on-Timber-Any-Floor-Finish-2400-x-2000.jpg",
      "A versatile build-up using a heating cable and decoupling membrane for any floor finish.",
    ),
  ]),
  HeatingSystemCategory("Combymat Foil Heating", [
    FloorBuildUp(
      10,
      "Combymat and Overlay Boards – Carpet",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Combymat-and-Overlay-Boards-Carpet-Finish-2400-x-2000.jpg",
      "Diagram illustrating the use of Combymat with overlay boards for a carpeted floor finish.",
    ),
    FloorBuildUp(
      11,
      "Combymat and Overlay Boards – LVT Flooring Finish",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Combymat-and-Overlay-Boards-LVT-Flooring-Finish-2400-x-2000.jpg",
      "Diagram illustrating the use of Combymat with overlay boards for an LVT floor finish.",
    ),
    FloorBuildUp(
      12,
      "Combymat – Floating Laminate",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/Combymat-Floating-Laminate-Finish-2400-x-2000.jpg",
      "Diagram showing Combymat installation directly beneath a floating laminate floor.",
    ),
  ]),
  HeatingSystemCategory("In-screed Cable", [
    FloorBuildUp(
      13,
      "In-screed Cable and Reinforcement Fabric – Any Floor Finish",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/In-screed-Cable-and-Reinforcement-Fabric-Any-Floor-Finish-2400-x-2000.jpg",
      "Diagram for installing in-screed heating cable with reinforcement fabric, suitable for any floor finish.",
    ),
    FloorBuildUp(
      14,
      "In-screed Cable and Fixing Strips – Any Floor Finish",
      "https://www.heatmat.co.uk/wp-content/uploads/2025/02/In-screed-Cable-and-Fixing-Strips-Any-Floor-Finish-2400-x-2000.jpg",
      "Diagram for installing in-screed heating cable using fixing strips, suitable for any floor finish.",
    ),
  ]),
];

/// --- SCREEN ---

class FloorDiagramsScreen extends StatefulWidget {
  const FloorDiagramsScreen({super.key});

  @override
  State<FloorDiagramsScreen> createState() => _FloorDiagramsScreenState();
}

class _FloorDiagramsScreenState extends State<FloorDiagramsScreen> {
  final Color appBarColor = const Color(0xFFF4BE25);

  String search = '';
  Set<String> expanded = {};

  @override
  Widget build(BuildContext context) {
    final filtered = _filter(allHeatingSystems, search);

    if (search.isNotEmpty) {
      expanded = filtered.map((e) => e.name).toSet();
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
          icon: Icon(Icons.arrow_back_rounded, color: appBarColor, size: 30),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Floor Build-up Diagrams',
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Explore recommended floor constructions',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.raleway(
                color: const Color(0xFFB7B7B7),
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(Icons.layers, color: appBarColor, size: 27),
          ),
        ],
      ),
      body: AtmosphericDarkBackground(
        accentColor: appBarColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _SearchField(
                value: search,
                hint: 'Search diagrams (e.g. timber, tiled, laminate)',
                accentColor: appBarColor,
                onChanged: (v) => setState(() => search = v),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No results found.',
                        style: GoogleFonts.raleway(
                          color: const Color(0xFFB7B7B7),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final cat = filtered[i];
                        final isOpen = expanded.contains(cat.name);
                        return _ExpandableCategoryCard(
                          category: cat,
                          expanded: isOpen,
                          onToggle: () {
                            setState(() {
                              if (isOpen) {
                                expanded.remove(cat.name);
                              } else {
                                expanded.add(cat.name);
                              }
                            });
                          },
                          onOpenImage: _openViewer,
                          onShare: _share,
                          onDownload: _download,
                          accentColor: appBarColor,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<HeatingSystemCategory> _filter(
    List<HeatingSystemCategory> data,
    String q,
  ) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return data;

    // Synonym groups
    final groups = [
      {'laminate', 'engineered wood', 'wood'},
      {'tiles', 'tiled'},
      {'timber', 'floorboards', 'floor boards'},
      {'levelling compound', 'screed', 'latex'},
      {'lvt', 'karndean', 'vinyl', 'lino', 'amtico'},
    ];

    final terms = <String>{query};
    for (final g in groups) {
      if (g.contains(query)) terms.addAll(g);
    }

    final out = <HeatingSystemCategory>[];
    for (final cat in data) {
      final catMatch = terms.any((t) => cat.name.toLowerCase().contains(t));
      final items = cat.floorBuildUps.where((b) {
        return terms.any(
          (t) =>
              b.title.toLowerCase().contains(t) ||
              b.description.toLowerCase().contains(t),
        );
      }).toList();

      if (catMatch) {
        out.add(cat);
      } else if (items.isNotEmpty) {
        out.add(HeatingSystemCategory(cat.name, items));
      }
    }
    return out;
  }

  void _openViewer(FloorBuildUp b) {
    showDialog(
      context: context,
      barrierColor: Colors.white.withValues(alpha: 1), // frosted barrier
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent, // no black background
          insetPadding: const EdgeInsets.all(0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Frosted white layer inside the dialog
                Positioned.fill(
                  child: Container(color: Colors.white.withValues(alpha: 1)),
                ),

                // Zoom/pan viewer
                InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: Image.network(b.imageUrl, fit: BoxFit.contain),
                  ),
                ),

                // Back button
                Positioned(
                  top:
                      MediaQuery.of(context).padding.top +
                      8, // below status bar
                  left: 20,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _share(FloorBuildUp b) async {
    await Share.share(
      'Check out this diagram: ${b.title}\n${b.imageUrl}',
      subject: 'Floor Diagram: ${b.title}',
    );
  }

  Future<void> _download(FloorBuildUp b) async {
    final uri = Uri.tryParse(b.imageUrl);
    if (uri != null) {
      // Let the browser/OS handle the download
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening download for "${b.title}"')),
      );
    }
  }
}

/// --- WIDGETS ---

class _SearchField extends StatelessWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;
  final Color accentColor;
  const _SearchField({
    required this.value,
    required this.hint,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      cursorColor: accentColor,
      style: GoogleFonts.raleway(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.raleway(
          color: const Color(0xFF8F8F8F),
          fontSize: 13.5,
        ),
        prefixIcon: Icon(Icons.search_rounded, color: accentColor),
        suffixIcon: value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Color(0xFFB7B7B7)),
                onPressed: () => onChanged(''),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          borderRadius: BorderRadius.circular(13),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentColor),
          borderRadius: BorderRadius.circular(13),
        ),
        filled: true,
        fillColor: const Color(0xFF1C1D1D),
      ),
    );
  }
}

class _ExpandableCategoryCard extends StatelessWidget {
  final HeatingSystemCategory category;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(FloorBuildUp) onOpenImage;
  final void Function(FloorBuildUp) onShare;
  final void Function(FloorBuildUp) onDownload;
  final Color accentColor;

  const _ExpandableCategoryCard({
    required this.category,
    required this.expanded,
    required this.onToggle,
    required this.onOpenImage,
    required this.onShare,
    required this.onDownload,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF161717), Color(0xFF242525)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.70),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFD67C17), accentColor],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.layers, color: Colors.white, size: 25),
            ),
            title: Text(
              category.name,
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: accentColor,
              size: 28,
            ),
            onTap: onToggle,
          ),
          if (expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111212),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(13),
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                ),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < category.floorBuildUps.length; i++) ...[
                    _BuildUpTile(
                      buildUp: category.floorBuildUps[i],
                      onOpenImage: () => onOpenImage(category.floorBuildUps[i]),
                      onShare: () => onShare(category.floorBuildUps[i]),
                      onDownload: () => onDownload(category.floorBuildUps[i]),
                      accentColor: accentColor,
                    ),
                    if (i < category.floorBuildUps.length - 1)
                      Divider(
                        height: 24,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BuildUpTile extends StatelessWidget {
  final FloorBuildUp buildUp;
  final VoidCallback onOpenImage;
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final Color accentColor;

  const _BuildUpTile({
    required this.buildUp,
    required this.onOpenImage,
    required this.onShare,
    required this.onDownload,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF161717), Color(0xFF202121)],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            buildUp.title,
            style: GoogleFonts.raleway(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onOpenImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                AspectRatio(
                  aspectRatio:
                      2400 /
                      2000, // keep a decent display ratio, most images are 2400x2000
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ColoredBox(
                      color: Colors.white,
                      child: Image.network(
                        buildUp.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: const Color(0xFF252626),
                          child: Center(
                            child: Icon(
                              Icons.layers_outlined,
                              color: accentColor,
                              size: 42,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.zoom_out_map,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            buildUp.description,
            style: GoogleFonts.raleway(
              color: const Color(0xFFB7B7B7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 2,
            children: [
              TextButton.icon(
                onPressed: onShare,
                icon: ClassicShareIcon(color: accentColor),
                label: Text(
                  'Share',
                  style: GoogleFonts.raleway(color: accentColor),
                ),
              ),
              TextButton.icon(
                onPressed: onDownload,
                icon: Icon(Icons.download, color: accentColor),
                label: Text(
                  'Download',
                  style: GoogleFonts.raleway(color: accentColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
