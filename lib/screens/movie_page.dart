import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/db.dart';
import '../models/movie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoviePage extends StatefulWidget {
  final String tconst;
  final String currentUid;
  final String? otherUid;

  const MoviePage({
    super.key,
    required this.tconst,
    required this.currentUid,
    this.otherUid,
  });

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  bool _seen = false;
  bool? _liked; // null = no choice, true = liked, false = disliked
  final TextEditingController _reviewController = TextEditingController();
  Map<String, dynamic>? _movieData;

  @override
  void initState() {
    super.initState();
    _fetchMovie();
  }

  Future<void> _fetchMovie() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('movies')
            .doc(widget.tconst)
            .get();

    if (doc.exists) {
      setState(() {
        _movieData = doc.data();
      });
    }
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

              // Seen icon toggle
              IconButton(
                icon: Icon(
                  _seen ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                  size: 30,
                ),
                tooltip: _seen ? 'Seen' : 'Mark as seen',
                onPressed: () => setState(() => _seen = !_seen),
              ),

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
                      onPressed: () {
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
                      onPressed: () {
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
                  decoration: const InputDecoration(
                    labelText: 'Write your review...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),

                const SizedBox(height: 16),

                // Post button
                ElevatedButton(
                  onPressed: () async {
                    final movie = Movie(
                      tconst: widget.tconst,
                      name: name,
                      year: year,
                      imdb_rating: imdb_rating,
                      poster_url: poster_url,
                      seen: _seen,
                      liked: _liked,
                      review: _reviewController.text,
                      timeAdded: DateTime.now(),
                    );

                    await DbService.addMovieToUser(movie, widget.currentUid);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text('Post'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
