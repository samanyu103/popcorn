import 'package:flutter/material.dart';
import '../screens/following.dart';
import '../screens/followers.dart';
import '../screens/ratings.dart';
import '../models/rating.dart';

class UserProfileInfo extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isCurrentUser;

  const UserProfileInfo({
    super.key,
    required this.user,
    this.isCurrentUser = true,
  });

  @override
  Widget build(BuildContext context) {
    final username = user['username'] ?? '';
    final name = user['name'] ?? '';
    final about = user['about'] ?? '';
    final movieCount = (user['movies'] as List?)?.length ?? 0;
    final followers = List<String>.from(user['followers'] ?? []);
    final following = List<String>.from(user['following'] ?? []);
    final uid = user['uid'];
    final scoreSum = (user['rating'] as List<dynamic>? ?? [])
        .map((r) => (r['score'] ?? 0) as int)
        .fold(0, (a, b) => a + b);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top-left Username
          Text(
            username,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Row: Profile Picture + Stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    user['profileUrl'] != null
                        ? NetworkImage(user['profileUrl'])
                        : null,
                child:
                    user['profileUrl'] == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
              ),
              const SizedBox(width: 20),

              // Stats: Movies, Followers, Following, Rating
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(label: 'Movies', value: movieCount.toString()),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FollowersListPage(userUid: uid),
                          ),
                        );
                      },
                      child: _StatItem(
                        label: 'Followers',
                        value: '${followers.length}',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FollowingListPage(userUid: uid),
                          ),
                        );
                      },
                      child: _StatItem(
                        label: 'Following',
                        value: '${following.length}',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ViewRatingsPage(
                                  ratings:
                                      (user['rating'] as List<dynamic>)
                                          .map((r) => Rating.fromMap(r))
                                          .toList(),
                                ),
                          ),
                        );
                      },
                      child: _StatItem(
                        label: 'Rating',
                        value: scoreSum.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name
          if (name.isNotEmpty)
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

          // About
          if (about.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                about,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
