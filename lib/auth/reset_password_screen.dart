import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';

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
      appBar: AppBar(
        title: Text('Reset password', style: GoogleFonts.raleway()),
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => email = v,
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: sending ? null : _send,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF333333)),
                child: sending
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Send reset email', style: GoogleFonts.raleway(color: Colors.white)),
              ),
              if (msg != null) ...[
                const SizedBox(height: 12),
                Text(msg!, style: GoogleFonts.raleway()),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() { sending = true; msg = null; });
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
