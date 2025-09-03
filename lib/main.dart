import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized: ${Firebase.apps.map((a) => a.name).toList()}');
  } catch (e, s) {
    print('Firebase init error: $e\n$s');
  }

  runApp(const HeatMatApp());
}

class HeatMatApp extends StatelessWidget {
  const HeatMatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'Heat Mat',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFFDD4F2E),
    textTheme: GoogleFonts.ralewayTextTheme(),
  ),
  home: const HomeScreen(),
  onGenerateRoute: Routes.onGenerateRoute,
  // NO `routes:` and NO `initialRoute`
);
  }
}

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
    final heroH = size.height < 700 ? 130.0 : 200.0;

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

          SafeArea(
            child: Column(
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
                        top: 16,
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
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                    ),
                  ),
                ),

                // Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      itemCount: _tileData.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (_, i) => _MenuCard(tile: _tileData[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top-right Profile/Login
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, Routes.profile),
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  label: Text('Profile', style: GoogleFonts.raleway(color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
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
          color: tile.color, // hard colour
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
              Icon(tile.icon, size: 48, color: Colors.white.withOpacity(0.9)),
              const SizedBox(height: 8),
              Text(
                tile.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
