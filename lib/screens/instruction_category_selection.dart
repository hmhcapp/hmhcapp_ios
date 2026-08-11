import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';
import '../widgets/accent_navigation_card.dart';
import '../widgets/atmospheric_dark_background.dart';

// A simple data class to hold button information
class _InstructionInfo {
  final String text;
  final String description;
  final Color color;
  final IconData icon;
  final String route;

  const _InstructionInfo({
    required this.text,
    required this.description,
    required this.color,
    required this.icon,
    required this.route,
  });
}

class InstructionCategorySelectionScreen extends StatelessWidget {
  const InstructionCategorySelectionScreen({super.key});

  // Store button data in a list for easier management
  static const _instructions = <_InstructionInfo>[
    _InstructionInfo(
      text: 'Underfloor Heating Instructions',
      description: 'Installation guidance for underfloor heating systems.',
      color: Color(0xFFE26A2D),
      icon: Icons.menu_book_outlined,
      route: Routes.underfloorHeatingInstructionsRoute,
    ),
    _InstructionInfo(
      text: 'Frost Protection Instructions',
      description: 'Installation guidance for frost protection systems.',
      color: Color(0xFF009ADC),
      icon: Icons.ac_unit,
      route: Routes.frostProtectionInstructionsRoute,
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
            color: Color(0xFFE26A2D),
            size: 30,
          ),
        ),
        titleSpacing: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Instruction Category',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Installation guides and product instructions',
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
        accentColor: const Color(0xFFE26A2D),
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
          itemCount: _instructions.length,
          itemBuilder: (context, index) {
            final instruction = _instructions[index];
            return AccentNavigationCard(
              title: instruction.text,
              description: instruction.description,
              accentColor: instruction.color,
              icon: instruction.icon,
              onTap: () => Navigator.pushNamed(context, instruction.route),
            );
          },
        ),
      ),
    );
  }
}
