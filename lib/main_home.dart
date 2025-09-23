import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _animate = false;

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
  void initState() {
    super.initState();
    // Delay to allow the screen to build first, then trigger animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _animate = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBar = MediaQuery.of(context).padding.top;

    final heroBase = size.height < 700 ? 130.0 : 200.0;
    const shrink = 55.0; // reduce hero by ~55 px
    final heroH = (heroBase + statusBar - shrink).clamp(100.0, double.infinity);

    const SystemUiOverlayStyle whiteSystemUI = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Light icons for Android
      statusBarBrightness: Brightness.light,    // Light icons for iOS
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: whiteSystemUI,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _animate ? 1.0 : 0.0,
                child: Image.asset(
                  'assets/images/diagonalpatternbg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
            Column(
              children: [
                SizedBox(
                  height: heroH,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Animated Top Image
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(
                          0,
                          _animate ? 0 : -heroH, // Start above the screen
                          0,
                        ),
                        child: Image.asset('assets/images/front_image.jpg', fit: BoxFit.cover),
                      ),
                      // Animated Logo
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 450),
                        left: _animate ? 16 : -200, // Start off-screen to the left
                        top: statusBar + 16,
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
                // Animated "The Underfloor Heating Specialists" box
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(
                    _animate ? 0 : size.width, // Start off-screen to the right
                    0,
                    0,
                  ),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      primary: false,
                      itemCount: _tileData.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (_, i) => _MenuCard(
                        tile: _tileData[i],
                        index: i,
                        // Pass the animation trigger state to the cards
                        startAnimation: _animate,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

class _MenuCard extends StatefulWidget {
  final _Tile tile;
  final int index;
  final bool startAnimation; // New property to trigger animation

  const _MenuCard({
    required this.tile,
    required this.index,
    required this.startAnimation,
  });

  @override
  __MenuCardState createState() => __MenuCardState();
}

class __MenuCardState extends State<_MenuCard> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    // We will now trigger the animation based on the `startAnimation` prop
    // so we don't need the delayed future here anymore.
  }

  @override
  void didUpdateWidget(covariant _MenuCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startAnimation && !_animate) {
      // Use a delay based on the index to stagger the card animations
      Future.delayed(Duration(milliseconds: 250 + (150 * widget.index)), () {
        if (mounted) {
          setState(() {
            _animate = true;
          });
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final isLeft = widget.index % 2 == 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final offScreenX = screenWidth / 2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100), // Slightly faster animation
      transform: Matrix4.translationValues(
        _animate ? 0 : (isLeft ? -offScreenX : offScreenX),
        0,
        0,
      ),
      curve: Curves.easeOut, // Add a nice curve to the animation
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, widget.tile.route),
        child: Container(
          decoration: BoxDecoration(
            color: widget.tile.color,
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
                Icon(widget.tile.icon, size: 48, color: Colors.white.withOpacity(0.8)),
                const SizedBox(height: 14),
                Text(
                  widget.tile.title,
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
      ),
    );
  }
}