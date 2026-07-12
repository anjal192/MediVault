import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint("Firebase not initialized yet: $e");
      return null;
    }
  }

  // Get current user ID
  String? get currentUid {
    return _auth?.currentUser?.uid ?? "john_doe_uid";
  }

  // Get current user email
  String? get currentUserEmail {
    return _auth?.currentUser?.email ?? "john.doe@medivault.com";
  }

  // Check if user is logged in
  bool get isLoggedIn {
    return _auth?.currentUser != null;
  }

  // Sign up with Email and Password
  Future<UserCredential?> signUp(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      debugPrint("SIMULATED SIGN UP: $email");
      return null;
    }
    return await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Log in with Email and Password
  Future<UserCredential?> logIn(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      debugPrint("SIMULATED LOGIN: $email");
      return null;
    }
    return await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Forgot Password Reset Email
  Future<void> sendPasswordReset(String email) async {
    final auth = _auth;
    if (auth == null) {
      debugPrint("SIMULATED PASSWORD RESET SENT: $email");
      return;
    }
    await auth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
  Future<void> logOut() async {
    final auth = _auth;
    if (auth == null) {
      debugPrint("SIMULATED SIGN OUT");
      return;
    }
    await auth.signOut();
  }

  // Sign Out alias
  Future<void> signOut() => logOut();

  // Current user
  User? get currentUser => _auth?.currentUser;
}
