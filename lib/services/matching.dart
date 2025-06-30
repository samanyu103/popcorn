import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

Future<List<AppUser>> findTopMatches(AppUser currentUser, {int k = 5}) async {
  final userCollection = FirebaseFirestore.instance.collection('users');
  final snapshot = await userCollection.get();

  Set<String> currentMovieTconsts =
      currentUser.movies.map((m) => m.tconst).toSet();
  Set<String> followingSet = currentUser.following.toSet();

  List<AppUser> candidates = [];

  for (final doc in snapshot.docs) {
    if (doc.id == currentUser.uid) continue;

    final data = doc.data();
    final otherUser = AppUser.fromMap(data);

    if (followingSet.contains(otherUser.uid)) continue;

    final otherMovieTconsts = otherUser.movies.map((m) => m.tconst).toSet();

    final commonMoviesCount =
        currentMovieTconsts.intersection(otherMovieTconsts).length;

    if (commonMoviesCount > 0) {
      candidates.add(otherUser);
    }
  }

  candidates.sort((a, b) {
    final commonA =
        currentMovieTconsts
            .intersection(a.movies.map((m) => m.tconst).toSet())
            .length;
    final commonB =
        currentMovieTconsts
            .intersection(b.movies.map((m) => m.tconst).toSet())
            .length;

    if (commonA != commonB) return commonB - commonA;

    final seenA = a.movies.where((m) => m.seen).length;
    final seenB = b.movies.where((m) => m.seen).length;

    return seenB - seenA;
  });

  return candidates.take(k).toList();
}
