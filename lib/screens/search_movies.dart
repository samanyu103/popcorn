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
  late final Stream<QuerySnapshot> _moviesStream;

  @override
  void initState() {
    super.initState();
    _moviesStream = FirebaseFirestore.instance.collection('movies').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search movies...',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _searchText = value.toLowerCase());
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _moviesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;
          final filteredDocs =
              allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] as String).toLowerCase();
                return name.contains(_searchText);
              }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(child: Text('No movies found.'));
          }

          // descending order of imdb rating
          filteredDocs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>?;
            final dataB = b.data() as Map<String, dynamic>?;

            final ratingA = (dataA?['imdb_rating'] ?? 0).toDouble();
            final ratingB = (dataB?['imdb_rating'] ?? 0).toDouble();

            return ratingB.compareTo(ratingA); // descending order
          });

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 posters per row
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7, // poster aspect ratio
            ),
            itemCount: filteredDocs.length,
            itemBuilder: (context, i) {
              final data = filteredDocs[i].data() as Map<String, dynamic>;
              final posterUrl = data['poster_url'] as String?;

              return GestureDetector(
                onTap: () {
                  final currentUid = FirebaseAuth.instance.currentUser?.uid;
                  if (currentUid == null) {
                    return;
                  }
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

                  // Placeholder: future link to movie page
                  // Navigator.push(...);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      posterUrl != null
                          ? Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                          )
                          : const Icon(Icons.broken_image),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
