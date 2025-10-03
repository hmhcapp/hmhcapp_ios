import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';

// A simple data class to hold button information
class _InstructionInfo {
  final String text;
  final Color color;
  final IconData icon;
  final String route;

  const _InstructionInfo({
    required this.text,
    required this.color,
    required this.icon,
    required this.route,
  });
}

class InstructionCategorySelectionScreen extends StatelessWidget {
  const InstructionCategorySelectionScreen({super.key});

  // Store button data in a list for easier management
  static const _instructions = <_InstructionInfo>[
    _InstructionInfo(
      text: 'Underfloor Heating Instructions',
      color: Color(0xFFE26A2D),
      icon: Icons.menu_book_outlined,
      route: Routes.underfloorHeatingInstructionsRoute,
    ),
    _InstructionInfo(
      text: 'Frost Protection Instructions',
      color: Color(0xFF009ADC),
      icon: Icons.ac_unit,
      route: Routes.frostProtectionInstructionsRoute,
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
        title: Text('Select Instruction Category', style: GoogleFonts.raleway()),
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
        leading: const BackButton(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
            child: Container(
              decoration: BoxDecoration(gradient: gradient),
            ),
          ),
          // Use a ListView for the buttons
          ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            itemCount: _instructions.length,
            itemBuilder: (context, index) {
              final instruction = _instructions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _BigButton(
                  text: instruction.text,
                  color: instruction.color,
                  icon: instruction.icon,
                  onTap: () => Navigator.pushNamed(context, instruction.route),
                  index: index, // Pass the index for the animation
                  size: buttonSize, // Pass the calculated size
                ),
              );
            },
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
  final double size; // New property to hold the button size

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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