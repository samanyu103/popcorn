import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/db.dart';
import '../models/app_user.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dbService = DbService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => authService.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<AppUser?>(
        future: dbService.getCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          }

          final user = snapshot.data!;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Name: ${user.name}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text('Age: ${user.age}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                Text(
                  'Email: ${user.email}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
