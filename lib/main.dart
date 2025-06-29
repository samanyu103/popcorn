import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/db.dart';
import 'models/app_user.dart';
import 'screens/authenticate/login.dart';
import 'screens/authenticate/signup.dart';
import 'screens/authenticate/verify_email.dart';
import 'screens/authenticate/forgot_password.dart';
import 'screens/authenticate/phone.dart';
import 'screens/details.dart';
import 'screens/home.dart';
import 'screens/search.dart';
import 'screens/search_movies.dart';
import 'screens/popcorn.dart';

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
        '/search': (_) => const SearchPage(),
        '/movies_search': (_) => const MoviesSearchPage(),
        '/popcorn': (_) => const PopcornPage(),
        '/verify-email': (_) => const VerifyEmailScreen(),
        '/phone-login': (_) => const PhoneLoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
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

          final isEmailPassword = user.providerData.any(
            (info) => info.providerId == 'password',
          );
          // print("$isEmailPassword, ${user.emailVerified}");
          if (isEmailPassword && !user.emailVerified) {
            return const VerifyEmailScreen();
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
              // if (userData == null ||
              //     userData.username.isEmpty ||
              //     userData.age == 0) {
              //   return const DetailsScreen();
              // }
              // print("user data: $userData");

              if (userData == null) {
                return const DetailsScreen(logout: true);
              }

              return const HomeScreen();
            },
          );
        },
      ),
    );
  }
}
