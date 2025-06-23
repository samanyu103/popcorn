class AppUser {
  final String uid;
  final String email;
  final String username;
  final int age;
  final List<String> followers;
  final List<String> following;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.age,
    required this.followers,
    required this.following,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],
      age: map['age'],
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'age': age,
      'followers': followers,
      'following': following,
    };
  }
}
