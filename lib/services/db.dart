import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/movie.dart';
import '../models/popcorn.dart';
import '../models/rating.dart';

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

  // DbService.dart

  Future<void> createUserProfile({
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
      'rating': [],
      'incomingPopcorns': [],
      'outgoingPopcorns': [],
      'incomingRequests': [],
      'outgoingRequests': [],
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    required String username,
    required String name,
    required String about,
    required String? profilePicture,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'username': username,
      'name': name,
      'about': about,
      'profile_picture': profilePicture,
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
      // print('Movie saved successfully!');
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

  static Future<void> requestPopcorn({
    required String fromUid,
    required String toUid,
  }) async {
    final fromDoc = FirebaseFirestore.instance.collection('users').doc(fromUid);
    final toDoc = FirebaseFirestore.instance.collection('users').doc(toUid);

    try {
      // Add to outgoingRequests of requester
      await fromDoc.update({
        'outgoingRequests': FieldValue.arrayUnion([toUid]),
      });

      // Add to incomingRequests of receiver
      await toDoc.update({
        'incomingRequests': FieldValue.arrayUnion([fromUid]),
      });

      // print('Popcorn request sent!');
    } catch (e) {
      print('Error requesting popcorn: $e');
    }
  }

  static Future<Movie?> getMovieUser(String uid, String tconst) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data();

    if (userData != null && userData['movies'] != null) {
      final moviesList = List<Map<String, dynamic>>.from(userData['movies']);
      final match = moviesList.firstWhere(
        (m) => m['tconst'] == tconst,
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        return Movie.fromMap(match);
      }
    }

    return null;
  }

  static Future<List<Movie>> getSeenByANotB(String aUid, String bUid) async {
    final aDoc =
        await FirebaseFirestore.instance.collection('users').doc(aUid).get();
    final bDoc =
        await FirebaseFirestore.instance.collection('users').doc(bUid).get();

    if (!aDoc.exists || !bDoc.exists) return [];

    final aMovies = List<Map<String, dynamic>>.from(aDoc['movies'] ?? []);
    final bMovies = List<Map<String, dynamic>>.from(bDoc['movies'] ?? []);

    final bTconsts = bMovies.map((m) => m['tconst']).toSet();

    return aMovies
        .where((m) => !bTconsts.contains(m['tconst']))
        .map((m) => Movie.fromMap(m))
        .toList();
  }

  static Future<Map<String, dynamic>?> fetchMovieAndUser(
    Popcorn popcorn,
  ) async {
    try {
      final fromDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(popcorn.fromUid)
              .get();
      final toDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(popcorn.toUid)
              .get();

      if (!fromDoc.exists || !toDoc.exists) return null;

      final fromData = fromDoc.data();
      final toData = toDoc.data();

      final fromUsername = fromData?['username'] ?? 'unknown';
      final toUsername = toData?['username'] ?? 'unknown';

      final movies = List<Map<String, dynamic>>.from(fromData?['movies'] ?? []);
      final movie = movies.firstWhere(
        (m) => m['tconst'] == popcorn.tconst,
        orElse: () => {},
      );

      if (movie.isEmpty) return null;

      return {
        'fromUsername': fromUsername,
        'toUsername': toUsername,
        'movie': movie,
      };
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  static Future<void> removeFromIncomingPopcorn(
    String tconst,
    String uid,
  ) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userSnap = await userRef.get();

    if (!userSnap.exists) return;

    final data = userSnap.data();
    final List<dynamic> incoming = data?['incomingPopcorns'] ?? [];

    // Find the matching popcorn(s)
    final updatedIncoming = List<Map<String, dynamic>>.from(incoming)
      ..removeWhere((pop) => pop['tconst'] == tconst);

    await userRef.update({'incomingPopcorns': updatedIncoming});
  }

  static Future<void> addRatingToUser(Rating rating, String uid) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await userDoc.update({
        'rating': FieldValue.arrayUnion([rating.toMap()]),
      });
      print('Rating added to user $uid!');
    } catch (e) {
      print('Error adding rating to user: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserByUsername(
    String username,
  ) async {
    final query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data() as Map<String, dynamic>;
    }
    return null;
  }
}
