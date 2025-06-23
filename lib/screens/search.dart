import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'other_profile.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usersStream =
        FirebaseFirestore.instance
            .collection('users')
            .orderBy('username')
            .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Search Users')),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(user['username']),
                subtitle: Text(user['email']),
                onTap: () {
                  final username = user['username'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtherProfilePage(username: username),
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
