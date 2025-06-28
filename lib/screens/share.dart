import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import '../models/popcorn.dart';
import '../services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeenByANotB extends StatefulWidget {
  final String otherUid; // B
  const SeenByANotB({super.key, required this.otherUid});

  @override
  State<SeenByANotB> createState() => _SeenByANotBState();
}

class _SeenByANotBState extends State<SeenByANotB> {
  late String currentUid; // A
  late Future<List<Movie>> futureMovies;

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser!.uid;
    futureMovies = DbService.getSeenByANotB(currentUid, widget.otherUid);
  }

  void sharePopcorn(Movie movie) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final popcorn = Popcorn(
      fromUid: currentUid,
      toUid: widget.otherUid,
      tconst: movie.tconst,
      timestamp: now,
    );

    final aRef = FirebaseFirestore.instance.collection('users').doc(currentUid);
    final bRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUid);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final aSnap = await tx.get(aRef);
      final bSnap = await tx.get(bRef);

      final aData = aSnap.data()!;
      final bData = bSnap.data()!;

      final updatedAIncoming = List<String>.from(
        aData['incomingRequests'] ?? [],
      )..remove(widget.otherUid);

      final updatedBOutgoing = List<String>.from(
        bData['outgoingRequests'] ?? [],
      )..remove(currentUid);

      final updatedAOut = List<Map<String, dynamic>>.from(
        aData['outgoingPopcorns'] ?? [],
      )..add(popcorn.toMap());

      final updatedBIn = List<Map<String, dynamic>>.from(
        bData['incomingPopcorns'] ?? [],
      )..add(popcorn.toMap());

      tx.update(aRef, {
        'incomingRequests': updatedAIncoming,
        'outgoingPopcorns': updatedAOut,
      });

      tx.update(bRef, {
        'outgoingRequests': updatedBOutgoing,
        'incomingPopcorns': updatedBIn,
      });
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Popcorn shared!")));
    Navigator.pushNamed(context, '/popcorn');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Share Popcorn"), leading: BackButton()),
      body: FutureBuilder<List<Movie>>(
        future: futureMovies,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data!;
          if (movies.isEmpty) {
            return const Center(
              child: Text(
                "No movies to share",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          // sort descending order of imdb ratings
          movies.sort((a, b) => (b.imdb_rating).compareTo(a.imdb_rating));

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text(movie.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(movie.poster_url, height: 150),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  sharePopcorn(movie);
                                },
                                child: const Text("Share a Popcorn"),
                              ),
                            ],
                          ),
                        ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    movie.poster_url,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
