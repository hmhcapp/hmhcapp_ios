import 'package:flutter/material.dart';

const atmosphericSurface = Color(0xFF1C1D1D);
const atmosphericRaisedSurface = Color(0xFF242525);
const atmosphericBorder = Color(0xFF464848);
const atmosphericPrimaryText = Color(0xFFF4F4F4);
const atmosphericSecondaryText = Color(0xFFB7B7B7);

ThemeData atmosphericDarkTheme(BuildContext context, {required Color accent}) {
  final base = Theme.of(context);
  return base.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    canvasColor: atmosphericSurface,
    cardColor: atmosphericSurface,
    dividerColor: atmosphericBorder,
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: accent,
      secondary: accent,
      surface: atmosphericSurface,
      onSurface: atmosphericPrimaryText,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: atmosphericPrimaryText,
      displayColor: atmosphericPrimaryText,
    ),
    cardTheme: const CardThemeData(
      color: atmosphericSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: atmosphericBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: atmosphericSurface,
      labelStyle: const TextStyle(color: atmosphericSecondaryText),
      hintStyle: const TextStyle(color: Color(0xFF858787)),
      prefixIconColor: accent,
      suffixIconColor: accent,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: atmosphericBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: atmosphericBorder),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: const BorderSide(color: atmosphericBorder),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? accent
            : atmosphericSecondaryText,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? accent.withValues(alpha: 0.42)
            : const Color(0xFF404242),
      ),
    ),
  );
}

/// A restrained dark backdrop used across the app's dark navigation screens.
///
/// The layered gradients add depth without reducing text or card contrast.
class AtmosphericDarkBackground extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final Color topColor;

  const AtmosphericDarkBackground({
    super.key,
    required this.child,
    this.accentColor = const Color(0xFFF39A1E),
    this.topColor = const Color(0xFF191A1A),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [topColor, const Color(0xFF0D0E0E), Colors.black],
              stops: const [0, 0.52, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.08, -0.92),
              radius: 1.05,
              colors: [
                accentColor.withValues(alpha: 0.21),
                accentColor.withValues(alpha: 0.045),
                Colors.transparent,
              ],
              stops: const [0, 0.42, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-1.12, 0.92),
              radius: 0.95,
              colors: [
                const Color(0xFFFFB329).withValues(alpha: 0.12),
                Colors.transparent,
              ],
              stops: const [0, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
