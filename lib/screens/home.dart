// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../services/auth.dart';
// import '../widgets/user_profile_info.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   void _onNavTapped(BuildContext context, int index) {
//     if (index == 1) {
//       Navigator.pushNamed(context, '/search');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final _authService = AuthService();
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       return const Scaffold(body: Center(child: Text("No user signed in.")));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               await _authService.signOut();
//               if (context.mounted) {
//                 Navigator.pushReplacementNamed(context, '/login');
//               }
//             },
//             icon: const Icon(Icons.logout),
//           ),
//         ],
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream:
//             FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(currentUser.uid)
//                 .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final user = snapshot.data!.data() as Map<String, dynamic>?;

//           if (user == null) {
//             return const Center(child: Text('User data not found.'));
//           }

//           return Center(child: UserProfileInfo(user: user));
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0,
//         onTap: (index) => _onNavTapped(context, index),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Home')),
      body: FutureBuilder<QuerySnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('movies')
                .where('tconst', isEqualTo: 'tt0111161')
                .limit(1)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Movie not found.'));
          }

          final movie =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie['poster_url'],
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  movie['name'] ?? 'Unknown Title',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${movie['year'] ?? ''} • IMDb: ${movie['imdb_rating'] ?? ''}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
