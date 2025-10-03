import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';

// A simple data class to hold button information
class _ToolInfo {
  final String text;
  final Color color;
  final IconData icon;
  final String route;

  const _ToolInfo({
    required this.text,
    required this.color,
    required this.icon,
    required this.route,
  });
}

class InstallerToolsScreen extends StatelessWidget {
  const InstallerToolsScreen({super.key});

  // Store button data in a list for easier management
  static const _tools = <_ToolInfo>[
    _ToolInfo(
      text: 'Floor Build-up Diagrams',
      color: Color(0xFFF4BE25),
      icon: Icons.layers,
      route: Routes.floorDiagrams,
    ),
    _ToolInfo(
      text: 'Cable Spacing Calculator',
      color: Color(0xFFEFA528),
      icon: Icons.calculate_outlined,
      route: Routes.cableSpacingCalculator,
    ),
    _ToolInfo(
      text: 'Thermostat Apps',
      color: Color(0xFFE26A2D),
      icon: Icons.phone_android,
      route: Routes.thermostatApps,
    ),
    _ToolInfo(
      text: 'Installation Checklist',
      color: Color(0xFFD94A2C),
      icon: Icons.playlist_add_check_outlined,
      route: Routes.installationChecklistHub,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white.withOpacity(0.4), const Color(0xFF333333).withOpacity(0.6)],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Installer Tools', style: GoogleFonts.raleway()),
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/diagonalpatternbg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(decoration: BoxDecoration(gradient: gradient)),
          ),
          // Wrap the LayoutBuilder with a SafeArea widget
          // This ensures the layout respects the system UI (like the bottom navigation bar)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const verticalPadding = 24.0;
                const spacing = 24.0;
                final buttonCount = _tools.length;

                // Calculate the total height used by padding and spacing
                // The last item does not have bottom padding in this calculation
                final totalSpacing = (verticalPadding * 2) + (spacing * (buttonCount -1));
                
                // Calculate the height available for each button within the safe area
                final buttonHeight = (constraints.maxHeight - totalSpacing) / buttonCount;

                // Use a fallback height in case the calculated height is invalid (e.g., during orientation changes)
                final safeButtonHeight = buttonHeight > 0 ? buttonHeight : 130.0;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: verticalPadding),
                  itemCount: buttonCount,
                  itemBuilder: (context, index) {
                    final tool = _tools[index];
                    return Padding(
                      // Add spacing below each button except the last one
                      padding: EdgeInsets.only(bottom: index == buttonCount - 1 ? 0 : spacing),
                      child: _BigButton(
                        text: tool.text,
                        color: tool.color,
                        icon: tool.icon,
                        onTap: () => Navigator.pushNamed(context, tool.route),
                        index: index,
                        height: safeButtonHeight, // Pass the calculated height
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BigButton extends StatefulWidget {
  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final int index;
  final double height; // Property for button height

  const _BigButton({
    required this.text,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.index,
    required this.height,
  });

  @override
  __BigButtonState createState() => __BigButtonState();
}

class __BigButtonState extends State<_BigButton> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    // Staggered delay for each button
    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) {
        setState(() {
          _animate = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine direction based on index (even/odd)
    final isLeft = widget.index % 2 == 0;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(
        _animate ? 0 : (isLeft ? -screenWidth : screenWidth),
        0,
        0,
      ),
      child: SizedBox(
        height: widget.height, // Use the passed-in height
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 56, color: Colors.white.withOpacity(0.9)),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  widget.text,
                  style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}