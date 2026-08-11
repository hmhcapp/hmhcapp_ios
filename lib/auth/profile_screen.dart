// lib/auth/profile_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes.dart';
import '../widgets/atmospheric_dark_background.dart';

const _orange = Color(0xFFDD4F2E);
const _warrantyYellow = Color(0xFFF1B227);
const _quotesOrange = Color(0xFFEFA528);
const _loyaltyBurgundy = Color(0xFF9F3D2D);
const _subtleBorder = BorderSide(color: Color(0x1FFFFFFF));

class UserProfileData {
  final String fullName;
  final String companyName;
  final String phoneNumber;
  final String email;

  const UserProfileData({
    required this.fullName,
    required this.companyName,
    required this.phoneNumber,
    required this.email,
  });

  factory UserProfileData.fromMap(
    Map<String, dynamic> m, {
    User? fallbackUser,
  }) {
    return UserProfileData(
      fullName: _firstNonEmpty(
        m['fullName'],
        m['name'],
        fallbackUser?.displayName,
      ),
      companyName: _firstNonEmpty(m['companyName'], m['company']),
      phoneNumber: _firstNonEmpty(m['phoneNumber'], m['phone']),
      email: _firstNonEmpty(m['email'], fallbackUser?.email),
    );
  }

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'companyName': companyName,
    'phoneNumber': phoneNumber,
    'email': email,
    'name': fullName,
    'company': companyName,
    'phone': phoneNumber,
  };

  static String _firstNonEmpty(dynamic first, [dynamic second, dynamic third]) {
    for (final value in [first, second, third]) {
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }
}

enum _ProfileState { loading, notFound, loaded }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  _ProfileState _state = _ProfileState.loading;
  UserProfileData? _profile;
  bool _editing = false;

  // Edit fields
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _saving = false;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  @override
  void initState() {
    super.initState();
    _attachProfileStreamOrRedirect();
  }

  void _attachProfileStreamOrRedirect() {
    final user = _auth.currentUser;

    // If not logged in or anonymous, route to login (Profile is for logged-in users only now).
    if (user == null || user.isAnonymous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.login, (r) => false);
      });
      return;
    }

    // Live listen to users/{uid} for immediate UI updates (e.g. just after register).
    _state = _ProfileState.loading;
    _sub = _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
          (doc) {
            if (!mounted) return;
            if (!doc.exists || doc.data() == null) {
              setState(() {
                _state = _ProfileState.notFound;
              });
              return;
            }
            final data = UserProfileData.fromMap(
              doc.data()!,
              fallbackUser: user,
            );
            _profile = data;

            // Set edit fields
            _nameCtrl.text = data.fullName;
            _companyCtrl.text = data.companyName;
            _phoneCtrl.text = data.phoneNumber;
            _emailCtrl.text = data.email;

            setState(() {
              _state = _ProfileState.loaded;
            });
          },
          onError: (_) {
            if (!mounted) return;
            setState(() => _state = _ProfileState.notFound);
          },
        );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final updated = UserProfileData(
        fullName: _nameCtrl.text.trim(),
        companyName: _companyCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );

      // 1) Update Firestore profile
      await _db
          .collection('users')
          .doc(user.uid)
          .set(updated.toMap(), SetOptions(merge: true));

      // 2) If email changed, update Auth email
      if (updated.email.isNotEmpty && updated.email != user.email) {
        await user.updateEmail(updated.email);
      }

      _profile = updated;
      _editing = false;

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _profile?.email.trim();
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email found to send reset link')),
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset email: $e')),
        );
      }
    }
  }

  // --- NEW FUNCTION TO SEND FEEDBACK EMAIL ---
  Future<void> _sendFeedbackEmail() async {
    const toEmail = 'tech@heatmat.co.uk';
    const subject = 'App Feedback / Suggestion';
    const body = 'Hello Heat Mat Team,\n\nI have the following feedback:\n\n';

    final mailtoUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
      } else {
        // Fallback if no email client is found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not find an email app to send feedback.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open email app: $e')));
      }
    }
  }
  // ------------------------------------------

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Signed out')));
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final statusBar = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: ColoredBox(
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
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33000000), Color(0x22000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: statusBar + 26,
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 72,
                      width: 170,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: statusBar + 44,
                    right: 18,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.34),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 29,
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
                    accentColor: _orange,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          switch (_state) {
                            _ProfileState.loading => _loading(),
                            _ProfileState.notFound => _notFound(),
                            _ProfileState.loaded => _loaded(),
                          },
                        ],
                      ),
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

  Widget _loading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 32),
        child: CircularProgressIndicator(color: _orange),
      ),
    );
  }

  Widget _notFound() {
    // This should be rare (e.g., profile doc missing). Offer logout or retry.
    return Column(
      children: [
        Text(
          'Profile Data Not Found',
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'We could not load your profile. Please sign out and sign in again, or contact support.',
          style: GoogleFonts.raleway(color: const Color(0xFFB7B7B7)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              side: _subtleBorder,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loaded() {
    final p = _profile!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _profileCard(p),
        if (!_editing) ...[
          const SizedBox(height: 24),
          _sectionHeading(Icons.folder_outlined, 'Your Saved Documents'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _documentCard(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Warranties',
                  description: 'View and manage your warranties',
                  accent: _warrantyYellow,
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.registerWarranty,
                    arguments: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _documentCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Quotes',
                  description: 'View and manage your quotes',
                  accent: _quotesOrange,
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.getAQuoteCategorySelection,
                    arguments: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _sectionHeading(Icons.settings_outlined, 'Account Management'),
          const SizedBox(height: 12),
          _accountAction(
            icon: Icons.workspace_premium_outlined,
            title: 'Loyalty Scheme',
            subtitle: 'View your loyalty benefits and rewards',
            accent: _loyaltyBurgundy,
            emphasized: true,
            onTap: () => Navigator.pushNamed(context, Routes.loyaltyScheme),
          ),
          const SizedBox(height: 10),
          _accountAction(
            icon: Icons.lock_reset_outlined,
            title: 'Reset Password',
            subtitle: 'Update your account password',
            onTap: _sendPasswordReset,
          ),
          const SizedBox(height: 10),
          _accountAction(
            icon: Icons.chat_outlined,
            title: 'Feedback, Ideas, Suggestions',
            subtitle: 'Help us make Heat Mat even better',
            onTap: _sendFeedbackEmail,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(
                    'Back',
                    style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    foregroundColor: _orange,
                    backgroundColor: const Color(0xAA171818),
                    side: BorderSide(color: _orange.withValues(alpha: 0.55)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _profileCard(UserProfileData p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF202121), Color(0xFF111212)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _orange.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color: _orange.withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 82,
                height: 82,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF33302D), Color(0xFF171818)],
                  ),
                  border: Border.all(color: _orange, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: _orange.withValues(alpha: 0.28),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Text(
                  _initials(p.fullName),
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editing ? 'Edit Your Profile' : p.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your account details and settings',
                      style: GoogleFonts.raleway(
                        color: atmosphericSecondaryText,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_editing) ...[
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _editing = true),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE9882A), Color(0xFFB94227)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _orange.withValues(alpha: 0.38),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          if (_editing)
            _editSection()
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0x991A1B1B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Column(
                children: [
                  _profileInfoRow(
                    Icons.apartment_rounded,
                    'Company Name',
                    p.companyName,
                  ),
                  _profileInfoRow(
                    Icons.mail_outline_rounded,
                    'Email Address',
                    p.email,
                  ),
                  _profileInfoRow(
                    Icons.phone_outlined,
                    'Phone Number',
                    p.phoneNumber,
                    showDivider: false,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final letters = parts.take(2).map((e) => e[0].toUpperCase()).join();
    return letters.isEmpty ? 'HM' : letters;
  }

  Widget _profileInfoRow(
    IconData icon,
    String label,
    String value, {
    bool showDivider = true,
  }) {
    final shown = value.trim().isEmpty ? 'Not provided' : value;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _orange.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: const Color(0xFFFF9A36), size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.raleway(
                    color: atmosphericSecondaryText,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  shown,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editSection() {
    return Column(
      children: [
        _outlinedField('Full Name', _nameCtrl),
        const SizedBox(height: 16),
        _outlinedField('Company Name', _companyCtrl),
        const SizedBox(height: 16),
        _outlinedField(
          'Phone Number',
          _phoneCtrl,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _outlinedField(
          'Email Address',
          _emailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final p = _profile!;
                  _nameCtrl.text = p.fullName;
                  _companyCtrl.text = p.companyName;
                  _phoneCtrl.text = p.phoneNumber;
                  _emailCtrl.text = p.email;
                  setState(() => _editing = false);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: _subtleBorder,
                  foregroundColor: _orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: _orange,
                  side: _subtleBorder,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save',
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _outlinedField(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.raleway(color: const Color(0xFFB7B7B7)),
        filled: true,
        fillColor: const Color(0xFF242525),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: _subtleBorder,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: _subtleBorder,
        ),
      ),
      cursorColor: _orange,
      style: GoogleFonts.raleway(color: Colors.white),
    );
  }

  Widget _sectionHeading(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF9A36), size: 25),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _documentCard({
    required IconData icon,
    required String title,
    required String description,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 122,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF282522), Color(0xFF151616)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.58)),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.1), blurRadius: 12),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.16),
                  border: Border.all(color: accent.withValues(alpha: 0.65)),
                ),
                child: Icon(icon, color: accent, size: 27),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.raleway(
                        color: atmosphericSecondaryText,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: accent, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color accent = _orange,
    bool emphasized = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            gradient: emphasized
                ? const LinearGradient(
                    colors: [Color(0xFF432018), Color(0xFF8E2E1E)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF242525), Color(0xFF171818)],
                  ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: emphasized
                  ? _orange.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: emphasized ? 0.26 : 0.08),
                  border: Border.all(
                    color: emphasized
                        ? const Color(0xFFFFA14A)
                        : Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(
                  icon,
                  color: emphasized ? const Color(0xFFFFB15C) : Colors.white70,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.raleway(
                        color: atmosphericSecondaryText,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: emphasized ? const Color(0xFFFFB15C) : Colors.white54,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
