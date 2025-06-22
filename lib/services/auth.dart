import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get userChanges => _auth.authStateChanges();

  Future<AppUser?> getCurrentUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Future<void> updateUserDetails(String name, int age) async {
  //   final user = _auth.currentUser;
  //   if (user == null) return;

  //   await _firestore.collection('users').doc(user.uid).set({
  //     'uid': user.uid,
  //     'email': user.email,
  //     'name': name,
  //     'age': age,
  //   });
  // }
}
