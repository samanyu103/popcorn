import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:popcorn/screens/movie_page.dart';

class MoviesSearchPage extends StatefulWidget {
  const MoviesSearchPage({super.key});

  @override
  State<MoviesSearchPage> createState() => _MoviesSearchPageState();
}

class _MoviesSearchPageState extends State<MoviesSearchPage> {
  String _searchText = '';
  List<QueryDocumentSnapshot> _allMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      // Try cache first
      final cacheSnapshot = await FirebaseFirestore.instance
          .collection('movies')
          .get(const GetOptions(source: Source.cache));

      if (cacheSnapshot.docs.isNotEmpty) {
        setState(() {
          _allMovies = cacheSnapshot.docs;
          _isLoading = false;
        });
      } else {
        // Fall back to server if cache is empty
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredMovies.isEmpty
              ? const Center(child: Text('No movies found.'))
              : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                itemCount: filteredMovies.length,
                itemBuilder: (context, i) {
                  final data = filteredMovies[i].data() as Map<String, dynamic>;
                  final posterUrl = data['poster_url'] as String?;

                  return GestureDetector(
                    onTap: () {
                      final currentUid = FirebaseAuth.instance.currentUser?.uid;
                      if (currentUid == null) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => MoviePage(
                                tconst: data['tconst'],
                                currentUid: currentUid,
                                otherUid: null,
                              ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          posterUrl != null
                              ? Image.network(
                                posterUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                              )
                              : const Icon(Icons.broken_image),
                    ),
                  );
                },
              ),
    );
  }
}
