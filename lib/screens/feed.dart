import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Changed from int to String because Firestore Document IDs are Strings
  final Set<String> likedPosts = {};
  final Set<String> savedPosts = {};
  
  // 1. Updated filters
  String activeFilter = "All"; // Set default to 'All'
  final List<String> filters = ["All", "Announcements", "Events"];

  void toggleLike(String id) {
    setState(() {
      likedPosts.contains(id) ? likedPosts.remove(id) : likedPosts.add(id);
    });
  }

  void toggleSave(String id) {
    setState(() {
      savedPosts.contains(id) ? savedPosts.remove(id) : savedPosts.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F2ED),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              height: 80,
              color: const Color(0xFFF9F2ED),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Assalamualaikum yoww👋", style: TextStyle(color: Color(0xFF909090), fontSize: 12, fontFamily: 'Urbanist')),
                          Text("Ail Hakim", style: TextStyle(color: Color(0xFF242424), fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Sora')),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                        
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Log Out'),
                                  content: const Text('Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await FirebaseAuth.instance.signOut();
                                if (!context.mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFC67C4E), width: 2),
                                image: const DecorationImage(image: NetworkImage("https://raw.githubusercontent.com/AilHakim/jom-masjid-assets/main/images/profile_image/IMG_0426.PNG"), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                 
                ],
              ),
            ),

            // Scrollable Feed
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                 
                  // Filter Pills (Now only shows 'Events')
                  SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isActive = activeFilter == filter;
                        return GestureDetector(
                          onTap: () => setState(() => activeFilter = filter),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFFC67C4E) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isActive ? null : Border.all(color: const Color(0xFFE5E5E5)),
                            ),
                            child: Center(
                              child: Text(
                                filter,
                                style: TextStyle(color: isActive ? Colors.white : const Color(0xFF242424), fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Urbanist'),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  
                  // NEW: Real-time Firebase Feed with Filtering
                  
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('announcements').snapshots(),
                    builder: (context, snapshot) {
                      
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      // 1. Show loading spinner while fetching
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(color: Color(0xFFC67C4E)),
                          ),
                        );
                      }

                      // 2. Extract all documents from Firebase
                      final allPosts = snapshot.data?.docs ?? [];

                      // 3. FILTER LOGIC: Keep only the posts that match the active tab
                      final filteredPosts = allPosts.where((doc) {
                        if (activeFilter == "All") return true; // Show everything
                        
                        final data = doc.data() as Map<String, dynamic>;
                        final String tag = data['tag'] ?? '';

                        // Match the tab name to the exact tag saved in Firebase
                        if (activeFilter == "Events" && tag == "Event") return true;
                        if (activeFilter == "Announcements" && tag == "Announcement") return true;
                        
                        return false; // Hide it if it doesn't match
                      }).toList();

                      // 4. Show Empty State if no data matches the current filter
                      if (filteredPosts.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              children: [
                                const Icon(Icons.inbox_outlined, size: 64, color: Color(0xFFD1D1D1)),
                                const SizedBox(height: 16),
                                Text(
                                  activeFilter == "All" 
                                      ? "No Announcements Yet" 
                                      : "No $activeFilter Right Now",
                                  style: const TextStyle(color: Color(0xFF242424), fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Sora'),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "When mosques post new updates,\nthey will appear here.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF909090), fontSize: 14, fontFamily: 'Urbanist'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // 5. Build the feed with the FILTERED database data
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredPosts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final doc = filteredPosts[index];
                          final data = doc.data() as Map<String, dynamic>;
                          //final String postId = doc.id; 

                          final String mosque = data['mosque'] ?? 'Unknown Mosque';
                          final String location = data['location'] ?? 'Location TBA';
                          
                          // SAFE TIMESTAMP EXTRACTION
                          String time = 'Recently';
                          if (data['time'] is String) {
                            time = data['time']; 
                          } else if (data['time'] is Timestamp) {
                            DateTime dateTime = (data['time'] as Timestamp).toDate();
                            time = "${dateTime.day}/${dateTime.month}/${dateTime.year}"; 
                          }

                          final String title = data['title'] ?? 'No Title';
                          final String content = data['content'] ?? '';
                          final String avatar = data['avatar'] ?? 'https://ui-avatars.com/api/?name=Mosque';
                          final String tag = data['tag'] ?? 'Announcement';
                          final String? image = data['image'];
                          final int likes = data['likes'] ?? 0;
                          final int comments = data['comments'] ?? 0;

                          // Color-code the tag dynamically
                          Color tagColor = const Color(0xFFC67C4E); // Default Orange for Events
                          if (tag == "Event") tagColor = const Color(0xFF4EC67C); // Green for Donations
                          if (tag == "Announcement") tagColor = const Color(0xFF4E8BC6); // Blue for Classes

                          //final isLiked = likedPosts.contains(postId);
                          //final isSaved = savedPosts.contains(postId);

                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PostDetailScreen(
                                  mosque: mosque,
                                  location: location,
                                  time: time,
                                  title: title,
                                  content: content,
                                  avatar: avatar,
                                  tag: tag,
                                  tagColor: tagColor,
                                  image: image,
                                  likes: likes,
                                  comments: comments,
                                ),
                              ),
                            ),
                            child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Padding(
                                  padding: const EdgeInsets.all(16).copyWith(bottom: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatar)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(mosque, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Sora')),
                                            Text("$location · $time", style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'Urbanist')),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: tagColor, 
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          tag,
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Urbanist'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Image
                                if (image != null && image.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(image, height: 176, width: double.infinity, fit: BoxFit.cover),
                                    ),
                                  ),
                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title, style: const TextStyle(color: Color(0xFF242424), fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Sora')),
                                      const SizedBox(height: 4),
                                      Text(content, style: const TextStyle(color: Color(0xFF909090), fontSize: 12, height: 1.5, fontFamily: 'Urbanist')),
                                    ],
                                  ),
                                ),
                              
                              ],
                            ),
                            ),
                          );
                        },
                      );
                    },
                  ),
           ], ),
        ),],
        ),
      ),
    );
  }
}

class PostDetailScreen extends StatelessWidget {
  final String mosque, location, time, title, content, avatar, tag;
  final Color tagColor;
  final String? image;
  final int likes, comments;

  const PostDetailScreen({
    super.key,
    required this.mosque,
    required this.location,
    required this.time,
    required this.title,
    required this.content,
    required this.avatar,
    required this.tag,
    required this.tagColor,
    required this.image,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F2ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF242424)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(radius: 22, backgroundImage: NetworkImage(avatar)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mosque, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'Sora')),
                      Text('$location · $time', style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Urbanist')),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Urbanist')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Image
            if (image != null && image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(image!, width: double.infinity, fit: BoxFit.cover),
              ),
            if (image != null && image!.isNotEmpty) const SizedBox(height: 20),
            // Title
            Text(title, style: const TextStyle(color: Color(0xFF242424), fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Sora')),
            const SizedBox(height: 12),
            // Content
            Text(content, style: const TextStyle(color: Color(0xFF909090), fontSize: 14, height: 1.7, fontFamily: 'Urbanist')),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
