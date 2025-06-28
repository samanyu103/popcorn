import 'package:flutter/material.dart';
import '../models/rating.dart';

class ViewRatingsPage extends StatelessWidget {
  final List<Rating> ratings;

  const ViewRatingsPage({super.key, required this.ratings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ratings')),
      body: ListView.builder(
        itemCount: ratings.length,
        itemBuilder: (context, index) {
          // newest first
          final rating = ratings[ratings.length - 1 - index];

          String action;
          if (rating.liked == true) {
            action = 'liked';
          } else if (rating.liked == false) {
            action = 'disliked';
          } else {
            action = 'saw';
          }

          final scoreColor =
              rating.score > 0
                  ? Colors.green
                  : rating.score < 0
                  ? Colors.red
                  : Colors.grey;

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(rating.poster_url),
            ),
            title: Text('${rating.toUserName} $action ${rating.name}'),
            trailing: Text(
              '${rating.score > 0 ? '+' : ''}${rating.score}',
              style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
