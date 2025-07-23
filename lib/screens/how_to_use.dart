import 'package:flutter/material.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Add Posts',
        'subtitle':
            'Use the + icon in the center to post movies you have watched.',
        'icon': Icons.add_box_outlined,
      },
      {
        'title': 'Check Common and Unique Movies',
        'subtitle':
            'Visit someone’s profile from search to see movies you both have watched and ones only one of you has seen.',
        'icon': Icons.compare_arrows_outlined,
      },
      {
        'title': 'Follow and Ask for Recommendations',
        'subtitle':
            'Follow users. Then request a 🍿 (movie recommendation) from them.',
        'icon': Icons.person_add_alt_1,
      },
      {
        'title': 'Incoming Popcorns',
        'subtitle':
            'Once someone responds to your request, you’ll see it in the Incoming Popcorns section.',
        'icon': Icons.mark_email_unread_outlined,
      },
      {
        'title': 'Match Tab',
        'subtitle':
            'Find users with similar movie tastes (most movies in common) whom you don’t follow yet.',
        'icon': Icons.people_alt_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('How to Use')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(item['icon'] as IconData, color: Colors.blue),
            title: Text(
              item['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item['subtitle'] as String),
          );
        },
      ),
    );
  }
}
