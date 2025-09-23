
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              itemCount: _checklists.length,
              itemBuilder: (context, index) {
                final checklist = _checklists[index];
                return Padding(
                  // Add spacing below each button except the last one
                  padding: EdgeInsets.only(bottom: index == _checklists.length - 1 ? 0 : 24),
                  child: _BigButton(
                    text: checklist.text,
                    color: checklist.color,
                    icon: checklist.icon,
                    onTap: () => Navigator.pushNamed(context, checklist.route),
                    index: index, // Pass the index for the animation
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
  final int index; // Index to determine direction and delay

  const _BigButton({
    required this.text,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.index,
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
        height: 130,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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