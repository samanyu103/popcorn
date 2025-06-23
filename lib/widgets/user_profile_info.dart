// lib/widgets/user_profile_info.dart
import 'package:flutter/material.dart';
import '../screens/followers.dart';
import '../screens/following.dart';

class UserProfileInfo extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserProfileInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String uid = user['uid'];
    final String username = user['username'];
    final int age = user['age'];
    final String email = user['email'];
    final List<String> followers = List<String>.from(user['followers'] ?? []);
    final List<String> following = List<String>.from(user['following'] ?? []);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Username: $username', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text('Age: $age', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text('Email: $email', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FollowersListPage(userUid: uid),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      '${followers.length}',
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
                      builder: (_) => FollowingListPage(userUid: uid),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      '${following.length}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Text('Following'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
