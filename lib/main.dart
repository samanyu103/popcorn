import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/db.dart';
import 'models/app_user.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/details.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth + Profile',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/details': (_) => const DetailsScreen(),
        '/home': (_) => const HomeScreen(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = authSnapshot.data;
          // debugPrint('User: $user');
          if (user == null) {
            return const LoginScreen();
          }

          // Authenticated — now check Firestore for user profile
          return FutureBuilder<AppUser?>(
            future: DbService().getCurrentUserProfile(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final userData = userSnapshot.data;
              if (userData == null ||
                  userData.name.isEmpty ||
                  userData.age == 0) {
                return const DetailsScreen();
              }

              return const HomeScreen();
            },
          );
        },
      ),
    );
  }
}
