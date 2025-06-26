import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth.dart';
import '../widgets/user_profile_info.dart';
import '../models/movie.dart';
import '../widgets/posts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onNavTapped(BuildContext context, int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/movies_search');
    }
    if (index == 2) {
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

          final user = snapshot.data!.data() as Map<String, dynamic>?;

          if (user == null) {
            return const Center(child: Text('User data not found.'));
          }

          final rawMovies = user['movies'] as List<dynamic>? ?? [];
          final movies = rawMovies.map((m) => Movie.fromMap(m)).toList();

          return Column(
            children: [
              UserProfileInfo(user: user),
              const SizedBox(height: 10),
              Expanded(child: MovieGrid(movies: movies, uid: user['uid'])),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => _onNavTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Post',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
