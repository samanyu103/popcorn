import 'movie.dart';

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
  final int rating;

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
      rating: map['rating'] ?? 0,
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
      'rating': rating,
    };
  }
}
