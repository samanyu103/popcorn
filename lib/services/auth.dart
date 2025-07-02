import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete Firestore document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        print('Firestore user document deleted.');

        // Delete Firebase Auth account
        await user.delete();
        print('Firebase Auth user deleted.');
      } else {
        // print('No user currently signed in.');
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow; // Re-throw the error so calling code can handle it (e.g., show Snackbar)
    }
  }

  Stream<User?> get userChanges => _auth.authStateChanges();

  String? getCurrentUserId() => _auth.currentUser?.uid;
  String? getCurrentUserEmail() => _auth.currentUser?.email;

  // Future<String?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //     if (googleUser == null) return 'Google sign-in aborted';

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     await _auth.signInWithCredential(credential);
  //     return null; // success
  //   } on FirebaseAuthException catch (e) {
  //     return e.message ?? 'Google sign-in failed';
  //   } catch (e, stack) {
  //     print('Unexpected error: $e');
  //     print('Stack trace: $stack');
  //     return e.toString(); // this will help you see the actual error message
  //   }
  // }

  // Future<String?> signInWithApple() async {
  //   try {
  //     final appleCredential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //     );

  //     final oauthCredential = OAuthProvider("apple.com").credential(
  //       idToken: appleCredential.identityToken,
  //       accessToken: appleCredential.authorizationCode,
  //     );

  //     await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  //     return null;
  //   } on FirebaseAuthException catch (e) {
  //     return e.message ?? 'Firebase Apple sign-in failed';
  //   } catch (e) {
  //     print(e.toString());
  //     return e.toString();
  //   }
  // }
}
