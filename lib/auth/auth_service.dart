// lib/auth/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void>? _googleInitialization;

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

  /// Google sign-in for Android and iOS.
  ///
  /// A null result means that the user dismissed Google's account chooser.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuthentication = googleUser.authentication;
      final idToken = googleAuthentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google did not return an identity token.');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final current = _auth.currentUser;
      final result = current != null && current.isAnonymous
          ? await current.linkWithCredential(credential)
          : await _auth.signInWithCredential(credential);
      await _ensureUserDoc(result.user);
      return result;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  /// Apple sign-in through Firebase's native provider flow.
  Future<UserCredential> signInWithApple() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    final current = _auth.currentUser;
    final result = current != null && current.isAnonymous
        ? await current.linkWithProvider(provider)
        : await _auth.signInWithProvider(provider);
    await _ensureUserDoc(result.user);
    return result;
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
      'fullName': fullName?.trim(),
      'company': company?.trim(),
      'companyName': company?.trim(),
      'phone': phone?.trim(),
      'phoneNumber': phone?.trim(),
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
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Firebase is already signed out. A missing Google configuration must
      // not prevent the user from leaving their Heat Mat account.
    }
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
      if (name != null && name.trim().isNotEmpty) ...{
        'name': name.trim(),
        'fullName': name.trim(),
      },
      if (company != null && company.trim().isNotEmpty) ...{
        'company': company.trim(),
        'companyName': company.trim(),
      },
      if (phone != null && phone.trim().isNotEmpty) ...{
        'phone': phone.trim(),
        'phoneNumber': phone.trim(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (data.isEmpty) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  }

  /// Whether the signed-in account still needs the business details that
  /// Google and Apple do not provide.
  Future<bool> needsProfileCompletion() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return false;

    final snapshot = await _db.collection('users').doc(user.uid).get();
    final data = snapshot.data() ?? const <String, dynamic>{};
    final company = _firstNonEmpty(data['companyName'], data['company']);
    final phone = _firstNonEmpty(data['phoneNumber'], data['phone']);
    return company.isEmpty || phone.isEmpty;
  }

  /// Saves profile details using both the original and current field names.
  /// This keeps existing warranty, quote and profile screens compatible.
  Future<void> completeSocialProfile({
    required String company,
    required String phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    final trimmedCompany = company.trim();
    final trimmedPhone = phone.trim();
    if (trimmedCompany.isEmpty || trimmedPhone.isEmpty) {
      throw ArgumentError('Company and phone are required.');
    }

    final displayName = user.displayName?.trim() ?? '';
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      if (displayName.isNotEmpty) ...{
        'name': displayName,
        'fullName': displayName,
      },
      'company': trimmedCompany,
      'companyName': trimmedCompany,
      'phone': trimmedPhone,
      'phoneNumber': trimmedPhone,
      'isAnonymous': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
      final displayName = user.displayName?.trim() ?? '';
      await ref.set({
        'email': user.email,
        if (displayName.isNotEmpty) ...{
          'name': displayName,
          'fullName': displayName,
        },
        if (user.photoURL?.trim().isNotEmpty ?? false)
          'photoUrl': user.photoURL!.trim(),
        'providerIds': user.providerData
            .map((info) => info.providerId)
            .toList(),
        'isAnonymous': anonymous || user.isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInitialization ??= GoogleSignIn.instance.initialize();
  }

  static String _firstNonEmpty(dynamic first, dynamic second) {
    final firstValue = first is String ? first.trim() : '';
    if (firstValue.isNotEmpty) return firstValue;
    return second is String ? second.trim() : '';
  }
}
