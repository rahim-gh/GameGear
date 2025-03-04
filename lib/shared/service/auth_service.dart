import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      applog('User signed in with uid: ${credential.user?.uid}', level: Level.info);
      return credential;
    } on FirebaseAuthException catch (e) {
      final friendlyError = _mapFirebaseError(e);
      applog('FirebaseAuthException during signIn: ${e.code} - $friendlyError', level: Level.error);
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
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      applog('User signed up with uid: ${credential.user?.uid}', level: Level.info);
      return credential;
    } on FirebaseAuthException catch (e) {
      final friendlyError = _mapFirebaseError(e);
      applog('FirebaseAuthException during signUp: ${e.code} - $friendlyError', level: Level.error);
      throw FirebaseAuthException(code: e.code, message: friendlyError);
    } catch (e) {
      applog('Unexpected error during signUp: $e', level: Level.error);
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
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
