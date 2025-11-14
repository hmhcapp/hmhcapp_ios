// lib/auth/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of auth state changes for the current device.
  Stream<User?> get authState => _auth.authStateChanges();

  /// Currently signed-in user, if any.
  User? get currentUser => _auth.currentUser;

  /// Email/password sign-in.
  Future<UserCredential> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _ensureUserDoc(cred.user);
    return cred;
  }

  /// Anonymous sign-in (for guest access).
  Future<UserCredential> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    await _ensureUserDoc(cred.user, anonymous: true);
    return cred;
  }

  /// Backwards-compatible register used by existing UI.
  ///
  /// Supports:
  /// - companyName / company
  /// - phoneNumber / phone
  ///
  /// and forwards to [registerWithEmail].
  Future<UserCredential> register({
    required String email,
    required String password,
    String? fullName,
    String? companyName,
    String? company,
    String? phoneNumber,
    String? phone,
  }) {
    final resolvedCompany = companyName ?? company;
    final resolvedPhone = phoneNumber ?? phone;

    return registerWithEmail(
      email: email,
      password: password,
      fullName: fullName,
      company: resolvedCompany,
      phone: resolvedPhone,
    );
  }

  /// Core registration implementation.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? fullName,
    String? company,
    String? phone,
  }) async {
    final trimmedEmail = email.trim();

    final cred = await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'email': trimmedEmail,
      'name': fullName?.trim(),
      'company': company?.trim(),
      'phone': phone?.trim(),
      'isAnonymous': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return cred;
  }

  /// Send password reset e-mail.
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign out current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Update profile fields in Firestore.
  Future<void> updateUserProfile({
    String? name,
    String? company,
    String? phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final data = <String, dynamic>{
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (company != null && company.trim().isNotEmpty) 'company': company.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (data.isEmpty) return;

    await _db.collection('users').doc(user.uid).set(
          data,
          SetOptions(merge: true),
        );
  }

  /// Change e-mail in Auth and mirror it in Firestore.
  Future<void> updateUserEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final trimmed = newEmail.trim();
    await user.updateEmail(trimmed);

    await _db.collection('users').doc(user.uid).set({
      'email': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _ensureUserDoc(User? user, {bool anonymous = false}) async {
    if (user == null) return;

    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'email': user.email,
        'isAnonymous': anonymous || user.isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
