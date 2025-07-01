import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  void _openWhatsAppChat() async {
    final phone = '+919667220343';
    final message = Uri.encodeComponent(
      "Hey! I watched a movie that’s not in your app. Please add it!",
    );
    final url = 'https://wa.me/$phone?text=$message';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 72, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              "You saw a movie which you couldn't find in search?\n\nNo worries! Let us know and we will add it to our database.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.whatsapp),
              label: const Text('Send Your Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 20.0,
                ),
              ),
              onPressed: _openWhatsAppChat,
            ),
          ],
        ),
      ),
    );
  }
}
