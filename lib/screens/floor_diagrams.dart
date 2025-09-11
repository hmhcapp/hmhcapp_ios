import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  HeatingSystemCategory(
    "Heating Mats",
    [
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
    ],
  ),
  HeatingSystemCategory(
    "Heating Cable with Decoupling Membrane",
    [
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
    ],
  ),
  HeatingSystemCategory(
    "Combymat Foil Heating",
    [
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
    ],
  ),
  HeatingSystemCategory(
    "In-screed Cable",
    [
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
    ],
  ),
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
      backgroundColor: appBarColor,
      appBar: AppBar(
        title: Text('Floor Build-up Diagrams', style: GoogleFonts.raleway(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.layers, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SearchField(
              value: search,
              hint: 'Search Diagrams (e.g., timber, tiled, laminate...)',
              onChanged: (v) => setState(() => search = v),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Text('No results found.', style: GoogleFonts.raleway(color: Colors.grey)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
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
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<HeatingSystemCategory> _filter(List<HeatingSystemCategory> data, String q) {
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
        return terms.any((t) =>
            b.title.toLowerCase().contains(t) ||
            b.description.toLowerCase().contains(t));
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
    barrierColor: Colors.white.withOpacity(1), // frosted barrier
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,      // no black background
        insetPadding: const EdgeInsets.all(0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Frosted white layer inside the dialog
              Positioned.fill(
                child: Container(color: Colors.white.withOpacity(1)),
              ),

              // Zoom/pan viewer
              InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Image.network(
                    b.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Back button
Positioned(
  top: MediaQuery.of(context).padding.top + 8, // below status bar
  left: 20,
  child: Material(
    color: Colors.black.withOpacity(0.6),
    shape: const CircleBorder(),
    clipBehavior: Clip.antiAlias,
    child: IconButton(
      tooltip: 'Back',
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
  const _SearchField({required this.value, required this.hint, required this.onChanged});

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

class _ExpandableCategoryCard extends StatelessWidget {
  final HeatingSystemCategory category;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(FloorBuildUp) onOpenImage;
  final void Function(FloorBuildUp) onShare;
  final void Function(FloorBuildUp) onDownload;

  const _ExpandableCategoryCard({
    required this.category,
    required this.expanded,
    required this.onToggle,
    required this.onOpenImage,
    required this.onShare,
    required this.onDownload,
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
          ListTile(
            title: Text(
              category.name,
              style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onTap: onToggle,
          ),
          if (expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < category.floorBuildUps.length; i++) ...[
                    _BuildUpTile(
                      buildUp: category.floorBuildUps[i],
                      onOpenImage: () => onOpenImage(category.floorBuildUps[i]),
                      onShare: () => onShare(category.floorBuildUps[i]),
                      onDownload: () => onDownload(category.floorBuildUps[i]),
                    ),
                    if (i < category.floorBuildUps.length - 1)
                      const Divider(height: 30),
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

  const _BuildUpTile({
    required this.buildUp,
    required this.onOpenImage,
    required this.onShare,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(buildUp.title, style: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w400)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onOpenImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              AspectRatio(
                aspectRatio: 2400 / 2000, // keep a decent display ratio, most images are 2400x2000
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    image: DecorationImage(
                      image: NetworkImage(buildUp.imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.zoom_out_map, color: Colors.white, size: 18),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(buildUp.description, style: GoogleFonts.raleway(color: Colors.black54, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              label: Text('Share', style: GoogleFonts.raleway()),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download),
              label: Text('Download', style: GoogleFonts.raleway()),
            ),
          ],
        ),
      ],
    );
  }
}
