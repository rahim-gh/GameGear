import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_gear/screen/authentication/login_screen.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser {
    try {
      // Attempt to retrieve the current user
      final user = _auth.currentUser;
      if (user != null) {
        applog('Current user retrieved with UID: ${user.uid}',
            level: Level.info);
      } else {
        applog('No current user found', level: Level.info);
      }
      return user;
    } catch (e) {
      applog('Error while retrieving current user: $e', level: Level.error);
      return null; // Return null in case of error
    }
  }

  /// Signs in the user using Firebase Auth with email and password.
  /// Throws a FirebaseAuthException with a user-friendly message.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      applog('User signed in with UID: ${credential.user?.uid}',
          level: Level.info);
      return credential;
    } on FirebaseAuthException catch (e) {
      final friendlyError = _mapFirebaseError(e);
      applog('FirebaseAuthException during signIn: ${e.code} - $friendlyError',
          level: Level.error);
      throw FirebaseAuthException(code: e.code, message: friendlyError);
    } catch (e) {
      applog('Unexpected error during signIn: $e', level: Level.error);
      rethrow;
    }
  }

  /// Creates a new user with Firebase Auth using email and password.
  /// Throws a FirebaseAuthException with a user-friendly message.
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
      applog('User signed up with UID: ${credential.user?.uid}',
          level: Level.info);
      return credential;
    } on FirebaseAuthException catch (e) {
      final friendlyError = _mapFirebaseError(e);
      applog('FirebaseAuthException during signUp: ${e.code} - $friendlyError',
          level: Level.error);
      throw FirebaseAuthException(code: e.code, message: friendlyError);
    } catch (e) {
      applog('Unexpected error during signUp: $e', level: Level.error);
      rethrow;
    }
  }

  /// Handles logging out the current user.
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      // Clear any user-specific data here if needed
      // For example, you might want to clear user preferences or cached data

      // Navigate to the login screen
      // Assuming you have a navigation service or context available
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // builder: (context) => HomeScreen(uid: credential.user!.uid)),
          builder: (context) => LoginScreen(),
        ),
      );

      applog('User successfully signed out', level: Level.info);
    } catch (e) {
      applog('Error during sign out: $e', level: Level.error);
      rethrow;
    }
  }

  /// Maps Firebase error codes to more user-friendly messages.
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

  /// Checks if the user is authenticated and handles the logic accordingly.
  Future<void> checkAuthenticationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        applog('User is not authenticated', level: Level.info);
        // Optionally, redirect the user to the login screen.
      } else {
        applog('User is authenticated with UID: ${user.uid}',
            level: Level.info);
      }
    } catch (e) {
      applog('Error during authentication check: $e', level: Level.error);
      rethrow;
    }
  }
}
