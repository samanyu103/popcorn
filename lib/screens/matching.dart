import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/db.dart'; // getCurrentUserProfile()
import '../services/matching.dart'; // findTopMatches(AppUser currentUser)
import '../widgets/tile.dart'; // UserListTile

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
      appBar: AppBar(title: const Text('Your Top Matches')),
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
            return const Center(
              child: Text(
                'No matches found.\nTry adding more movies using the post button',
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Users who have similar taste as you',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final user = matches[index];
                    return UserListTile(
                      username: user.username,
                      profilePicture: user.profilePicture,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
