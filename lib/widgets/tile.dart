import 'package:flutter/material.dart';
import '../screens/other_profile.dart'; // Update import if needed

class UserListTile extends StatelessWidget {
  final String username;
  final String? profilePicture;

  const UserListTile({super.key, required this.username, this.profilePicture});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            profilePicture != null ? NetworkImage(profilePicture!) : null,
        child: profilePicture == null ? const Icon(Icons.person) : null,
      ),
      title: Text(username),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtherProfilePage(username: username),
          ),
        );
      },
    );
  }
}
