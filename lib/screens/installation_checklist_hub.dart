import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';
import '../widgets/atmospheric_dark_background.dart';
import '../widgets/accent_navigation_card.dart';

// Data class for the button information
class _ChecklistInfo {
  final String text;
  final String description;
  final Color color;
  final IconData icon;
  final String route;

  const _ChecklistInfo({
    required this.text,
    required this.description,
    required this.color,
    required this.icon,
    required this.route,
  });
}

class InstallationChecklistHubScreen extends StatelessWidget {
  const InstallationChecklistHubScreen({super.key});

  // Store button data in a list
  static const _checklists = <_ChecklistInfo>[
    _ChecklistInfo(
      text: 'Heating Mats',
      description: 'Step-by-step checks for heating mat installations.',
      color: Color(0xFFF4BE25),
      icon: Icons.space_dashboard,
      route: Routes.heatingMatChecklist,
    ),
    _ChecklistInfo(
      text: 'Heating Cables',
      description: 'Step-by-step checks for heating cable installations.',
      color: Color(0xFFEFA528),
      icon: Icons.route,
      route: Routes.heatingCableChecklist,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Installation Checklist',
          style: GoogleFonts.raleway(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF202020),
        leading: const BackButton(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: AtmosphericDarkBackground(
        accentColor: Color(0xFFE9882A),
        child: SafeArea(
          top: false,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            itemCount: _checklists.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 174,
            ),
            itemBuilder: (context, index) {
              final checklist = _checklists[index];
              return AccentNavigationCard(
                title: checklist.text,
                description: checklist.description,
                accentColor: checklist.color,
                icon: checklist.icon,
                onTap: () => Navigator.pushNamed(context, checklist.route),
              );
            },
          ),
        ),
      ),
    );
  }
}
