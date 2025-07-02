import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth.dart';
import '../widgets/user_profile_info.dart';
import '../models/movie.dart';
import '../widgets/posts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 0--home
  // 1 -- search
  // 2 -- movies search
  // 3 -- matches
  // 4 --
  void _onNavTapped(BuildContext context, int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/search');
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/movies_search');
    }
    if (index == 3) {
      Navigator.pushNamed(context, '/matches');
    }

    if (index == 4) {
      Navigator.pushNamed(context, '/popcorn');
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
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.pushNamed(context, '/details');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer first
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  await _authService.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/contact');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context); // Close the drawer first
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                          'This will permanently delete your account. Are you sure?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  try {
                    await _authService.deleteAccount();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error deleting account: ${e.toString()}',
                          ),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
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
          // print("user $user");
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
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) => _onNavTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Text('🍿', style: TextStyle(fontSize: 24)),
            label: 'Popcorn',
          ),
        ],
      ),
    );
  }
}
