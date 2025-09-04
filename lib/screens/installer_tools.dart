import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';

class InstallerToolsScreen extends StatelessWidget {
  const InstallerToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const toolsColor = Color(0xFFF4BE25);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white.withOpacity(0.4), const Color(0xFF333333).withOpacity(0.6)],
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/diagonalpatternbg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: gradient))),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text('Installer Tools', style: GoogleFonts.raleway()),
                  backgroundColor: const Color(0xFF333333),
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _BigButton(
                        text: 'Floor Build-up Diagrams',
                        color: toolsColor,
                        icon: Icons.layers,
                        onTap: () => Navigator.pushNamed(context, Routes.floorDiagrams),
                      ),
                      const SizedBox(height: 24),
                      _BigButton(
                        text: 'Cable Spacing Calculator',
                        color: const Color(0xFFEFA528),
                        icon: Icons.calculate_outlined,
                        onTap: () => Navigator.pushNamed(context, Routes.cableSpacingCalculator), // placeholder
                      ),
                      const SizedBox(height: 24),
                      _BigButton(
                        text: 'Thermostat Apps',
                        color: const Color(0xFFE26A2D),
                        icon: Icons.phone_android,
                        onTap: () => Navigator.pushNamed(context, Routes.thermostatApps), // placeholder
                      ),
                      const SizedBox(height: 24),
                      _BigButton(
                        text: 'Installation Checklist',
                        color: const Color(0xFFD94A2C),
                        icon: Icons.playlist_add_check_outlined,
                        onTap: () => Navigator.pushNamed(context, Routes.installationChecklistHub), // placeholder
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
  const _BigButton({required this.text, required this.color, required this.icon, required this.onTap});

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 56, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(text, style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
