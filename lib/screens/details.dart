import 'dart:io';
import 'package:flutter/material.dart';
import 'package:popcorn/models/app_user.dart';
import '../services/auth.dart';
import '../services/db.dart';
import '../widgets/profilePicturePicker.dart';

class DetailsScreen extends StatefulWidget {
  final bool logout;

  const DetailsScreen({super.key, this.logout = false});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final DbService _dbService = DbService();

  String _username = '';
  String _name = '';
  String _about = '';
  String? _profilePicture;
  File? _pickedImage;
  bool _profileExists = false;

  // Submit the form
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final uid = _authService.getCurrentUserId();
      final email = _authService.getCurrentUserEmail();
      if (uid == null) return;

      // Check username only on creation
      if (!_profileExists) {
        final isTaken = await _dbService.isUsernameTaken(_username);
        if (isTaken) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username is already taken')),
          );
          return;
        }
      }

      // Upload profile picture only if picked
      String? imageUrl = _profilePicture;
      if (_pickedImage != null) {
        imageUrl = await _dbService.uploadProfilePicture(uid, _pickedImage!);
      }

      if (!_profileExists) {
        await _dbService.createUserProfile(
          uid: uid,
          email: email,
          username: _username,
          name: _name,
          about: _about,
          profilePicture: imageUrl,
        );
      } else {
        await _dbService.updateUserProfile(
          uid: uid,
          username: _username,
          name: _name,
          about: _about,
          profilePicture: imageUrl,
        );
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  // Load existing user data (if any)
  Future<AppUser?> _loadProfile() async {
    final uid = _authService.getCurrentUserId();
    if (uid == null) return null;

    final userData = await _dbService.getUserProfile(uid);
    if (userData != null) {
      _profileExists = true;
      _username = userData.username;
      _name = userData.name;
      _about = userData.about;
      _profilePicture = userData.profilePicture;
    }

    return userData;
  }

  // Logout handler
  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions:
            widget.logout
                ? [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ]
                : null,
      ),
      body: FutureBuilder<AppUser?>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfilePicturePicker(
                      initialPicture: _profilePicture,
                      onImagePicked: (file) {
                        _pickedImage = file;
                      },
                      onImageRemoved: () {
                        _pickedImage = null;
                        _profilePicture = null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: _username,
                      decoration: const InputDecoration(labelText: 'Username'),
                      onSaved: (val) => _username = val!.trim(),
                      validator:
                          (val) => val!.isEmpty ? 'Enter your username' : null,
                    ),
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      onSaved: (val) => _name = val!.trim(),
                      validator:
                          (val) => val!.isEmpty ? 'Enter your name' : null,
                    ),
                    TextFormField(
                      initialValue: _about,
                      decoration: const InputDecoration(labelText: 'About'),
                      maxLines: 3,
                      onSaved: (val) => _about = val!.trim(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
