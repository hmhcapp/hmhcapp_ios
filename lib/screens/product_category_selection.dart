import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // AppBar at the very top (status bar remains visible)
      appBar: AppBar(
        title: Text('Select Product Category', style: GoogleFonts.raleway()),
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light, // white status bar icons
      ),

      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Image.asset(
              'assets/images/diagonalpatternbg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: gradient),
            ),
          ),

          // Content (no SafeArea, AppBar already handles status bar)
          Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _BigButton(
                      text: 'Underfloor Heating Products',
                      color: const Color(0xFFDD4F2E),
                      icon: Icons.thermostat,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.underfloorHeatingFactsheetsRoute,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _BigButton(
                      text: 'Frost Protection Products',
                      color: const Color(0xFF009ADC),
                      icon: Icons.ac_unit,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.frostProtectionFactsheetsRoute,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
