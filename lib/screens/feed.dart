import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import!

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Changed from int to String because Firestore Document IDs are Strings
  final Set<String> likedPosts = {};
  final Set<String> savedPosts = {};
  
  // 1. Updated filters
  String activeFilter = "All"; // Set default to 'All'
  final List<String> filters = ["All", "Donations", "Events"];

  // Dummy Story Data (Kept exactly as you liked it)
  final List<Map<String, dynamic>> stories = [
    {
      "id": 1,
      "name": "Al-Hidayah",
      "image": "https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=100&q=80",
      "storyImage": "https://images.unsplash.com/photo-1519817650390-2c24b4c29e20?w=600&q=80",
      "hasUpdate": true
    },
    {
      "id": 2,
      "name": "Masjid Omar",
      "image": "https://images.unsplash.com/photo-1542931287-023b922fa89b?w=100&q=80",
      "storyImage": "https://images.unsplash.com/photo-1564769625905-50e93615e769?w=600&q=80",
      "hasUpdate": true
    },
  ];

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

  void openStory(Map<String, dynamic> story) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryViewerScreen(story: story),
      ),
    );
    setState(() {
      story['hasUpdate'] = false;
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
                          Text("Assalamualaikum 👋", style: TextStyle(color: Color(0xFF909090), fontSize: 12, fontFamily: 'Urbanist')),
                          Text("Ahmad Rizwan", style: TextStyle(color: Color(0xFF242424), fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Sora')),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)]),
                                child: const Icon(Icons.notifications_outlined, size: 20, color: Color(0xFF242424)),
                              ),
                              Positioned(
                                top: 0, right: 0,
                                child: Container(
                                  width: 12, height: 12,
                                  decoration: BoxDecoration(color: const Color(0xFFC67C4E), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF9F2ED), width: 2)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFC67C4E), width: 2),
                              image: const DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80"), fit: BoxFit.cover),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  /*Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, size: 20, color: Color(0xFF909090)),
                        SizedBox(width: 12),
                        Text("Search mosques, events, classes...", style: TextStyle(color: Color(0xFF909090), fontSize: 14, fontFamily: 'Urbanist')),
                      ],
                    ),
                  ),*/
                ],
              ),
            ),

            // Scrollable Feed
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Stories Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Following", style: TextStyle(color: Color(0xFF242424), fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Sora')),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: const [
                              Text("See all", style: TextStyle(color: Color(0xFFC67C4E), fontSize: 12, fontFamily: 'Urbanist')),
                              Icon(Icons.chevron_right, size: 16, color: Color(0xFFC67C4E)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Horizontal Story Bar
                  SizedBox(
                    height: 85,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.white, Colors.transparent, Colors.transparent, Colors.white],
                          stops: [0.0, 0.05, 0.95, 1.0], 
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstOut,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: stories.length,
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return GestureDetector(
                            onTap: () => openStory(story),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  Container(
                                    width: 58, height: 58,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                      gradient: story['hasUpdate'] ? const LinearGradient(colors: [Color(0xFFC67C4E), Color(0xFFE8A07A)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                                      color: story['hasUpdate'] ? null : const Color(0xFFE5E5E5),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFF9F2ED), width: 2),
                                        image: DecorationImage(image: NetworkImage(story['image']), fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 58,
                                    child: Text(
                                      story['name'],
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: story['hasUpdate'] ? const Color(0xFF242424) : const Color(0xFF909090),
                                        fontSize: 10,
                                        fontWeight: story['hasUpdate'] ? FontWeight.w600 : FontWeight.normal,
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                  
                  // ==========================================
                  // NEW: Real-time Firebase Feed with Filtering
                  // ==========================================
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('announcement').snapshots(),
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
                        if (activeFilter == "Donations" && tag == "Donation") return true;
                        
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
                          final String postId = doc.id; 

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
                          if (tag == "Donation") tagColor = const Color(0xFF4EC67C); // Green for Donations
                          if (tag == "Learning") tagColor = const Color(0xFF4E8BC6); // Blue for Classes

                          final isLiked = likedPosts.contains(postId);
                          final isSaved = savedPosts.contains(postId);

                          return Container(
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
                                // Actions
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF6EBE4)))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => toggleLike(postId),
                                            child: Row(
                                              children: [
                                                Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 18, color: isLiked ? const Color(0xFFE84057) : const Color(0xFF909090)),
                                                const SizedBox(width: 6),
                                                Text("${isLiked ? likes + 1 : likes}", style: const TextStyle(color: Color(0xFF909090), fontSize: 12, fontFamily: 'Urbanist')),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Row(
                                            children: [
                                              const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF909090)),
                                              const SizedBox(width: 6),
                                              Text("$comments", style: const TextStyle(color: Color(0xFF909090), fontSize: 12, fontFamily: 'Urbanist')),
                                            ],
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.share_outlined, size: 18, color: Color(0xFF909090)),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () => toggleSave(postId),
                                        child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, size: 20, color: isSaved ? const Color(0xFFC67C4E) : const Color(0xFF909090)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

// Ensure the StoryViewerScreen from earlier is included at the bottom of the file
class StoryViewerScreen extends StatefulWidget {
  final Map<String, dynamic> story;
  const StoryViewerScreen({Key? key, required this.story}) : super(key: key);

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _animationController.stop(),
        onTapUp: (_) => _animationController.forward(),
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) Navigator.of(context).pop(); 
        },
        child: Stack(
          children: [
            Center(
              child: Image.network(
                widget.story['storyImage'] ?? widget.story['image'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _animationController.value,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 2.5,
                          borderRadius: BorderRadius.circular(10),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 18, backgroundImage: NetworkImage(widget.story['image'])),
                        const SizedBox(width: 10),
                        Text(widget.story['name'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Sora')),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop())
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}