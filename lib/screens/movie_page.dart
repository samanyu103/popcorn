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
  final String? message;

  const MoviePage({
    super.key,
    required this.tconst,
    required this.currentUid,
    this.otherUid,
    this.viewOnly = false,
    this.message,
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
  bool _inWatchlist = false;

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
    // Check current user's movie
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
      // return;
    }

    // Check other user's movie
    if (ouid != null && !foundincuruserdb) {
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
        // return;
      }
    }
    // check the watchlist
    final watchlist_movie = await DbService.getMovieFromWatchlist(cuid, tconst);
    if (watchlist_movie != null) {
      _inWatchlist = true;
      _movieData = {
        'name': watchlist_movie.name,
        'poster_url': watchlist_movie.poster_url,
        'imdb_rating': watchlist_movie.imdb_rating,
        'year': watchlist_movie.year,
        'numVotes': watchlist_movie.numVotes,
        'recent': watchlist_movie.recent,
      };
      setState(() {});
    }

    // Fallback to base movie data

    if (!foundincuruserdb && !foundinotheruserdb && !_inWatchlist) {
      final movieDoc =
          await FirebaseFirestore.instance
              .collection('movies')
              .doc(tconst)
              .get();

      if (movieDoc.exists) {
        _movieData = movieDoc.data();
      }

      setState(() {});
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
                      await DbService.removeFromIncomingPopcorn(
                        widget.tconst,
                        widget.currentUid,
                      );
                      // if inwatchlist?
                      await DbService.removeMovieFromWatchlist(
                        widget.currentUid,
                        widget.tconst,
                      );

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
                // not seen then
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

                if (!isViewOnly && !foundincuruserdb) ...[
                  IconButton(
                    icon: Icon(
                      _inWatchlist ? Icons.check : Icons.add,
                      color: _inWatchlist ? Colors.green : null,
                      size: 30,
                    ),
                    tooltip:
                        _inWatchlist
                            ? 'Remove from Watchlist'
                            : 'Add to Watchlist',
                    onPressed: () async {
                      if (_inWatchlist) {
                        await DbService.removeMovieFromWatchlist(
                          widget.currentUid,
                          widget.tconst,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from watchlist'),
                            ),
                          );
                        }
                      } else {
                        final movie = Movie(
                          tconst: widget.tconst,
                          name: _movieData!['name'],
                          year: _movieData!['year'],
                          imdb_rating: _movieData!['imdb_rating'],
                          poster_url: _movieData!['poster_url'],
                          seen: false,
                          liked: null,
                          review: null,
                          timeAdded: DateTime.now(),
                          numVotes: _movieData!['numVotes'],
                          recent: _movieData!['recent'],
                        );

                        await DbService.addMovieToWatchlist(
                          widget.currentUid,
                          movie,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to watchlist')),
                          );
                        }
                      }

                      setState(() {
                        _inWatchlist = !_inWatchlist;
                      });
                    },
                  ),
                ],

                // message
                // Display the message if it exists
                if (widget.message != null &&
                    widget.message!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow[700]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.message, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.message!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                if (foundinotheruserdb) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thumb_up,
                        color: otherliked == true ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.thumb_down,
                        color: otherliked == false ? Colors.red : Colors.grey,
                      ),
                    ],
                  ),
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
