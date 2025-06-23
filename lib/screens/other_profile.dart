import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'followers.dart';
import 'following.dart';

class OtherProfilePage extends StatelessWidget {
  final String username;

  const OtherProfilePage({super.key, required this.username});

  Future<Map<String, dynamic>?> _getUserData() async {
    final query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
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

    return Scaffold(
      appBar: AppBar(title: Text("$username's Profile")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User not found.'));
          }

          final user = snapshot.data!;
          final otherUserUid = user['uid'];
          final isFollowing =
              currentUser != null &&
              (List<String>.from(
                user['followers'] ?? [],
              ).contains(currentUser.uid));

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Username: ${user['username']}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  'Age: ${user['age']}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: ${user['email']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FollowersListPage(userUid: otherUserUid),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            '${(user['followers'] as List).length}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Text('Followers'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FollowingListPage(userUid: otherUserUid),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            '${(user['following'] as List).length}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Text('Following'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (currentUser != null && currentUser.uid != otherUserUid)
                  ElevatedButton(
                    onPressed: () async {
                      await _toggleFollow(user);
                      if (context.mounted) {
                        // Rebuild to reflect change
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => OtherProfilePage(username: username),
                          ),
                        );
                      }
                    },
                    child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
