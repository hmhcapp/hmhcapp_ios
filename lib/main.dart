import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes.dart';
import 'package:flutter/services.dart';

import 'auth/login_screen.dart';
import 'main_home.dart'; // moved HomeScreen into its own file to keep main.dart clean

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  // Global system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,       // Android: .dark == light icons
    statusBarBrightness: Brightness.light,       // iOS: .light == light content (counter-intuitive)
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const HeatMatApp());
}

class HeatMatApp extends StatelessWidget {
  const HeatMatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final raleway = GoogleFonts.raleway();

    return MaterialApp(
      title: 'Heat Mat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFDD4F2E),
        textTheme: GoogleFonts.ralewayTextTheme(),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Color(0xFF333333),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: raleway.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      // Always open on the Login screen
      home: const LoginScreen(),
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
