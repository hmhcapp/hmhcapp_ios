// lib/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';
import '../routes.dart';

const _orange = Color(0xFFDD4F2E);
const _dark = Color(0xFF333333);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  String? error;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Force white system UI (status bar icons) from the first frame
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,        // transparent status bar
      statusBarIconBrightness: Brightness.light, // Android: white icons
      statusBarBrightness: Brightness.dark,      // iOS: white icons
      systemNavigationBarColor: Colors.black,    // optional nav bar color
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Colors.white, Color(0xFFF2F2F2)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                // --- SYNTAX FIX: The 'children' property needs a list, starting with [ ---
                children: [
                  Image.asset('assets/images/front_image.jpg', fit: BoxFit.cover),
                  Positioned(
                    left: 16,
                    top: MediaQuery.of(context).padding.top + 16,
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                                   
                    const SizedBox(height: 32),
                    Text(
                      'Welcome',
                      style: GoogleFonts.raleway(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: _dark,
                      ),
                    ),
                    Text(
                      'Sign in to your account',
                      style: GoogleFonts.raleway(color: Colors.grey[700], fontSize: 16),
                    ),
                    const SizedBox(height: 32),

                    _outlinedField(
                      label: 'Email',
                      onChanged: (v) => email = v,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _outlinedField(
                      label: 'Password',
                      onChanged: (v) => password = v,
                      obscure: true,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                              )
                            : Text(
                                'Login',
                                style: GoogleFonts.raleway(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        style: GoogleFonts.raleway(color: const Color(0xFFC00000)),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, Routes.resetPassword),
                          child: Text('Forgot Password?', style: GoogleFonts.raleway(color: _dark)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, Routes.register),
                          child: Text('Register', style: GoogleFonts.raleway(color: _dark)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: _continueAsGuest,
                      child: Text(
                        'Continue as Guest',
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w600,
                          color: _orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlinedField({
    required String label,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.raleway(color: Colors.black54),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: _orange)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
        border: const OutlineInputBorder(),
      ),
      style: GoogleFonts.raleway(color: _dark),
    );
  }

  Future<void> _submit() async {
    if (email.trim().isEmpty || password.isEmpty) {
      setState(() => error = 'Please enter both email and password.');
      return;
    }
    setState(() { loading = true; error = null; });
    try {
      await AuthService.instance.signIn(email.trim(), password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() { loading = true; error = null; });
    try {
      await AuthService.instance.signInAnonymously();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}