import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/tile.dart';

class FollowersListPage extends StatelessWidget {
  final String userUid; // UID of the user whose followers we want

  const FollowersListPage({super.key, required this.userUid});

  Future<List<Map<String, dynamic>>> _getFollowers() async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();
    final List<String> followerUids = List<String>.from(
      userDoc.data()?['followers'] ?? [],
    );

    if (followerUids.isEmpty) return [];

    final usersRef = FirebaseFirestore.instance.collection('users');
    final snapshots = await Future.wait(
      followerUids.map((uid) => usersRef.doc(uid).get()),
    );
    return snapshots.map((doc) => doc.data()!).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Followers')),
      body: FutureBuilder(
        future: _getFollowers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final users = snapshot.data as List<Map<String, dynamic>>;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final profilePicture = user['profile_picture'] as String?;
              final username = user['username'] as String;
              return UserListTile(
                username: username,
                profilePicture: profilePicture,
              );
            },
          );
        },
      ),
    );
  }
}
