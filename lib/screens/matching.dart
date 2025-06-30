import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/db.dart'; // getCurrentUserProfile()
import '../services/matching.dart'; // findTopMatches(AppUser currentUser)
import 'other_profile.dart'; // OtherProfilePage

class FindMatchesPage extends StatefulWidget {
  const FindMatchesPage({super.key});

  @override
  State<FindMatchesPage> createState() => _FindMatchesPageState();
}

class _FindMatchesPageState extends State<FindMatchesPage> {
  late Future<List<AppUser>> _matchesFuture;

  Future<List<AppUser>> _loadMatches() async {
    final currentUser = await DbService().getCurrentUserProfile();
    if (currentUser == null) throw Exception('Current user not found');
    return await findTopMatches(currentUser);
  }

  @override
  void initState() {
    super.initState();
    _matchesFuture = _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Matches')),
      body: FutureBuilder<List<AppUser>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final matches = snapshot.data ?? [];

          if (matches.isEmpty) {
            return const Center(child: Text('No matches found.'));
          }

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final user = matches[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      user.profilePicture != null
                          ? NetworkImage(user.profilePicture!)
                          : null,
                  child:
                      user.profilePicture == null
                          ? const Icon(Icons.person)
                          : null,
                ),
                title: Text(user.username),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtherProfilePage(username: user.username),
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
