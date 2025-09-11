// lib/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../routes.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String email = '';
  String password = '';
  String confirmPassword = '';
  String fullName = '';
  String companyName = '';
  String phoneNumber = '';
  String? errorMessage;
  bool loading = false;
  bool termsAccepted = false;
  bool showTerms = false;

  bool get formValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      password == confirmPassword &&
      fullName.isNotEmpty &&
      companyName.isNotEmpty &&
      phoneNumber.isNotEmpty &&
      termsAccepted;

  @override
  Widget build(BuildContext context) {
    final statusBar = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
        child: Stack(
          children: [
            // content
            Column(
              children: [
                // Hero image + logo
                SizedBox(
                  height: (200.0 + statusBar).clamp(150.0, 260.0),
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/front_image.jpg', fit: BoxFit.cover),
                      Positioned(
                        left: 16,
                        top: statusBar + 16,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Text('Create Account',
                            style: GoogleFonts.raleway(
                              fontSize: 26,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF333333),
                            )),
                        const SizedBox(height: 16),

                        _outlined('Full Name', onChanged: (v) => fullName = v),
                        const SizedBox(height: 12),
                        _outlined('Company Name', onChanged: (v) => companyName = v),
                        const SizedBox(height: 12),
                        _outlined('Phone Number',
                            onChanged: (v) => phoneNumber = v,
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 12),
                        _outlined('Email',
                            onChanged: (v) => email = v,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 12),
                        _outlined('Password',
                            onChanged: (v) => password = v, obscure: true),
                        const SizedBox(height: 12),
                        _outlined('Confirm Password',
                            onChanged: (v) => confirmPassword = v,
                            obscure: true,
                            isError: confirmPassword.isNotEmpty && confirmPassword != password),
                        const SizedBox(height: 12),

                        // Terms
                        Row(
                          children: [
                            Checkbox(
                              value: termsAccepted,
                              onChanged: (v) => setState(() => termsAccepted = v ?? false),
                              activeColor: const Color(0xFFDD4F2E),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: InkWell(
                                onTap: () => setState(() => showTerms = true),
                                child: Text(
                                  'I agree to the Terms and Conditions',
                                  style: GoogleFonts.raleway(
                                    color: const Color(0xFFDD4F2E),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Register button
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: (!formValid || loading) ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFDD4F2E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Register', style: GoogleFonts.raleway(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(errorMessage!, style: GoogleFonts.raleway(color: const Color(0xFFC00000))),
                        ],
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Already have an account? Sign in', style: GoogleFonts.raleway(color: const Color(0xFF333333))),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (showTerms) _TermsDialog(onClose: () => setState(() => showTerms = false)),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      await AuthService.instance.register(
        email: email.trim(),
        password: password,
        fullName: fullName.trim(),
        companyName: companyName.trim(),
        phoneNumber: phoneNumber.trim(),
      );

      if (!mounted) return;
      // Go straight to Profile so user can see their details
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.profile, (r) => false);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _outlined(
    String label, {
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    bool obscure = false,
    bool isError = false,
  }) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.raleway(color: const Color(0xFF333333)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.raleway(color: Colors.black54),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDD4F2E)),
        ),
        border: const OutlineInputBorder(),
        errorText: isError ? 'Passwords do not match' : null,
      ),
    );
  }
}

class _TermsDialog extends StatelessWidget {
  final VoidCallback onClose;
  const _TermsDialog({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Container(
            margin: const EdgeInsets.all(56),
            decoration: BoxDecoration(
              color: const Color(0xFF2F2F2F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF222222),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Text('Terms and Conditions',
                          style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                      const Spacer(),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close, color: Colors.white),
                      )
                    ],
                  ),
                ),
                // Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _termsText,
                      style: GoogleFonts.raleway(color: Colors.white70, height: 1.35),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Keep your legal text here
const String _termsText = '''
Effective Date: 8 August 2025
Welcome to the Heat Mat - Installer App (the "App"), owned and operated by HEAT MAT LIMITED ("Company," "we," "us," or "our"). Our company registration number is 4905464.
These Terms and Conditions ("Terms") govern your access to and use of our App and its services. By creating an account and using our App, you agree to be bound by these Terms and our Privacy Policy. If you do not agree to these Terms, you may not use the App.
1. User Accounts
To access certain features of the App, including saved quotes and saved warranty applications, you must create an account. When you create an account, you agree to:
Provide accurate, current, and complete information, including your full name, company name, phone number, and email address.
Create a secure password and maintain the confidentiality of your password.
Be solely responsible for all activities that occur under your account.
Notify us immediately of any unauthorized use of your account or any other breach of security.
You must be 18 years of age or older to create an account.
2. Privacy and Your Data
Our Privacy Policy describes how we collect, use, and disclose your personal information. By using our App, you consent to the collection and use of your data in accordance with our Privacy Policy, which is incorporated into these Terms. We encourage you to read our Privacy Policy carefully.
3. User-Generated Content
Our App allows you to create and save content, such as quotes and warranty applications ("User Content"). You retain ownership of your User Content.
By creating and saving User Content on our App, you grant us a worldwide, non-exclusive, royalty-free license to store, display, and reproduce your User Content for the purpose of providing and improving our services.
You are solely responsible for the accuracy, legality, and appropriateness of your User Content. We reserve the right to remove any User Content that we believe violates these Terms or is otherwise objectionable.
4. Intellectual Property
The App and its original content (excluding User Content), features, and functionality are and will remain the exclusive property of HEAT MAT LIMITED and its licensors. The App is protected by copyright, trademark, and other laws of the UNITED KINGDOM.
5. Prohibited Uses
You agree not to use the App for any of the following prohibited purposes:
In any way that violates any applicable local, national, or international law or regulation.
To transmit, or procure the sending of, any advertising or promotional material without our prior written consent.
To impersonate or attempt to impersonate the Company, a Company employee, another user, or any other person or entity.
To engage in any other conduct that restricts or inhibits anyone's use or enjoyment of the App, or which, as determined by us, may harm the Company or users of the App or expose them to liability.
6. Termination
We may terminate or suspend your account and bar access to the App immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.
7. Disclaimer of Warranties
The App is provided on an "AS IS" and "AS AVAILABLE" basis. To the maximum extent permitted by applicable law, the Company makes no representations or warranties of any kind, express or implied, as to the operation of the App or the information, content, or materials included therein.
8. Limitation of Liability
To the fullest extent permitted by applicable law, in no event shall HEAT MAT LIMITED, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the App.
9. Governing Law
These Terms shall be governed and construed in accordance with the laws of the UNITED KINGDOM, without regard to its conflict of law provisions.
10. Changes to These Terms
We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will make reasonable efforts to provide at least 30 days' notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.
11. Contact Us
If you have any questions about these Terms, please contact us at:
HEAT MAT LIMITED
Email: sales@heatmat.co.uk
Phone: 01444 247020
Company registration number: 4905464
''';
