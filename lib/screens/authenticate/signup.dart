import 'package:flutter/material.dart';
import '../../services/auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';
  bool _obscurePassword = true;

  final _authService = AuthService();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // print("$_email, $_password");
      final errorMessage = await _authService.signUp(_email, _password);
      if (errorMessage == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/verify-email');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                // keyboardType: TextInputType.emailAddress,
                onSaved: (val) => _email = val!.trim(),
                validator:
                    (val) => val!.contains('@') ? null : 'Enter a valid email',
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                onSaved: (value) => _password = value!.trim(),
                validator:
                    (value) =>
                        value!.length >= 6 ? null : 'Minimum 6 characters',
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('Sign Up')),
              TextButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
