// lib/auth/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Register a new user and create their profile in `users/{uid}`
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
    required String phoneNumber,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Set displayName for convenience
    await cred.user?.updateDisplayName(fullName);

    final uid = cred.user!.uid;

    // IMPORTANT: Write to 'users' (not 'user_profiles')
    final profileDoc = _db.collection('users').doc(uid);
    await profileDoc.set({
      'uid': uid,
      'fullName': fullName,
      'companyName': companyName,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Live stream of the user profile document in `users/{uid}`
  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Fetch the user profile once (optional)
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return snap.data();
  }

  /// Optional: Update profile fields
  Future<void> updateUserProfile({
    required String fullName,
    required String companyName,
    required String phoneNumber,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).set({
      'fullName': fullName,
      'companyName': companyName,
      'phoneNumber': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _auth.currentUser?.updateDisplayName(fullName);
  }

  /// Optional: Update email
  Future<void> updateUserEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.updateEmail(newEmail);
    await _db.collection('users').doc(user.uid).set({
      'email': newEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
