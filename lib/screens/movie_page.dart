import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/db.dart';
import '../models/movie.dart';
import '../models/rating.dart';

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
  bool? _liked;
  bool? otherliked;
  String? otherreview;
  final TextEditingController _reviewController = TextEditingController();
  Map<String, dynamic>? _movieData;
  Movie? _existingUserMovie;
  bool foundincuruserdb = false;
  bool foundinotheruserdb = false;

  bool get isViewOnly => widget.viewOnly;

  @override
  void initState() {
    super.initState();
    _fetchMovie();
  }

  Future<void> _fetchMovie() async {
    final cuid = widget.currentUid;
    final ouid = widget.otherUid;
    final tconst = widget.tconst;

    final userMovie = await DbService.getMovieUser(cuid, tconst);
    if (userMovie != null) {
      foundincuruserdb = true;
      _existingUserMovie = userMovie;
      _movieData = {
        'name': userMovie.name,
        'poster_url': userMovie.poster_url,
        'imdb_rating': userMovie.imdb_rating,
        'year': userMovie.year,
        'numVotes': userMovie.numVotes,
        'recent': userMovie.recent,
      };
      _seen = userMovie.seen;
      _liked = userMovie.liked;
      _reviewController.text = userMovie.review ?? '';
      setState(() {});
      return;
    }

    if (ouid != null) {
      final otherMovie = await DbService.getMovieUser(ouid, tconst);
      if (otherMovie != null) {
        foundinotheruserdb = true;
        _existingUserMovie = otherMovie;
        _movieData = {
          'name': otherMovie.name,
          'poster_url': otherMovie.poster_url,
          'imdb_rating': otherMovie.imdb_rating,
          'year': otherMovie.year,
          'numVotes': otherMovie.numVotes,
          'recent': otherMovie.recent,
        };
        otherliked = otherMovie.liked;
        otherreview = otherMovie.review ?? '';
        setState(() {});
        return;
      }
    }

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
    final posterUrl = _movieData!['poster_url'] ?? '';
    final imdbRating = _movieData!['imdb_rating'];
    final year = _movieData!['year'];

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              posterUrl.isNotEmpty
                  ? Image.network(posterUrl, height: 300)
                  : const Icon(Icons.broken_image, size: 150),

              const SizedBox(height: 16),

              Text(
                'Year: $year • IMDb Rating: $imdbRating',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 24),

              IconButton(
                icon: Icon(
                  _seen ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                  size: 30,
                ),
                tooltip: _seen ? 'Seen' : 'Mark as seen',
                onPressed:
                    isViewOnly ? null : () => setState(() => _seen = !_seen),
              ),

              const SizedBox(height: 20),

              if (_seen) ...[
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

                TextField(
                  controller: _reviewController,
                  readOnly: isViewOnly,
                  decoration: const InputDecoration(
                    labelText: 'review',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
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
                            foundincuruserdb
                                ? _existingUserMovie?.timeAdded ??
                                    DateTime.now()
                                : DateTime.now(),
                        numVotes: _movieData!['numVotes'],
                        recent: _movieData!['recent'],
                      );

                      await DbService.addMovieToUser(movie, widget.currentUid);
                      // remove from incoming popcorn
                      await DbService.removeFromIncomingPopcorn(
                        widget.tconst,
                        widget.currentUid,
                      );

                      // ratings
                      if (foundinotheruserdb) {
                        final user = await DbService().getUserProfile(
                          widget.currentUid,
                        );
                        final username = user!.username;
                        final rating = Rating(
                          tconst: widget.tconst,
                          name: _movieData!['name'],
                          poster_url: _movieData!['poster_url'],
                          liked: _liked,
                          score:
                              _liked == true
                                  ? 1
                                  : _liked == false
                                  ? -1
                                  : 0,
                          timeAdded: DateTime.now(),
                          toUserName: username,
                        );
                        await DbService.addRatingToUser(
                          rating,
                          widget.otherUid!,
                        );
                      }

                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: Text(foundincuruserdb ? 'Update' : 'Post'),
                  ),
              ] else ...[
                if (!isViewOnly && foundincuruserdb)
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

                if (foundinotheruserdb) ...[
                  // const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👍👎 Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.thumb_up,
                            color:
                                otherliked == true ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 20),
                          Icon(
                            Icons.thumb_down,
                            color:
                                otherliked == false ? Colors.red : Colors.grey,
                          ),
                        ],
                      ),

                      // Review box if available
                      if (otherreview != null &&
                          otherreview!.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        TextField(
                          readOnly: true,
                          controller: TextEditingController(text: otherreview),
                          decoration: const InputDecoration(
                            labelText: 'review',
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          maxLines: 4,
                        ),
                      ],
                    ],
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
