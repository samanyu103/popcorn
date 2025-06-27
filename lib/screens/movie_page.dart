import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/db.dart';
import '../models/movie.dart';

class MoviePage extends StatefulWidget {
  final String tconst;
  final String currentUid;
  final String? otherUid;
  final bool viewOnly;

  const MoviePage({
    super.key,
    required this.tconst,
    required this.currentUid,
    this.otherUid,
    this.viewOnly = false,
  });

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  bool _seen = false;
  bool? _liked; // null = no choice, true = liked, false = disliked
  final TextEditingController _reviewController = TextEditingController();
  Map<String, dynamic>? _movieData;
  Movie? _existingUserMovie;

  bool get isViewOnly => widget.viewOnly;

  @override
  void initState() {
    super.initState();
    _fetchMovie();
  }

  Future<void> _fetchMovie() async {
    final uid = widget.otherUid ?? widget.currentUid;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final userData = userDoc.data();
    if (userData != null && userData['movies'] != null) {
      final moviesList = List<Map<String, dynamic>>.from(userData['movies']);
      final match = moviesList.firstWhere(
        (m) => m['tconst'] == widget.tconst,
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        final existingMovie = Movie.fromMap(match);
        _existingUserMovie = existingMovie;

        _movieData = {
          'name': existingMovie.name,
          'poster_url': existingMovie.poster_url,
          'imdb_rating': existingMovie.imdb_rating,
          'year': existingMovie.year,
        };

        _seen = existingMovie.seen;
        _liked = existingMovie.liked;
        _reviewController.text = existingMovie.review ?? '';
        setState(() {});
        return;
      }
    }

    // Fallback to global movie collection if not in user list
    final movieDoc =
        await FirebaseFirestore.instance
            .collection('movies')
            .doc(widget.tconst)
            .get();

    if (movieDoc.exists) {
      _movieData = movieDoc.data();
    }

    setState(() {});
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_movieData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = _movieData!['name'] ?? 'Unknown';
    final poster_url = _movieData!['poster_url'] ?? '';
    final imdb_rating = _movieData!['imdb_rating'];
    final year = _movieData!['year'];

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Poster image
              poster_url.isNotEmpty
                  ? Image.network(poster_url, height: 300)
                  : const Icon(Icons.broken_image, size: 150),

              const SizedBox(height: 16),

              // Year and IMDb Rating
              Text(
                'Year: $year • IMDb Rating: $imdb_rating',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 24),

              // Seen icon toggle (only editable if !viewOnly)
              IconButton(
                icon: Icon(
                  _seen ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                  size: 30,
                ),
                tooltip: _seen ? 'Seen' : 'Mark as seen',
                onPressed:
                    isViewOnly ? null : () => setState(() => _seen = !_seen),
              ),

              ...[
                if (_seen) ...[
                  const SizedBox(height: 20),

                  // Like / Dislike toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          color: _liked == true ? Colors.green : Colors.grey,
                        ),
                        onPressed:
                            isViewOnly
                                ? null
                                : () {
                                  setState(() {
                                    _liked = _liked == true ? null : true;
                                  });
                                },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          Icons.thumb_down,
                          color: _liked == false ? Colors.red : Colors.grey,
                        ),
                        onPressed:
                            isViewOnly
                                ? null
                                : () {
                                  setState(() {
                                    _liked = _liked == false ? null : false;
                                  });
                                },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Review input
                  TextField(
                    controller: _reviewController,
                    readOnly: isViewOnly,
                    decoration: const InputDecoration(
                      labelText: 'review',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),

                  const SizedBox(height: 16),

                  if (!isViewOnly)
                    ElevatedButton(
                      onPressed: () async {
                        final movie = Movie(
                          tconst: widget.tconst,
                          name: _movieData!['name'],
                          year: _movieData!['year'],
                          imdb_rating: _movieData!['imdb_rating'],
                          poster_url: _movieData!['poster_url'],
                          seen: _seen,
                          liked: _liked,
                          review: _reviewController.text,
                          timeAdded:
                              _existingUserMovie?.timeAdded ?? DateTime.now(),
                        );

                        await DbService.addMovieToUser(
                          movie,
                          widget.currentUid,
                        );
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                      child: Text(
                        _existingUserMovie != null ? 'Update' : 'Post',
                      ),
                    ),
                ] else if (!isViewOnly && _existingUserMovie != null) ...[
                  // Show "Remove" button if previously seen but now unchecked
                  ElevatedButton(
                    onPressed: () async {
                      await DbService.removeMovieFromUser(
                        widget.tconst,
                        widget.currentUid,
                      );
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: const Text('Remove'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
