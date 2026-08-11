import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes.dart';
import 'services/notification_service.dart';
import 'widgets/atmospheric_dark_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _animate = false;
  static const _plannerAnnouncementKey =
      'announcement_heating_mat_planner_2026';

  static const _tileData = <_Tile>[
    _Tile(
      'PRODUCT FACTSHEETS',
      'Technical data and product information.',
      Icons.description_outlined,
      Routes.productCategorySelection,
      Color(0xFFDD4F2E),
    ),
    _Tile(
      'PRODUCT INSTRUCTIONS',
      'Step-by-step installation instructions.',
      Icons.menu_book_outlined,
      Routes.productInstructionCategorySelection,
      Color(0xFFE26A2D),
    ),
    _Tile(
      'CASE STUDIES',
      'Real projects and proven performance.',
      Icons.library_books_outlined,
      Routes.caseStudies,
      Color(0xFFE88A2B),
    ),
    _Tile(
      'GET A QUOTE',
      'Request a tailored quote for your project.',
      Icons.edit_note_outlined,
      Routes.getAQuoteCategorySelection,
      Color(0xFFEFA528),
    ),
    _Tile(
      'REGISTER WARRANTY',
      'Register your product warranty with ease.',
      Icons.workspace_premium_outlined,
      Routes.registerWarranty,
      Color(0xFFF1B227),
    ),
    _Tile(
      'INSTALLER TOOLS',
      'Tools, resources and downloads for pros.',
      Icons.build_outlined,
      Routes.installerTools,
      Color(0xFFF4BE25),
      featured: true,
    ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPlannerAnnouncementIfNeeded();
      NotificationService.instance.handlePendingLaunchMessage();
    });
  }

  Future<void> _showPlannerAnnouncementIfNeeded() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_plannerAnnouncementKey) ?? false) return;
    if (!mounted) return;

    final action = await showDialog<_AnnouncementAction>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.grid_view_rounded,
          size: 42,
          color: Color(0xFFDD4F2E),
        ),
        title: const Text(
          'New: Heating Mat Planner',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Create a professional heating mat plan directly in Installer '
          'Tools, then save or share the finished PDF.\n\n'
          'You can also enable notifications for future app updates and '
          'important Heat Mat news.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _AnnouncementAction.dismiss),
            child: const Text('LATER'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              _AnnouncementAction.enableNotifications,
            ),
            child: const Text('ENABLE NOTIFICATIONS'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _AnnouncementAction.openPlanner),
            child: const Text('TRY PLANNER'),
          ),
        ],
      ),
    );

    await preferences.setBool(_plannerAnnouncementKey, true);
    if (!mounted) return;

    switch (action) {
      case _AnnouncementAction.enableNotifications:
        await _requestNotificationPermission();
        break;
      case _AnnouncementAction.openPlanner:
        if (mounted) {
          Navigator.pushNamed(context, Routes.heatingMatPlanner);
        }
        break;
      case _AnnouncementAction.dismiss:
      case null:
        break;
    }
  }

  Future<void> _requestNotificationPermission() async {
    final connected = await NotificationService.instance.requestPermission();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          connected
              ? 'Notifications are enabled and connected.'
              : NotificationService.instance.notificationsEnabled.value
              ? 'Permission is enabled, but notification setup has not '
                    'finished. Close and reopen the app to retry.'
              : 'Notifications were not enabled. You can change this in your '
                    'phone settings.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBar = MediaQuery.of(context).padding.top;
    const heroH = 240.0;

    const SystemUiOverlayStyle whiteSystemUI = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Light icons for Android
      statusBarBrightness: Brightness.light, // Light icons for iOS
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: whiteSystemUI,
      child: Scaffold(
        backgroundColor: const Color(0xFF1D1D1D),
        body: Column(
          children: [
            SizedBox(
              height: heroH - 18,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: heroH,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/front_image.jpg',
                          fit: BoxFit.cover,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0x55000000), Color(0x08000000)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          top: statusBar + 26,
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 72,
                            width: 170,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: statusBar + 28,
                          right: 14,
                          child: StreamBuilder<User?>(
                            stream: FirebaseAuth.instance.authStateChanges(),
                            builder: (context, snap) {
                              final user = snap.data;
                              final isLoggedIn =
                                  user != null && !user.isAnonymous;

                              return Stack(
                                children: [
                                  Positioned.fill(
                                    child: ShaderMask(
                                      blendMode: BlendMode.dstIn,
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.black,
                                              Colors.black,
                                              Colors.transparent,
                                            ],
                                            stops: [0, 0.12, 0.88, 1],
                                          ).createShader(bounds),
                                      child: ShaderMask(
                                        blendMode: BlendMode.dstIn,
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black,
                                                Colors.black,
                                                Colors.transparent,
                                              ],
                                              stops: [0, 0.22, 0.78, 1],
                                            ).createShader(bounds),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 5,
                                              sigmaY: 5,
                                            ),
                                            child: ColoredBox(
                                              color: Colors.black.withValues(
                                                alpha: 0.01,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      isLoggedIn
                                          ? Routes.profile
                                          : Routes.login,
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.fromLTRB(
                                        8,
                                        10,
                                        18,
                                        10,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: Icon(
                                      isLoggedIn
                                          ? Icons.account_circle
                                          : Icons.login,
                                      size: 20,
                                    ),
                                    label: Text(
                                      isLoggedIn ? 'Profile' : 'Login',
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: AtmosphericDarkBackground(
                  accentColor: const Color(0xFFE9882A),
                  child: Column(
                    children: [
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        offset: _animate ? Offset.zero : const Offset(1, 0),
                        child: SizedBox(
                          height: 66,
                          width: double.infinity,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                'The Underfloor Heating Specialists',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.raleway(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final tileHeight =
                                ((constraints.maxHeight - 56) / 3).clamp(
                                  142.0,
                                  158.0,
                                );
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(14, 4, 14, 22),
                              primary: false,
                              itemCount: _tileData.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    mainAxisExtent: tileHeight,
                                  ),
                              itemBuilder: (_, i) => _MenuCard(
                                tile: _tileData[i],
                                index: i,
                                startAnimation: _animate,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
  final String description;
  final IconData icon;
  final String route;
  final Color color;
  final bool featured;

  const _Tile(
    this.title,
    this.description,
    this.icon,
    this.route,
    this.color, {
    this.featured = false,
  });
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
    final darkerColor = HSLColor.fromColor(widget.tile.color)
        .withLightness(
          (HSLColor.fromColor(widget.tile.color).lightness - 0.12).clamp(
            0.0,
            1.0,
          ),
        )
        .toColor();
    final isFeatured = widget.tile.featured;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      transform: Matrix4.translationValues(
        _animate ? 0 : (isLeft ? -offScreenX : offScreenX),
        0,
        0,
      ),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, widget.tile.route),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isFeatured
                  ? const [
                      Color(0xFF3A2717),
                      Color(0xFF1C1D1D),
                      Color(0xFF332A18),
                    ]
                  : const [Color(0xFF191A1A), Color(0xFF262727)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.tile.color, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.72),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 54,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [darkerColor, widget.tile.color],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.tile.color.withValues(
                                  alpha: 0.28,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.tile.icon,
                            size: 31,
                            color: Colors.white.withValues(alpha: 0.96),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.tile.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.raleway(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  height: 1.22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 30,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: widget.tile.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 22),
                      child: Text(
                        widget.tile.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.raleway(
                          color: const Color(0xFFB5B5B5),
                          fontSize: 10.8,
                          height: 1.42,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 9,
                bottom: 13,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: widget.tile.color,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AnnouncementAction { dismiss, enableNotifications, openPlanner }
