import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';

class InstallationChecklistHubScreen extends StatelessWidget {
  const InstallationChecklistHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.4),
        const Color(0xFF333333).withOpacity(0.6),
      ],
    );

    return Scaffold(
      // ✅ AppBar now in Scaffold so the black bar goes to the very top
      appBar: AppBar(
        title: Text(
          'Installation Checklist',
          style: GoogleFonts.raleway(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF333333),
        leading: const BackButton(color: Colors.white),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/diagonalpatternbg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(decoration: BoxDecoration(gradient: gradient)),
          ),

          // Content below the app bar
          SafeArea(
            top: false, // App bar already handles the top area
            child: Column(
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _BigButton(
                        text: 'Heating Mats',
                        color: const Color(0xFFF4BE25),
                        icon: Icons.space_dashboard,
                        onTap: () => Navigator.pushNamed(context, Routes.heatingMatChecklist),
                      ),
                      const SizedBox(height: 24),
                      _BigButton(
                        text: 'Heating Cables',
                        color: const Color(0xFFEFA528),
                        icon: Icons.route,
                        onTap: () => Navigator.pushNamed(context, Routes.heatingCableChecklist),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _BigButton({
    required this.text,
    required this.color,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 56, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
