import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class DbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<bool> isUsernameTaken(String username) async {
    final result =
        await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

    return result.docs.isNotEmpty;
  }

  Future<void> saveUserProfile({
    required String uid,
    required String email,
    required String username,
    required int age,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'username': username,
      'age': age,
      'followers': [],
      'following': [],
    });
  }

  Future<AppUser?> getCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return getUserProfile(user.uid);
  }
}
