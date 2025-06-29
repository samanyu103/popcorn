import 'package:flutter/material.dart';
import 'otp.dart'; // Adjust path if needed

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: _phoneNumber)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login with Phone')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+911234567890',
                  helperText: 'Include country code (e.g., +91 for India)',
                ),
                keyboardType: TextInputType.phone,
                onSaved: (val) => _phoneNumber = val!.trim(),
                validator:
                    (val) =>
                        RegExp(r'^\+?[0-9]{10,15}$').hasMatch(val!)
                            ? null
                            : 'Enter a valid phone number',
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('Send OTP')),
            ],
          ),
        ),
      ),
    );
  }
}
