import 'package:flutter/material.dart';
import 'masjid_detail_screen.dart';

// 1. Upgraded to a StatefulWidget so the UI can react to search typing
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. We keep the master list of all Masjids safe here
  final List<Map<String, String>> allMasjids = const [
    {
      'id': 'm1',
      'name': 'Masjid Negara',
      'location': 'Kuala Lumpur, Malaysia',
      'imageUrl': 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': 'm2',
      'name': 'Masjid Wilayah Persekutuan',
      'location': 'Jalan Tuanku Abdul Halim, KL',
      'imageUrl': 'https://images.unsplash.com/photo-1542382156909-9ae37b3f56fd?auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': 'm3',
      'name': 'Masjid Putra',
      'location': 'Putrajaya, Malaysia',
      'imageUrl': 'https://images.unsplash.com/photo-1564507004663-b6dfb3c824d5?auto=format&fit=crop&w=800&q=80',
    }
  ];

  // 3. This list holds the filtered results that the user actually sees
  List<Map<String, String>> displayedMasjids = [];
  
  // 4. A controller to read what the user types in the search bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // When the app first loads, show all masjids
    displayedMasjids = allMasjids; 
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _searchController.dispose();
    super.dispose();
  }

  // 5. The Search Logic
  void _runFilter(String enteredKeyword) {
    List<Map<String, String>> results = [];
    if (enteredKeyword.isEmpty) {
      // If search field is empty, show all
      results = allMasjids;
    } else {
      // Filter based on the name OR location
      results = allMasjids.where((masjid) {
        final nameMatches = masjid['name']!.toLowerCase().contains(enteredKeyword.toLowerCase());
        final locationMatches = masjid['location']!.toLowerCase().contains(enteredKeyword.toLowerCase());
        return nameMatches || locationMatches;
      }).toList();
    }

    // Tell Flutter to redraw the screen with the new results
    setState(() {
      displayedMasjids = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Masjids'),
      ),
      body: Column(
        children: [
          // THE NEW SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value), // Runs every time a letter is typed
              decoration: InputDecoration(
                hintText: 'Search for a masjid or location...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _runFilter(''); // Reset the list
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          // THE MASJID LIST
          // We wrap the ListView in an Expanded widget so it takes up the remaining screen space below the search bar
          Expanded(
            child: displayedMasjids.isEmpty
                ? const Center(
                    child: Text(
                      'No Masjids found 🕌',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: displayedMasjids.length,
                    itemBuilder: (context, index) {
                      final masjid = displayedMasjids[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MasjidDetailScreen(masjidData: masjid),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Image.network(
                                  masjid['imageUrl']!,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      height: 180,
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        masjid['name']!,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              masjid['location']!,
                                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}