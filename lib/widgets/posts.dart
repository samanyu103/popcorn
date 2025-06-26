import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../screens/movie_page.dart'; // Adjust the import path if needed
import 'package:firebase_auth/firebase_auth.dart';

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  const MovieGrid({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    // final sortedMovies = List<Movie>.from(movies)
    //   ..sort((a, b) => b.timeAdded.compareTo(a.timeAdded));
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];

        Color? borderColor;
        if (movie.liked == true) {
          borderColor = Colors.green;
        } else if (movie.liked == false) {
          borderColor = Colors.red;
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        MoviePage(tconst: movie.tconst, currentUid: currentUid),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border:
                  borderColor != null
                      ? Border.all(color: borderColor, width: 2)
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                movie.poster_url,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        );
      },
    );
  }
}
