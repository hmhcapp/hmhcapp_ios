// lib/auth/profile_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes.dart';

const _orange = Color(0xFFDD4F2E);
const _dark = Color(0xFF333333);
const _greyBtn = Color(0xFF555555);
const _warnRed = Color(0xFFC00000);
const _warrantyYellow = Color(0xFFF1B227);
const _quotesOrange = Color(0xFFEFA528);

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

  factory UserProfileData.fromMap(Map<String, dynamic> m) {
    return UserProfileData(
      fullName: (m['fullName'] as String?)?.trim() ?? '',
      companyName: (m['companyName'] as String?)?.trim() ?? '',
      phoneNumber: (m['phoneNumber'] as String?)?.trim() ?? '',
      email: (m['email'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'companyName': companyName,
        'phoneNumber': phoneNumber,
        'email': email,
      };
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

  bool _showDeleteDialog = false;
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
      // Defer until after first frame to avoid Navigator during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (r) => false);
      });
      return;
    }

    // Live listen to users/{uid} for immediate UI updates (e.g. just after register).
    _state = _ProfileState.loading;
    _sub = _db.collection('users').doc(user.uid).snapshots().listen((doc) {
      if (!mounted) return;
      if (!doc.exists || doc.data() == null) {
        setState(() {
          _state = _ProfileState.notFound;
        });
        return;
      }
      final data = UserProfileData.fromMap(doc.data()!);
      _profile = data;

      // Set edit fields
      _nameCtrl.text = data.fullName;
      _companyCtrl.text = data.companyName;
      _phoneCtrl.text = data.phoneNumber;
      _emailCtrl.text = data.email;

      setState(() {
        _state = _ProfileState.loaded;
      });
    }, onError: (_) {
      if (!mounted) return;
      setState(() => _state = _ProfileState.notFound);
    });
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
      await _db.collection('users').doc(user.uid).set(updated.toMap(), SetOptions(merge: true));

      // 2) If email changed, update Auth email
      if (updated.email.isNotEmpty && updated.email != user.email) {
        await user.updateEmail(updated.email);
      }

      _profile = updated;
      _editing = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
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

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _db.collection('users').doc(user.uid).delete().catchError((_) {});
      await user.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted')),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (r) => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out')),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Colors.white, Color(0xFFF2F2F2)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      // No AppBar, we replicate the Kotlin layout
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Column(
          children: [
            // --- Header Image and Logo ---
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
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

            // --- Scrollable Form Content ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24 + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    switch (_state) {
                      _ProfileState.loading => _loading(),
                      _ProfileState.notFound => _notFound(),
                      _ProfileState.loaded => _loaded(),
                    },
                  ],
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
          style: GoogleFonts.raleway(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'We could not load your profile. Please sign out and sign in again, or contact support.',
          style: GoogleFonts.raleway(color: Colors.grey[700]),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Logout', style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _loaded() {
    final p = _profile!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- Header with Name and Edit Button ---
        Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                _editing ? 'Edit Your Profile' : p.fullName,
                style: GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold, color: _dark),
                textAlign: TextAlign.center,
              ),
            ),
            if (!_editing)
              Positioned(
                right: 0,
                child: IconButton(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit, color: _orange),
                  tooltip: 'Edit Profile',
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your account details and settings below.',
          style: GoogleFonts.raleway(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Toggle between View and Edit sections
        if (_editing) _editSection() else _viewSection(p),
      ],
    );
  }

  Widget _editSection() {
    return Column(
      children: [
        _outlinedField('Full Name', _nameCtrl),
        const SizedBox(height: 16),
        _outlinedField('Company Name', _companyCtrl),
        const SizedBox(height: 16),
        _outlinedField('Phone Number', _phoneCtrl, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _outlinedField('Email Address', _emailCtrl, keyboardType: TextInputType.emailAddress),
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
                  side: const BorderSide(color: _orange),
                  foregroundColor: _orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Cancel', style: GoogleFonts.raleway(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: _orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _saving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Save', style: GoogleFonts.raleway(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _outlinedField(String label, TextEditingController ctrl, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
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

  Widget _viewSection(UserProfileData p) {
    return Column(
      children: [
        _infoRow('Company Name', p.companyName),
        _infoRow('Email Address', p.email),
        _infoRow('Phone Number', p.phoneNumber),
        const SizedBox(height: 24),

        // --- Your Saved Documents ---
        Text(
          'Your Saved Documents',
          style: GoogleFonts.raleway(fontWeight: FontWeight.bold, fontSize: 18, color: _dark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, Routes.registerWarranty, arguments: 1),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: _warrantyYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.workspace_premium, color: Colors.white),
                label: Text('Warranties',
                    style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, Routes.getAQuoteCategorySelection, arguments: 1),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: _quotesOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.edit_note, color: Colors.white),
                label: Text('Quotes',
                    style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // --- Account Management ---
        Text(
          'Account Management',
          style: GoogleFonts.raleway(fontWeight: FontWeight.bold, fontSize: 18, color: _dark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sendPasswordReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: _greyBtn,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Reset Password',
                style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() => _showDeleteDialog = true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _warnRed),
              foregroundColor: _warnRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete My Account', style: GoogleFonts.raleway(fontWeight: FontWeight.bold)),
          ),
        ),

        const SizedBox(height: 32),

        // --- Back and Logout buttons ---
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, Routes.home),
                icon: const Icon(Icons.arrow_back),
                label: Text('Back', style: GoogleFonts.raleway(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: _orange),
                  foregroundColor: _orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                label: Text('Logout',
                    style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: _orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_showDeleteDialog) _deleteDialog(),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    final show = value.trim().isNotEmpty ? value : 'Not provided';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.raleway(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(show, style: GoogleFonts.raleway(fontSize: 16, color: _dark)),
          const Divider(color: Color(0xFFDDDDDD), height: 16),
        ],
      ),
    );
  }

  Widget _deleteDialog() {
    return AlertDialog(
      title: Text('Delete Account', style: GoogleFonts.raleway(fontWeight: FontWeight.bold)),
      content: Text(
        'Are you sure you want to delete your account and all associated data? This action is irreversible.',
        style: GoogleFonts.raleway(),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _showDeleteDialog = false),
          child: Text('Cancel', style: GoogleFonts.raleway(color: _dark)),
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() => _showDeleteDialog = false);
            await _deleteAccount();
          },
          style: ElevatedButton.styleFrom(backgroundColor: _warnRed),
          child: Text('Delete', style: GoogleFonts.raleway(color: Colors.white)),
        ),
      ],
    );
  }
}
