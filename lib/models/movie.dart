import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String tconst;
  final String name;
  final int year;
  final double imdb_rating;
  final String poster_url;
  final bool seen;
  final bool? liked;
  final String? review;
  final DateTime timeAdded;
  final int? numVotes; // New nullable field

  Movie({
    required this.tconst,
    required this.name,
    required this.year,
    required this.imdb_rating,
    required this.poster_url,
    required this.seen,
    required this.liked,
    this.review,
    required this.timeAdded,
    this.numVotes,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      tconst: map['tconst'],
      name: map['name'],
      year: map['year'],
      imdb_rating: (map['imdb_rating'] as num).toDouble(),
      poster_url: map['poster_url'],
      seen: map['seen'],
      liked: map['liked'],
      review: map['review'],
      timeAdded: (map['time_added'] as Timestamp).toDate(),
      numVotes: map['numVotes'], // Safe: Firestore stores nulls too
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tconst': tconst,
      'name': name,
      'year': year,
      'imdb_rating': imdb_rating,
      'poster_url': poster_url,
      'seen': seen,
      'liked': liked,
      'review': review,
      'time_added': Timestamp.fromDate(timeAdded),
      'numVotes': numVotes,
    };
  }
}
