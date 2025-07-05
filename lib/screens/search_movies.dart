import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:popcorn/screens/movie_page.dart';
import 'package:popcorn/models/movie.dart';
import 'package:popcorn/services/db.dart';

class MoviesSearchPage extends StatefulWidget {
  const MoviesSearchPage({super.key});

  @override
  State<MoviesSearchPage> createState() => _MoviesSearchPageState();
}

class _MoviesSearchPageState extends State<MoviesSearchPage> {
  String _searchText = '';
  List<QueryDocumentSnapshot> _allMovies = [];
  bool _isLoading = true;
  bool _isPosting = false;

  bool _selectionMode = false;
  List<Movie> _selectedMovies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final cacheSnapshot = await FirebaseFirestore.instance
          .collection('movies')
          .get(const GetOptions(source: Source.cache));

      if (cacheSnapshot.docs.isNotEmpty) {
        setState(() {
          _allMovies = cacheSnapshot.docs;
          _isLoading = false;
        });
      } else {
        final serverSnapshot = await FirebaseFirestore.instance
            .collection('movies')
            .get(const GetOptions(source: Source.server));

        setState(() {
          _allMovies = serverSnapshot.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading movies: $e");
      setState(() => _isLoading = false);
    }
  }

  void _toggleSelection(Map<String, dynamic> data) {
    final tconst = data['tconst'];
    final index = _selectedMovies.indexWhere((movie) => movie.tconst == tconst);
    setState(() {
      if (index != -1) {
        _selectedMovies.removeAt(index);
      } else {
        final movie = Movie(
          tconst: tconst,
          name: data['name'],
          year: data['year'],
          imdb_rating: data['imdb_rating'],
          poster_url: data['poster_url'],
          seen: true,
          liked: null,
          review: '',
          timeAdded: DateTime.now(),
          numVotes: data['numVotes'],
        );
        _selectedMovies.add(movie);
      }
    });
  }

  bool _isSelected(String tconst) {
    return _selectedMovies.any((movie) => movie.tconst == tconst);
  }

  Future<void> _postSelectedMovies() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    setState(() => _isPosting = true);

    for (var movie in _selectedMovies) {
      await DbService.addMovieToUser(movie, currentUid);
    }

    if (!mounted) return;

    setState(() {
      _isPosting = false;
      _selectionMode = false;
      _selectedMovies.clear();
    });

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies =
        _allMovies.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] as String?)?.toLowerCase() ?? '';
            return name.contains(_searchText.toLowerCase());
          }).toList()
          ..sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>?;
            final dataB = b.data() as Map<String, dynamic>?;
            final votesA = (dataA?['numVotes'] ?? 0).toDouble();
            final votesB = (dataB?['numVotes'] ?? 0).toDouble();
            return votesB.compareTo(votesA);
          });

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search movies...',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _searchText = value),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredMovies.isEmpty
                        ? const Center(child: Text('No movies found.'))
                        : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: filteredMovies.length,
                          itemBuilder: (context, i) {
                            final doc = filteredMovies[i];
                            final data = doc.data() as Map<String, dynamic>;
                            final tconst = data['tconst'];
                            final posterUrl = data['poster_url'] as String?;
                            final isSelected = _isSelected(tconst);

                            return GestureDetector(
                              onTap: () {
                                if (_selectionMode) {
                                  _toggleSelection(data);
                                } else {
                                  final currentUid =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  if (currentUid == null) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => MoviePage(
                                            tconst: tconst,
                                            currentUid: currentUid,
                                            otherUid: null,
                                          ),
                                    ),
                                  );
                                }
                              },
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        posterUrl != null
                                            ? Image.network(
                                              posterUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) => const Icon(
                                                    Icons.broken_image,
                                                  ),
                                            )
                                            : const Icon(Icons.broken_image),
                                  ),
                                  if (_selectionMode)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color:
                                              isSelected
                                                  ? Colors.green
                                                  : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                color: Colors.black,
                child:
                    _selectionMode
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectionMode = false;
                                  _selectedMovies.clear();
                                });
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Cancel'),
                            ),
                            ElevatedButton.icon(
                              onPressed:
                                  _selectedMovies.isEmpty
                                      ? null
                                      : _postSelectedMovies,
                              icon: const Icon(Icons.send),
                              label: Text(
                                'Post (${_selectedMovies.length} Selected)',
                              ),
                            ),
                          ],
                        )
                        : Center(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => setState(() => _selectionMode = true),
                            icon: const Icon(Icons.check_box),
                            label: const Text('Select Multiple'),
                          ),
                        ),
              ),
            ],
          ),

          // Fullscreen overlay when posting
          if (_isPosting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
