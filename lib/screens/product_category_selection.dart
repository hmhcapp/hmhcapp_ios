import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';

class ProductCategorySelectionScreen extends StatelessWidget {
  const ProductCategorySelectionScreen({super.key});

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
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/diagonalpatternbg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(gradient: gradient),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    'Select Product Category',
                    style: GoogleFonts.raleway(),
                  ),
                  backgroundColor: const Color(0xFF333333),
                  leading: const BackButton(color: Colors.white),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _BigButton(
                        text: 'Underfloor Heating Products',
                        color: const Color(0xFFDD4F2E),
                        icon: Icons.thermostat,
                        routeName: Routes.underfloorHeatingFactsheetsRoute,
                      ),
                      const SizedBox(height: 24),
                      _BigButton(
                        text: 'Frost Protection Products',
                        color: const Color(0xFF009ADC),
                        icon: Icons.ac_unit,
                        routeName: Routes.frostProtectionFactsheetsRoute,
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
  final String routeName;

  const _BigButton({
    required this.text,
    required this.color,
    required this.icon,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, routeName),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // solid colour
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 56, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
