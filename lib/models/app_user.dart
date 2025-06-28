import 'movie.dart';
import 'popcorn.dart';
import 'rating.dart';

class AppUser {
  final String uid;
  final String email;
  final String username;
  final String? profilePicture;
  final String name;
  final String about;
  final List<Movie> movies;
  final List<String> followers;
  final List<String> following;
  final List<Rating> rating;

  final List<Popcorn> incomingPopcorns;
  final List<Popcorn> outgoingPopcorns;
  final List<String> incomingRequests;
  final List<String> outgoingRequests;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.profilePicture,
    required this.name,
    required this.about,
    required this.movies,
    required this.followers,
    required this.following,
    required this.rating,
    required this.incomingPopcorns,
    required this.outgoingPopcorns,
    required this.incomingRequests,
    required this.outgoingRequests,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],
      profilePicture: map['profile_picture'],
      name: map['name'],
      about: map['about'],
      movies:
          (map['movies'] as List<dynamic>? ?? [])
              .map((movieMap) => Movie.fromMap(movieMap))
              .toList(),
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      rating:
          (map['rating'] as List<dynamic>? ?? [])
              .map((ratingMap) => Rating.fromMap(ratingMap))
              .toList(),
      incomingPopcorns:
          (map['incomingPopcorns'] as List<dynamic>? ?? [])
              .map((p) => Popcorn.fromMap(p))
              .toList(),
      outgoingPopcorns:
          (map['outgoingPopcorns'] as List<dynamic>? ?? [])
              .map((p) => Popcorn.fromMap(p))
              .toList(),
      incomingRequests: List<String>.from(map['incomingRequests'] ?? []),
      outgoingRequests: List<String>.from(map['outgoingRequests'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'profile_picture': profilePicture,
      'name': name,
      'about': about,
      'movies': movies.map((movie) => movie.toMap()).toList(),
      'followers': followers,
      'following': following,
      'rating': rating.map((r) => r.toMap()).toList(),
      'incomingPopcorns': incomingPopcorns.map((p) => p.toMap()).toList(),
      'outgoingPopcorns': outgoingPopcorns.map((p) => p.toMap()).toList(),
      'incomingRequests': incomingRequests,
      'outgoingRequests': outgoingRequests,
    };
  }
}
