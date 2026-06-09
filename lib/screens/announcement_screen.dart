import 'package:flutter/material.dart';

class AnnouncementScreen extends StatelessWidget {
  // 1. ADDED: This variable catches the specific data passed from the MasjidDetailScreen
  final Map<String, String> masjidData;

  // 2. UPDATED: Require the masjidData in the constructor
  const AnnouncementScreen({super.key, required this.masjidData});

  // Dummy data to simulate Firebase Cloud Firestore data for now
  final List<Map<String, String>> announcements = const [
    {
      'title': 'Ramadhan Tarawih Schedule',
      'date': '10 March 2026',
      'content': 'Tarawih prayers will begin immediately after Isyak at 8:45 PM. A guest Imam will be leading the prayers for the first week. All are welcome!',
      'author': 'Admin Masjid',
    },
    {
      'title': 'Gotong-Royong Perdana',
      'date': '15 March 2026',
      'content': 'Join us this Sunday morning for a community cleanup around the masjid compound in preparation for Ramadhan. Breakfast will be provided!',
      'author': 'AJK Keselamatan',
    },
    {
      'title': 'Friday Khutbah Topic',
      'date': '18 March 2026',
      'content': 'This week\'s Friday Khutbah will cover the importance of community charity and helping neighbors in need.',
      'author': 'Imam Besar',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 3. UPDATED: The title now dynamically displays the Masjid's name!
        title: Text('${masjidData['name']} Announcements 📢'),
      ),
      // ListView.builder is highly optimized for scrolling through a feed of items
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final item = announcements[index];
          
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      // Note: If you fully switched to the CertiTrust Teal theme earlier, 
                      // you can change Colors.green to AppTheme.teal600 here!
                      color: Colors.green, 
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item['date']} • By ${item['author']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Divider(height: 24, thickness: 1),
                  Text(
                    item['content']!,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}