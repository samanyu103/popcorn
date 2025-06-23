import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth.dart';
import 'followers.dart'; // FollowersListPage
import 'following.dart'; // FollowingListPage

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onNavTapped(BuildContext context, int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("No user signed in.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text('User data not found.'));
          }

          final username = data['username'];
          final age = data['age'];
          final email = data['email'];
          final followers = List<String>.from(data['followers'] ?? []);
          final following = List<String>.from(data['following'] ?? []);
          final uid = data['uid'];

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Username: $username',
                  style: const TextStyle(fontSize: 20),
                ),
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
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => _onNavTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
