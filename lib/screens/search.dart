import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:popcorn/services/db.dart';
import 'other_profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchText = '';
  late final Stream<QuerySnapshot> _usersStream;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _usersStream = DbService.getUsersStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search users…',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _searchText = value.toLowerCase());
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;

          final filteredDocs =
              allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final username = (data['username'] as String).toLowerCase();
                final uid = data['uid'] as String;
                return uid != currentUid && username.contains(_searchText);
              }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, i) {
              final data = filteredDocs[i].data() as Map<String, dynamic>;
              final profilePicture = data['profile_picture'] as String?;
              final username = data['username'] as String;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      profilePicture != null
                          ? NetworkImage(profilePicture)
                          : null,
                  child:
                      profilePicture == null ? const Icon(Icons.person) : null,
                ),
                title: Text(username),
                onTap: () {
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
