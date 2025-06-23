import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/db.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _name = '';
  String _about = '';

  final AuthService _authService = AuthService();
  final DbService _dbService = DbService();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final isTaken = await _dbService.isUsernameTaken(_username);
      if (isTaken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username is already taken')),
        );
        return;
      }

      final uid = _authService.getCurrentUserId();
      final email = _authService.getCurrentUserEmail();

      await _dbService.saveUserProfile(
        uid: uid!,
        email: email!,
        username: _username,
        name: _name,
        about: _about,
        profilePicture: null,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                onSaved: (val) => _username = val!.trim(),
                validator: (val) => val!.isEmpty ? 'Enter your username' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                onSaved: (val) => _name = val!.trim(),
                validator: (val) => val!.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'About'),
                maxLines: 3,
                onSaved: (val) => _about = val!.trim(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
