import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/movie.dart';

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
      'movies': [],
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

  static Future<void> addMovieToUser(Movie movie, String uid) async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      final userSnapshot = await userDocRef.get();
      final userData = userSnapshot.data();

      if (userData == null) {
        print('User not found.');
        return;
      }

      List<Map<String, dynamic>> movies = List<Map<String, dynamic>>.from(
        userData['movies'] ?? [],
      );

      final index = movies.indexWhere((m) => m['tconst'] == movie.tconst);

      if (index != -1) {
        // ✅ Replace existing movie
        movies[index] = movie.toMap();
      } else {
        // ➕ Add new movie
        movies.add(movie.toMap());
      }

      await userDocRef.update({'movies': movies});
      print('Movie saved successfully!');
    } catch (e) {
      print('Error saving movie: $e');
    }
  }

  static Future<void> removeMovieFromUser(String tconst, String uid) async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userDoc = await userDocRef.get();
    final userData = userDoc.data();

    if (userData != null && userData['movies'] != null) {
      final moviesList = List<Map<String, dynamic>>.from(userData['movies']);
      final updatedList =
          moviesList.where((m) => m['tconst'] != tconst).toList();

      await userDocRef.update({'movies': updatedList});
    }
  }

  static Future<List<Movie>> getUserMovies(String uid) async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!docSnapshot.exists) return [];

      final data = docSnapshot.data();
      if (data == null || !data.containsKey('movies')) return [];

      final moviesData = List<Map<String, dynamic>>.from(
        data['movies'].map((e) => Map<String, dynamic>.from(e)),
      );

      return moviesData.map((movieMap) => Movie.fromMap(movieMap)).toList();
    } catch (e) {
      print('Error fetching movies for user $uid: $e');
      return [];
    }
  }
}
