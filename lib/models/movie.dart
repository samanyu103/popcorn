import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String tconst;
  final String name;
  final int year;
  final double? imdb_rating;
  final String poster_url;
  final bool seen;
  final bool? liked;
  final String? review;
  final DateTime timeAdded;
  final int? numVotes;
  final bool? recent;

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
    this.recent,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      tconst: map['tconst'] as String,
      name: map['name'] as String,
      year: map['year'] as int,
      imdb_rating:
          map['imdb_rating'] != null
              ? (map['imdb_rating'] as num).toDouble()
              : null,
      poster_url: map['poster_url'] as String,
      seen: map['seen'] ?? false,
      liked: map['liked'] as bool?,
      review: map['review'] as String?,
      timeAdded: (map['time_added'] as Timestamp).toDate(),
      numVotes: map['numVotes'] as int?,
      recent: map['recent'] as bool?,
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
      'recent': recent,
    };
  }
}
