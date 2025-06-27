import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../widgets/popcorn_scroller.dart';
import '../widgets/incomingRequests.dart';
import '../widgets/outgoingRequests.dart';

class PopcornPage extends StatefulWidget {
  const PopcornPage({super.key});

  @override
  State<PopcornPage> createState() => _PopcornPageState();
}

class _PopcornPageState extends State<PopcornPage> {
  String? currentUid;

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Popcorns')),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          // print("data $data");
          final user = AppUser.fromMap(data);
          // print("user $user");
          // print("incoming popcorns ${user.incomingPopcorns}");
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Incoming Popcorns
                const Text(
                  "Incoming Popcorns",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                PopcornScroller(
                  popcorns: user.incomingPopcorns,
                  incoming: true,
                ),
                const SizedBox(height: 20),

                // Outgoing Popcorns
                const Text(
                  "Outgoing Popcorns",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                PopcornScroller(
                  popcorns: user.outgoingPopcorns,
                  incoming: false,
                ),

                const SizedBox(height: 20),

                // Incoming Requests
                const Text(
                  "Incoming Requests",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                IncomingRequestsWidget(incomingRequests: user.incomingRequests),

                const SizedBox(height: 20),

                // Outgoing Requests
                const Text(
                  "Outgoing Requests",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                OutgoingRequestsWidget(outgoingRequests: user.outgoingRequests),
              ],
            ),
          );
        },
      ),
    );
  }
}
