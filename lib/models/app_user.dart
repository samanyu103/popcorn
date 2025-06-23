class AppUser {
  final String uid;
  final String email;
  final String username;
  final String? profilePicture;
  final String name;
  final String about;
  final int movies;
  final int followers;
  final int following;
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
      movies: map['movies'] ?? 0,
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
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
      'movies': movies,
      'followers': followers,
      'following': following,
      'rating': rating,
    };
  }
}
