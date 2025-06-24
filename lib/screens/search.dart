import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'other_profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  late final Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    // Initialize once to avoid repeated reads :contentReference[oaicite:2]{index=2}
    _usersStream = FirebaseFirestore.instance
        .collection('users')
        .orderBy('username')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
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
          final filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final username = (data['username'] as String).toLowerCase();
            return username.contains(_searchText);
          }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, i) {
              final data = filteredDocs[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['username']),
                subtitle: Text(data['email']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OtherProfilePage(username: data['username']),
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

