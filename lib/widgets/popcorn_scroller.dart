import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/popcorn.dart';
import '../screens/movie_page.dart';
import '../services/db.dart';

class PopcornScroller extends StatelessWidget {
  final List<Popcorn> popcorns;
  final bool incoming;

  const PopcornScroller({
    super.key,
    required this.popcorns,
    required this.incoming,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popcorns.length,
        itemBuilder: (context, index) {
          // newest first
          final popcorn = popcorns[popcorns.length - 1 - index];
          return FutureBuilder<Map<String, dynamic>?>(
            future: DbService.fetchMovieAndUser(popcorn),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox.shrink();
              }

              final movie = snapshot.data!['movie'];
              // from username
              final fromUsername = snapshot.data!['fromUsername'];
              final toUsername = snapshot.data!['toUsername'];

              return GestureDetector(
                onTap: () {
                  if (incoming) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MoviePage(
                              tconst: popcorn.tconst,
                              currentUid: popcorn.toUid,
                              otherUid: popcorn.fromUid,
                            ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MoviePage(
                              tconst: popcorn.tconst,
                              currentUid: popcorn.fromUid,
                            ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 2 / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            movie['poster_url'],
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        incoming ? fromUsername : toUsername,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
