import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'firebase_options.dart';
import 'routes.dart';
import 'auth/auth_gate.dart';
import 'services/notification_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _useAndroidSystemPhotoPicker();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    // Optionally log error
  }

  if (firebaseReady) {
    await NotificationService.instance.initialize(
      navigatorKey: navigatorKey,
      messengerKey: scaffoldMessengerKey,
    );
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const HeatMatApp());
}

void _useAndroidSystemPhotoPicker() {
  if (defaultTargetPlatform != TargetPlatform.android) return;

  final implementation = ImagePickerPlatform.instance;
  if (implementation is ImagePickerAndroid) {
    implementation.useAndroidPhotoPicker = true;
  }
}

class HeatMatApp extends StatelessWidget {
  const HeatMatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final raleway = GoogleFonts.raleway();

    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
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
      home: const AuthGate(),
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
