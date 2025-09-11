// lib/main_home.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // <-- 1. IMPORTED SERVICES

import 'routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _tileData = <_Tile>[
    _Tile('PRODUCT FACTSHEETS', Icons.description_outlined,
        Routes.productCategorySelection, Color(0xFFDD4F2E)),
    _Tile('PRODUCT INSTRUCTIONS', Icons.menu_book_outlined,
        Routes.productInstructionCategorySelection, Color(0xFFE26A2D)),
    _Tile('CASE STUDIES', Icons.library_books_outlined,
        Routes.caseStudies, Color(0xFFE88A2B)),
    _Tile('GET A QUOTE', Icons.edit_note_outlined,
        Routes.getAQuoteCategorySelection, Color(0xFFEFA528)),
    _Tile('REGISTER WARRANTY', Icons.workspace_premium_outlined,
        Routes.registerWarranty, Color(0xFFF1B227)),
    _Tile('INSTALLER TOOLS', Icons.build_outlined,
        Routes.installerTools, Color(0xFFF4BE25)),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBar = MediaQuery.of(context).padding.top;

    final heroBase = size.height < 700 ? 130.0 : 200.0;
    const shrink = 55.0; // reduce hero by ~55 px
    final heroH = (heroBase + statusBar - shrink).clamp(100.0, double.infinity);

    // 2. DEFINED THE UI STYLE FOR WHITE ICONS
    const SystemUiOverlayStyle whiteSystemUI = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Light icons for Android
      statusBarBrightness: Brightness.light,    // Light icons for iOS
    );

    // 3. WRAPPED THE SCAFFOLD IN AN ANNOTATED REGION
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: whiteSystemUI,
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/diagonalpatternbg.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Gradient behind content
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.40),
                        const Color(0xFF333333).withOpacity(0.50),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            // Main content (no SafeArea so hero goes to very top)
            Column(
              children: [
                // Hero image + logo
                SizedBox(
                  height: heroH,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/front_image.jpg', fit: BoxFit.cover),
                      Positioned(
                        left: 16,
                        top: statusBar + 16, // keep logo below status bar
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 80,
                          width: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dark strap
                Container(
                  width: double.infinity,
                  color: const Color(0xFF333333),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'The Underfloor Heating Specialists',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                  ),
                ),

                // Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,     // remove extra inset
                      primary: false,               // don't apply MediaQuery padding
                      itemCount: _tileData.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (_, i) => _MenuCard(tile: _tileData[i]),
                    ),
                  ),
                ),
              ],
            ),

            // Top-right Login/Profile (reacts to auth state)
            Positioned(
              top: statusBar + 30,
              right: 16,
              child: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snap) {
                  final user = snap.data;
                  final isLoggedIn = user != null && !user.isAnonymous;

                  return TextButton.icon(
                    onPressed: () {
                      if (isLoggedIn) {
                        Navigator.pushNamed(context, Routes.profile);
                      } else {
                        Navigator.pushNamed(context, Routes.login);
                      }
                    },
                    icon: Icon(
                      isLoggedIn ? Icons.account_circle : Icons.login,
                      color: Colors.white,
                    ),
                    label: Text(
                      isLoggedIn ? 'Profile' : 'Login',
                      style: GoogleFonts.raleway(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  const _Tile(this.title, this.icon, this.route, this.color);
}

class _MenuCard extends StatelessWidget {
  final _Tile tile;
  const _MenuCard({required this.tile, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, tile.route),
      child: Container(
        decoration: BoxDecoration(
          color: tile.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tile.icon, size: 48, color: Colors.white.withOpacity(0.8)),
              const SizedBox(height: 14),
              Text(
                tile.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}