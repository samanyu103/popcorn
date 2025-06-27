import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';
import '../widgets/user_profile_info.dart';
import '../widgets/symmetric_difference.dart';

class OtherProfilePage extends StatelessWidget {
  final String username;

  const OtherProfilePage({super.key, required this.username});

  Future<String?> _getUserUidByUsername() async {
    final query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    return null;
  }

  Future<void> _toggleFollow(Map<String, dynamic> user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final otherUserUid = user['uid'];

    if (currentUser == null || currentUser.uid == otherUserUid) return;

    final currentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);
    final otherRef = FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserUid);

    final currentSnap = await currentRef.get();
    final otherSnap = await otherRef.get();

    final currentFollowing = List<String>.from(currentSnap['following'] ?? []);
    final otherFollowers = List<String>.from(otherSnap['followers'] ?? []);

    if (currentFollowing.contains(otherUserUid)) {
      currentFollowing.remove(otherUserUid);
      otherFollowers.remove(currentUser.uid);
    } else {
      currentFollowing.add(otherUserUid);
      otherFollowers.add(currentUser.uid);
    }

    await currentRef.update({'following': currentFollowing});
    await otherRef.update({'followers': otherFollowers});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<String?>(
      future: _getUserUidByUsername(),
      builder: (context, uidSnapshot) {
        if (uidSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final uid = uidSnapshot.data;

        if (uid == null) {
          return const Scaffold(body: Center(child: Text('User not found.')));
        }

        return StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('User not found.')),
              );
            }

            final user = snapshot.data!.data() as Map<String, dynamic>;
            print("current user $currentUser, other user $user");
            final otherUserUid = user['uid'];
            final followers = List<String>.from(user['followers'] ?? []);
            final isFollowing =
                currentUser != null && followers.contains(currentUser.uid);

            final rawMovies = user['movies'] as List<dynamic>? ?? [];
            final movies = rawMovies.map((m) => Movie.fromMap(m)).toList();

            return Scaffold(
              appBar: AppBar(title: Text("$username's Profile")),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UserProfileInfo(user: user),
                    const SizedBox(height: 20),
                    if (currentUser != null && currentUser.uid != otherUserUid)
                      ElevatedButton(
                        onPressed: () => _toggleFollow(user),
                        child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                      ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: CompareMoviesWidget(
                        currentUid: currentUser!.uid,
                        otherUid: otherUserUid,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
