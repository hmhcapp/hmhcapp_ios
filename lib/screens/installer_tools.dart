import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/atmospheric_dark_background.dart';

import '../routes.dart';

class _ToolInfo {
  final String text;
  final String description;
  final Color color;
  final IconData icon;
  final String route;

  const _ToolInfo({
    required this.text,
    required this.description,
    required this.color,
    required this.icon,
    required this.route,
  });
}

class InstallerToolsScreen extends StatelessWidget {
  const InstallerToolsScreen({super.key});

  static const _calculators = <_ToolInfo>[
    _ToolInfo(
      text: 'Floor Build-up Diagrams',
      description: 'Explore build-up options and details.',
      color: Color(0xFFF4BE25),
      icon: Icons.layers,
      route: Routes.floorDiagrams,
    ),
    _ToolInfo(
      text: 'Cable Spacing Calculator',
      description: 'Calculate optimal cable spacing.',
      color: Color(0xFFEFA528),
      icon: Icons.calculate_outlined,
      route: Routes.cableSpacingCalculator,
    ),
    _ToolInfo(
      text: 'Installation Video',
      description: 'Step-by-step video guides.',
      color: Color(0xFFED9828),
      icon: Icons.play_circle_outline,
      route: Routes.installationVideo,
    ),
    _ToolInfo(
      text: 'Installation Checklist',
      description: 'Stay on track with every installation.',
      color: Color(0xFFEB9029),
      icon: Icons.playlist_add_check_outlined,
      route: Routes.installationChecklistHub,
    ),
  ];

  static const _support = <_ToolInfo>[
    _ToolInfo(
      text: 'Thermostat Apps',
      description: 'Explore compatible thermostat apps.',
      color: Color(0xFFE9882A),
      icon: Icons.phone_android,
      route: Routes.thermostatApps,
    ),
    _ToolInfo(
      text: 'Floor Sensor Calculator',
      description: 'Find the right sensor for your project.',
      color: Color(0xFFE26A2D),
      icon: Icons.device_thermostat_outlined,
      route: Routes.floorSensorCalculator,
    ),
  ];

  static const _planner = _ToolInfo(
    text: 'Heating Mat Planner',
    description: 'Design your heating layout.',
    color: Color(0xFFD94A2C),
    icon: Icons.design_services_outlined,
    route: Routes.heatingMatPlanner,
  );

  @override
  Widget build(BuildContext context) {
    final allTools = [..._calculators, ..._support];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
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
              color: Color(0xFFF4A21E),
              size: 30,
            ),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Installer Tools',
                style: GoogleFonts.raleway(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Calculators, guides and planning tools',
                style: GoogleFonts.raleway(
                  color: const Color(0xFFB7B7B7),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        body: AtmosphericDarkBackground(
          accentColor: const Color(0xFFF4A21E),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: _SectionHeading(
                  icon: Icons.calculate_outlined,
                  text: 'CALCULATORS AND PLANNING',
                  topPadding: 20,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _PlannerCard(tool: _planner, index: allTools.length),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 122,
                  ),
                  itemCount: _calculators.length,
                  itemBuilder: (context, index) =>
                      _ToolCard(tool: _calculators[index], index: index),
                ),
              ),
              const SliverToBoxAdapter(
                child: _SectionHeading(
                  icon: Icons.thermostat_outlined,
                  text: 'THERMOSTAT SUPPORT',
                  topPadding: 28,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 122,
                  ),
                  itemCount: _support.length,
                  itemBuilder: (context, index) => _ToolCard(
                    tool: _support[index],
                    index: index + _calculators.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String text;
  final double topPadding;

  const _SectionHeading({
    required this.icon,
    required this.text,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22, topPadding, 22, 0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFFF39A13)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.raleway(
                color: const Color(0xFFF39A13),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final _ToolInfo tool;
  final int index;

  const _ToolCard({required this.tool, required this.index});

  @override
  Widget build(BuildContext context) {
    final darkerColor = HSLColor.fromColor(tool.color)
        .withLightness(
          (HSLColor.fromColor(tool.color).lightness - 0.13).clamp(0.0, 1.0),
        )
        .toColor();

    return GestureDetector(
      key: ValueKey('installer_tool_$index'),
      onTap: () => Navigator.pushNamed(context, tool.route),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF171818), Color(0xFF242525)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 62,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [darkerColor, tool.color],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.42),
                    blurRadius: 9,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                tool.icon,
                color: Colors.white.withValues(alpha: 0.95),
                size: 32,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tool.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.raleway(
                      color: const Color(0xFFAFAFAF),
                      fontSize: 9.7,
                      height: 1.25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFF39A13),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerCard extends StatelessWidget {
  final _ToolInfo tool;
  final int index;

  const _PlannerCard({required this.tool, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('installer_tool_$index'),
      onTap: () => Navigator.pushNamed(context, tool.route),
      child: Container(
        height: 132,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF8B4B00), Color(0xFFD43D22)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF39A13), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.72),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _PlannerPainter()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Container(
                    width: 66,
                    height: 78,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE89A1B), Color(0xFFE14124)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.40),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(tool.icon, color: Colors.white, size: 38),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFB128),
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'FEATURED',
                                style: GoogleFonts.raleway(
                                  color: const Color(0xFFFFD8A5),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          tool.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tool.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.raleway(
                            color: const Color(0xFFD4C7C2),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFFFAE1A),
                    size: 28,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerPainter extends CustomPainter {
  const _PlannerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    final right = size.width + 16;
    for (var i = 0; i < 4; i++) {
      final y = 28.0 + (i * 16);
      path.moveTo(right, y);
      path.cubicTo(
        size.width * 0.84,
        y - 15,
        size.width * 0.77,
        y + 22,
        size.width * 0.68,
        y + 8,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
