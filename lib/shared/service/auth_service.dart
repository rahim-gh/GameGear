import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../screen/authentication/login_screen.dart';
import '../utils/logger_util.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser {
    try {
      logs('Fetching current user...', level: Level.debug);
      final user = _auth.currentUser;
      if (user != null) {
        logs('Current user retrieved with UID: ${user.uid}', level: Level.info);
      } else {
        logs('No current user found', level: Level.info);
      }
      return user;
    } catch (e) {
      logs('Error while retrieving current user: $e', level: Level.error);
      return null;
    }
  }

  /// Reauthenticates the current user using the provided current password.
  Future<void> reauthenticateUser(String currentPassword) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      logs('User reauthenticated successfully', level: Level.info);
    } else {
      logs('Reauthentication failed: No user or email found',
          level: Level.error);
    }
  }

  /// Signs in the user using Firebase Auth with email and password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      logs('User signed in with UID: ${credential.user?.uid}',
          level: Level.info);
      return credential;
    } on FirebaseAuthException catch (e) {
      final friendlyError = _mapFirebaseError(e);
      logs('FirebaseAuthException during signIn: ${e.code} - $friendlyError',
          level: Level.error);
      throw FirebaseAuthException(code: e.code, message: friendlyError);
    } catch (e) {
      logs('Unexpected error during signIn: $e', level: Level.error);
      rethrow;
    }
  }

  /// Creates a new user with Firebase Auth using email and password.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      logs('User signed up with UID: ${credential.user?.uid}',
          level: Level.info);
      return credential;
    } on FirebaseAuthException catch (e) {
      final friendlyError = _mapFirebaseError(e);
      logs('FirebaseAuthException during signUp: ${e.code} - $friendlyError',
          level: Level.error);
      throw FirebaseAuthException(code: e.code, message: friendlyError);
    } catch (e) {
      logs('Unexpected error during signUp: $e', level: Level.error);
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      logs('User successfully signed out', level: Level.info);
    } catch (e) {
      logs('Error during sign out: $e', level: Level.error);
      rethrow;
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account exists for this email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'operation-not-allowed':
        return 'Email/Password accounts are not enabled.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-credential':
        return 'The credential provided is invalid or has expired.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error occurred. Please check your connection.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  Future<void> checkAuthenticationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        logs('User is not authenticated', level: Level.info);
      } else {
        logs('User is authenticated with UID: ${user.uid}', level: Level.info);
      }
    } catch (e) {
      logs('Error during authentication check: $e', level: Level.error);
      rethrow;
    }
  }
}
