import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'other_profile.dart';

class FollowingListPage extends StatelessWidget {
  final String userUid; // UID of the user whose following list we want

  const FollowingListPage({super.key, required this.userUid});

  Future<List<Map<String, dynamic>>> _getFollowing() async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();
    final List<String> followingUids = List<String>.from(
      userDoc.data()?['following'] ?? [],
    );

    if (followingUids.isEmpty) return [];

    final usersRef = FirebaseFirestore.instance.collection('users');
    final snapshots = await Future.wait(
      followingUids.map((uid) => usersRef.doc(uid).get()),
    );
    return snapshots.map((doc) => doc.data()!).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: FutureBuilder(
        future: _getFollowing(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data as List<Map<String, dynamic>>;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['username']),
                subtitle: Text(user['email']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => OtherProfilePage(username: user['username']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
