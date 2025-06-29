import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String?> signUp(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.sendEmailVerification();
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        // case 'weak-password':
        //   return 'Password should be at least 6 characters.';
        // case 'operation-not-allowed':
        //   return 'Email/password accounts are not enabled.';
        default:
          return 'An unexpected error occurred. (${e.code})';
      }
    } catch (e) {
      return 'An unknown error occurred.';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'The email address is badly formatted.';
        // case 'user-disabled':
        //   return 'This account has been disabled.';
        // case 'user-not-found':
        //   return 'No user found for this email.';
        // case 'wrong-password':
        //   return 'Incorrect password.';
        case 'invalid-credential':
          return 'Incorrect email or password.';
        default:
          return 'An unexpected error occurred. (${e.code})';
      }
    } catch (e) {
      return 'An unknown error occurred.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get userChanges => _auth.authStateChanges();

  String? getCurrentUserId() => _auth.currentUser?.uid;
  String? getCurrentUserEmail() => _auth.currentUser?.email;
}
