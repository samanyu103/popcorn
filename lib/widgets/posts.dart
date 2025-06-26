import 'package:flutter/material.dart';
import '../models/movie.dart'; // adjust path

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;

  const MovieGrid({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    // by default sorted in descending order of date added.
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

        // Determine border color based on 'liked'
        // print("movie: ${movie.name}, liked?: ${movie.liked}");
        Color? borderColor;
        if (movie.liked == true) {
          borderColor = Colors.green;
        } else if (movie.liked == false) {
          borderColor = Colors.red;
        }

        return Container(
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
        );
      },
    );
  }
}
