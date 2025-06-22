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
  String _name = '';
  int _age = 0;

  final AuthService _authService = AuthService();
  final DbService _dbService = DbService();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // await _authService.updateUserDetails(_name, _age);
      final uid = _authService.getCurrentUserId();
      final email = _authService.getCurrentUserEmail();

      await _dbService.saveUserProfile(
        uid: uid!,
        email: email!,
        name: _name,
        age: _age,
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
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (val) => _name = val!.trim(),
                validator: (val) => val!.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onSaved: (val) => _age = int.tryParse(val!) ?? 0,
                validator:
                    (val) =>
                        int.tryParse(val!) == null ? 'Enter a valid age' : null,
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
