import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';

// Data class for the button information
class _ChecklistInfo {
  final String text;
  final Color color;
  final IconData icon;
  final String route;

  const _ChecklistInfo({
    required this.text,
    required this.color,
    required this.icon,
    required this.route,
  });
}

class InstallationChecklistHubScreen extends StatelessWidget {
  const InstallationChecklistHubScreen({super.key});

  // Store button data in a list
  static const _checklists = <_ChecklistInfo>[
    _ChecklistInfo(
      text: 'Heating Mats',
      color: Color(0xFFF4BE25),
      icon: Icons.space_dashboard,
      route: Routes.heatingMatChecklist,
    ),
    _ChecklistInfo(
      text: 'Heating Cables',
      color: Color(0xFFEFA528),
      icon: Icons.route,
      route: Routes.heatingCableChecklist,
    ),
  ];

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

    // Define horizontal padding value
    const horizontalPadding = 32.0;

    // Calculate the button size based on screen width minus padding
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth - (horizontalPadding * 2);

    return Scaffold(
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
          SafeArea(
            top: false,
            // Use a ListView for consistency and easy indexing
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 32,
              ),
              itemCount: _checklists.length,
              itemBuilder: (context, index) {
                final checklist = _checklists[index];
                return Padding(
                  // Add spacing below each button
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _BigButton(
                    text: checklist.text,
                    color: checklist.color,
                    icon: checklist.icon,
                    onTap: () => Navigator.pushNamed(context, checklist.route),
                    index: index, // Pass the index for the animation
                    size: buttonSize, // Pass the calculated size
                  ),
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
  final double size; // Property to hold the button size

  const _BigButton({
    required this.text,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.index,
    required this.size, // Make size a required parameter
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
      // Use the passed-in size for both height and width
      child: SizedBox(
        height: widget.size,
        width: widget.size,
        child: ElevatedButton(
          onPressed: widget.onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 72, color: Colors.white.withOpacity(0.9)),
              const SizedBox(height: 16),
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(fontSize: 20, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}