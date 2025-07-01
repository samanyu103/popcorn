import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late Timer _timer;
  bool _isEmailVerified = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _checkVerification(); // Initial check

    // Auto-check every 3 seconds
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkVerification(),
    );
  }

  Future<void> _checkVerification() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified && !_isEmailVerified && mounted) {
      setState(() {
        _isEmailVerified = true;
      });

      // Cancel timer before navigating
      _timer.cancel();

      if (!_isDisposed) {
        Navigator.pushReplacementNamed(context, '/details');
      }
    }
  }

  Future<void> _resendVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification email sent.')));
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A verification link has been sent to your email.(Ckeck your Spam folder)\nPlease verify to continue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resendVerification,
              child: const Text('Resend Email'),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(), // Indicate auto-checking
            const SizedBox(height: 10),
            const Text('Waiting for verification...'),
          ],
        ),
      ),
    );
  }
}
