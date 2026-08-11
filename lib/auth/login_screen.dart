// lib/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'auth_service.dart';
import 'auth_dark_shell.dart';
import '../routes.dart';

const _orange = authOrange;

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
  bool completingSocialProfile = false;
  String companyName = '';
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    // Force white system UI from the first frame
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android: white icons
        statusBarBrightness: Brightness.dark, // iOS: white icons
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AuthDarkShell(
        child: completingSocialProfile
            ? _buildProfileCompletion()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Welcome',
                    style: GoogleFonts.raleway(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Sign in to your account',
                    style: GoogleFonts.raleway(
                      color: const Color(0xFFB7B7B7),
                      fontSize: 16,
                    ),
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
                        side: authSubtleBorder,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
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
                      style: GoogleFonts.raleway(
                        color: const Color(0xFFFF8A80),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: GoogleFonts.raleway(
                            color: const Color(0xFFAAAAAA),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _socialButton(
                    label: 'Sign in with Google',
                    icon: SizedBox(
                      width: 28,
                      height: 28,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/google_sign_in.svg',
                          width: 23,
                          height: 23,
                        ),
                      ),
                    ),
                    onPressed: () => _socialSignIn(_SocialProvider.google),
                  ),
                  const SizedBox(height: 12),
                  _socialButton(
                    label: 'Sign in with Apple',
                    icon: const SizedBox(
                      width: 28,
                      height: 28,
                      child: Center(
                        child: Icon(Icons.apple, color: Colors.white, size: 25),
                      ),
                    ),
                    onPressed: () => _socialSignIn(_SocialProvider.apple),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: loading
                              ? null
                              : () => Navigator.pushNamed(
                                  context,
                                  Routes.resetPassword,
                                ),
                          child: Text(
                            'Forgot Password?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                              color: const Color(0xFFD0D0D0),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: loading
                              ? null
                              : () => Navigator.pushNamed(
                                  context,
                                  Routes.register,
                                ),
                          child: Text(
                            'Register',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                              color: const Color(0xFFD0D0D0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withValues(alpha: 0.12)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: loading ? null : _continueAsGuest,
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
    );
  }

  Widget _buildProfileCompletion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Text(
          'Complete your profile',
          textAlign: TextAlign.center,
          style: GoogleFonts.raleway(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Google and Apple do not share your company or phone number. '
          'Please add them to finish setting up your Heat Mat account.',
          textAlign: TextAlign.center,
          style: GoogleFonts.raleway(
            color: const Color(0xFFB7B7B7),
            fontSize: 15,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 30),
        _outlinedField(
          label: 'Company Name',
          onChanged: (value) => companyName = value,
        ),
        const SizedBox(height: 16),
        _outlinedField(
          label: 'Phone Number',
          onChanged: (value) => phoneNumber = value,
          keyboardType: TextInputType.phone,
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(
            error!,
            style: GoogleFonts.raleway(color: const Color(0xFFFF8A80)),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading ? null : _saveSocialProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              side: authSubtleBorder,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Continue',
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ],
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
      cursorColor: _orange,
      decoration: authFieldDecoration(label: label),
      style: GoogleFonts.raleway(color: Colors.white),
    );
  }

  Widget _socialButton({
    required String label,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE3E3E3),
          backgroundColor: const Color(0xFF131314),
          disabledForegroundColor: const Color(0xFF777777),
          side: const BorderSide(color: Color(0xFF8E918F)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(alignment: Alignment.centerLeft, child: icon),
            Text(
              label,
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (email.trim().isEmpty || password.isEmpty) {
      setState(() => error = 'Please enter both email and password.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await AuthService.instance.signIn(email.trim(), password);

      if (!mounted) return;

      // Online installer login:
      // Go to main app; Firebase persistence handles future auto-login.
      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      setState(() => error = 'Unable to sign in. Please check your details.');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _continueAsGuest() async {
    if (!mounted) return;

    // Offline-safe guest mode: do not call Firebase.
    setState(() {
      loading = false;
      error = null;
    });

    Navigator.pushReplacementNamed(context, Routes.home);
  }

  Future<void> _socialSignIn(_SocialProvider provider) async {
    final navigator = Navigator.of(context);
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final credential = provider == _SocialProvider.google
          ? await AuthService.instance.signInWithGoogle()
          : await AuthService.instance.signInWithApple();
      if (credential == null || !mounted) return;
      if (await AuthService.instance.needsProfileCompletion()) {
        if (!mounted) return;
        setState(() {
          completingSocialProfile = true;
          error = null;
        });
        return;
      }
      navigator.pushReplacementNamed(Routes.home);
    } on FirebaseAuthException catch (authError) {
      if (_isCancelledAuth(authError.code)) return;
      if (mounted) {
        setState(() => error = _friendlyAuthMessage(authError.code));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error =
              'This sign-in option is not configured yet. Please use email '
              'and password for now.';
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _saveSocialProfile() async {
    if (companyName.trim().isEmpty || phoneNumber.trim().isEmpty) {
      setState(() {
        error = 'Please enter both your company name and phone number.';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });
    try {
      await AuthService.instance.completeSocialProfile(
        company: companyName,
        phone: phoneNumber,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'We could not save your details. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  bool _isCancelledAuth(String code) {
    return code == 'canceled' ||
        code == 'web-context-canceled' ||
        code == 'popup-closed-by-user';
  }

  String _friendlyAuthMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'An account already uses this email address. Sign in with your '
            'existing method first.';
      case 'operation-not-allowed':
        return 'This sign-in option has not been enabled yet.';
      case 'network-request-failed':
        return 'We could not connect. Check your internet connection and try again.';
      default:
        return 'We could not sign you in. Please try again or use email and password.';
    }
  }
}

enum _SocialProvider { google, apple }
