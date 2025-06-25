import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class DbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      try {
        final map = doc.data() as Map<String, dynamic>;
        return AppUser.fromMap(map);
      } catch (e, stack) {
        print("Error in AppUser.fromMap: $e");
        print(stack);
      }
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
    required String name,
    required String about,
    required String? profilePicture,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'username': username,
      'name': name,
      'about': about,
      'profile_picture': profilePicture,
      'movies': 0,
      'followers': [],
      'following': [],
      'rating': 0,
    });
  }

  Future<AppUser?> getCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    // print("user: ${user.uid}");
    return getUserProfile(user.uid);
  }

  static Stream<QuerySnapshot> getUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('username')
        .snapshots();
  }
}
