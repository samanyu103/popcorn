import 'package:flutter/material.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(32.0),
          color: Colors.white,
          child: const Center(
            child: Image(image: AssetImage('assets/share_a_popcorn.png')),
          ),
        ),
      ),
    );
  }
}
