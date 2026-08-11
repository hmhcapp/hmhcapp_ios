import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'auth_dark_shell.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  String email = '';
  bool sending = false;
  String? msg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AuthDarkShell(
        showBackButton: true,
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(
                'Reset Password',
                style: GoogleFonts.raleway(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email and we’ll send you a reset link.',
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  color: const Color(0xFFB7B7B7),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                cursorColor: authOrange,
                style: GoogleFonts.raleway(color: Colors.white),
                decoration: authFieldDecoration(label: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => email = v,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: sending ? null : _send,
                  style: FilledButton.styleFrom(
                    backgroundColor: authOrange,
                    foregroundColor: Colors.white,
                    side: authSubtleBorder,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Send Reset Email',
                          style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              if (msg != null) ...[
                const SizedBox(height: 16),
                Text(
                  msg!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(color: const Color(0xFFD0D0D0)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      sending = true;
      msg = null;
    });
    try {
      await AuthService.instance.resetPassword(email.trim());
      setState(() => msg = 'Password reset email sent.');
    } catch (e) {
      setState(() => msg = e.toString());
    } finally {
      setState(() => sending = false);
    }
  }
}
