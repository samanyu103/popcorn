class AppUser {
  final String uid;
  final String email;
  final String name;
  final int age;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'name': name, 'age': age};
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      age: map['age'],
    );
  }
}
