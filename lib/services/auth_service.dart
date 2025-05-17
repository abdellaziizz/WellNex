import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

class AuthService {
  final FirebaseService _firebaseService;

  AuthService(this._firebaseService);

  User? get currentUser => _firebaseService.currentUser;
  Stream<User?> get authStateChanges => _firebaseService.authStateChanges;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      developer.log('Signing in with email: $email');
      return await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      developer.log('Auth error: ${e.code}');
      throw _parseAuthError(e);
    } catch (e) {
      developer.log('Unexpected error', error: e);
      throw 'Login failed. Please try again.';
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      developer.log('Signing up with email: $email');
      return await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      developer.log('Signup error: ${e.code}');
      throw _parseAuthError(e);
    } catch (e) {
      developer.log('Unexpected signup error', error: e);
      throw 'Signup failed. Please try again.';
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.auth.signOut();
    } catch (e) {
      throw 'Sign out failed. Please try again.';
    }
  }

  String _parseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'Account disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak';
      case 'too-many-requests':
        return 'Too many requests. Try again later';
      case 'network-request-failed':
        return 'Network error occurred. Check your connection';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}