import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _roleSub;

  static const String allowedEmailDomain = 'mdt.gov.mk';

  Map<String, dynamic>? user;
  String? role;
  bool isInitializing = true;

  Future<void> init() async {
    try {
      final current = _auth.currentUser;
      await _handleAuthChange(current);
      _auth.authStateChanges().listen((u) async {
        await _handleAuthChange(u);
      });
    } catch (e) {
      debugPrint('Auth init error: $e');
      role = null;
      user = null;
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _handleAuthChange(User? firebaseUser) async {
    await _roleSub?.cancel();
    if (firebaseUser == null) {
      user = null;
      role = null;
      return;
    }

    user = {
      'uid': firebaseUser.uid,
      'email': firebaseUser.email,
    };

    final doc = _db.collection('users').doc(firebaseUser.uid);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'email': firebaseUser.email ?? '',
        'role': 'staff',
        'createdAt': FieldValue.serverTimestamp(),
      });
      role = 'staff';
    } else {
      role = (snap.data()?['role'] ?? 'staff') as String;
    }
    _roleSub = doc.snapshots().listen((docSnap) {
      role = (docSnap.data()?['role'] ?? 'staff') as String;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      if (!normalizedEmail.endsWith('@$allowedEmailDomain')) {
        throw FirebaseAuthException(
          code: 'invalid-email-domain',
          message: 'Only @$allowedEmailDomain accounts can be created.',
        );
      }
      await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    user = null;
    role = null;
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Email is required.',
      );
    }
    await _auth.sendPasswordResetEmail(email: normalizedEmail);
  }
}
