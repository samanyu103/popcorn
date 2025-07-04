import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../screens/movie_page.dart'; // Adjust the import path if needed

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final String uid;
  final bool viewOnly;
  const MovieGrid({
    super.key,
    required this.movies,
    required this.uid,
    this.viewOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    // sort with latest post first
    movies.sort((a, b) => (b.timeAdded).compareTo(a.timeAdded));

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
                    (_) => MoviePage(
                      tconst: movie.tconst,
                      currentUid: uid,
                      viewOnly: viewOnly,
                    ),
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
