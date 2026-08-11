import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';
import '../widgets/accent_navigation_card.dart';
import '../widgets/atmospheric_dark_background.dart';

// A simple data class to hold button information
class _CategoryInfo {
  final String text;
  final String description;
  final Color color;
  final IconData icon;
  final String? svgAsset;
  final String route;

  const _CategoryInfo({
    required this.text,
    required this.description,
    required this.color,
    required this.icon,
    this.svgAsset,
    required this.route,
  });
}

class ProductCategorySelectionScreen extends StatelessWidget {
  const ProductCategorySelectionScreen({super.key});

  // Store button data in a list for easier management
  static const _categories = <_CategoryInfo>[
    _CategoryInfo(
      text: 'Underfloor Heating Products',
      description: 'Technical data for underfloor heating systems.',
      color: Color(0xFFDD4F2E),
      icon: Icons.waves_rounded,
      svgAsset: 'assets/images/nest_true_radiant.svg',
      route: Routes.underfloorHeatingFactsheetsRoute,
    ),
    _CategoryInfo(
      text: 'Frost Protection Products',
      description: 'Technical data for frost protection systems.',
      color: Color(0xFF009ADC),
      icon: Icons.ac_unit,
      route: Routes.frostProtectionFactsheetsRoute,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 16.0;
    const gridSpacing = 14.0;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: const Color(0xFF101111),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFFDD4F2E),
            size: 30,
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Product Category',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontSize: 23,
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
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: AtmosphericDarkBackground(
        accentColor: const Color(0xFFDD4F2E),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            24,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridSpacing,
            mainAxisExtent: 174,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return AccentNavigationCard(
              title: category.text,
              description: category.description,
              accentColor: category.color,
              icon: category.icon,
              svgAsset: category.svgAsset,
              onTap: () => Navigator.pushNamed(context, category.route),
            );
          },
        ),
      ),
    );
  }
}
