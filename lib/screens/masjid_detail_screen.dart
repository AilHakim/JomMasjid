import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
// Import the feature screens we are about to create/update
import 'announcement_screen.dart';
import 'donation_screen.dart';
import 'chat_screen.dart';

class MasjidDetailScreen extends StatelessWidget {
  final Map<String, String> masjidData;

  const MasjidDetailScreen({super.key, required this.masjidData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(masjidData['name']!), 
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  masjidData['imageUrl']!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Welcome to ${masjidData['name']}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // FEATURE 1: Specific Announcements
              CustomButton(
                text: 'Masjid Announcements 📢',
                onPressed: () {
                  debugPrint("Navigating to announcements for ID: ${masjidData['id']}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementScreen(masjidData: masjidData),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // FEATURE 2: Specific Online Donations
              CustomButton(
                text: 'Online Donations 💳',
                onPressed: () {
                  debugPrint("Navigating to donation gateway for ID: ${masjidData['id']}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonationScreen(masjidData: masjidData),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // FEATURE 3: Specific Community Chat
              CustomButton(
                text: 'Community Chat 💬',
                onPressed: () {
                  debugPrint("Navigating to chat room for ID: ${masjidData['id']}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(masjidData: masjidData),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}