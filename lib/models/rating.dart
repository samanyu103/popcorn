import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String tconst;
  final String name;
  final String poster_url;
  final bool? liked; // true = liked, false = disliked, null = seen
  final int score;
  final String toUserName;
  final DateTime timeAdded;

  Rating({
    required this.tconst,
    required this.name,
    required this.poster_url,
    required this.liked,
    required this.score,
    required this.toUserName,
    required this.timeAdded,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      tconst: map['tconst'],
      name: map['name'],
      poster_url: map['poster_url'],
      liked: map['liked'],
      score: map['score'] ?? 0,
      toUserName: map['toUserName'] ?? '',
      timeAdded: (map['time_added'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tconst': tconst,
      'name': name,
      'poster_url': poster_url,
      'liked': liked,
      'score': score,
      'toUserName': toUserName,
      'time_added': Timestamp.fromDate(timeAdded),
    };
  }
}
