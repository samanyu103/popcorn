import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/share.dart'; // SeenByAnotB

class IncomingRequestsWidget extends StatelessWidget {
  final List<String> incomingRequests;

  const IncomingRequestsWidget({super.key, required this.incomingRequests});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: incomingRequests.length,
        itemBuilder: (context, index) {
          final uid = incomingRequests[incomingRequests.length - 1 - index];
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final data = snapshot.data!.data() as Map<String, dynamic>;
              final username = data['username'] ?? '';
              final profilePic = data['profile_picture'] as String?;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SeenByANotB(otherUid: uid),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            profilePic != null
                                ? NetworkImage(profilePic)
                                : null,
                        child:
                            profilePic == null
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      const SizedBox(height: 4),
                      Text(username, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
