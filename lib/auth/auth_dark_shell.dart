import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/atmospheric_dark_background.dart';

const authOrange = Color(0xFFDD4F2E);
const authSubtleBorder = BorderSide(color: Color(0x1FFFFFFF));

class AuthDarkShell extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final EdgeInsetsGeometry contentPadding;

  const AuthDarkShell({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 0, 24, 34),
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: ColoredBox(
        color: Colors.black,
        child: Column(
          children: [
            SizedBox(
              height: 240,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/front_image.jpg',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 20,
                    top: MediaQuery.of(context).padding.top + 26,
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 72,
                      width: 170,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (showBackButton)
                    Positioned(
                      right: 16,
                      top: MediaQuery.of(context).padding.top + 18,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.34),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: authOrange,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF151616),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AtmosphericDarkBackground(
                    accentColor: authOrange,
                    child: SingleChildScrollView(
                      padding: contentPadding,
                      child: child,
                    ),
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

InputDecoration authFieldDecoration({
  required String label,
  String? errorText,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFFB7B7B7)),
    errorText: errorText,
    errorStyle: const TextStyle(color: Color(0xFFFF8A80)),
    filled: true,
    fillColor: const Color(0xFF1C1D1D),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: authOrange),
    ),
    enabledBorder: const OutlineInputBorder(borderSide: authSubtleBorder),
    border: const OutlineInputBorder(borderSide: authSubtleBorder),
  );
}
