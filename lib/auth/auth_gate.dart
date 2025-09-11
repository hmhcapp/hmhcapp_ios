import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authState,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data == null) {
          return const LoginScreen();
        }
        return const ProfileScreen();
      },
    );
  }
}
