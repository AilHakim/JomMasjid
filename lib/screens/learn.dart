// learn_screen.dart
//
// Flutter port of the React "LearnScreen" component (Islamic Learning app).
//
// Setup:
//   1. Add to pubspec.yaml dependencies:
//        google_fonts: ^6.2.1
//   2. Make sure your device/emulator has internet (course images load from network).
//   3. Drop `const LearnScreen()` into your app, e.g. as a tab body or a route.
//
// Everything below is self-contained in one file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Colour palette (mirrors the hex values from the React/Tailwind version)
// ---------------------------------------------------------------------------
class AppColors {
  static const background = Color(0xFFF9F2ED);
  static const primary = Color(0xFFC67C4E);
  static const textDark = Color(0xFF242424);
  static const textGray = Color(0xFF909090);
  static const green = Color(0xFF4EC67C);
  static const gold = Color(0xFFF5A623);
  static const lightAccent = Color(0xFFF6EBE4);
  static const border = Color(0xFFE5E5E5);
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------
class CourseVideo {
  final String title;
  final String duration;
  final bool free;

  const CourseVideo({
    required this.title,
    required this.duration,
    required this.free,
  });
}

class Course {
  final int id;
  final String title;
  final String instructor;
  final String mosque;
  final double rating;
  final int students;
  final String duration;
  final int lessons;
  final String price;
  final int priceNum;
  final String category;
  final String level;
  final String image;
  final String description;
  final List<CourseVideo> videos;

  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.mosque,
    required this.rating,
    required this.students,
    required this.duration,
    required this.lessons,
    required this.price,
    required this.priceNum,
    required this.category,
    required this.level,
    required this.image,
    required this.description,
    required this.videos,
  });
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------
const List<String> kCategories = [
  'All',
  'Fiqh',
  'Quran',
  'Aqidah',
  'Seerah',
  'Arabic',
];

const List<Course> kCourses = [
  Course(
    id: 1,
    title: 'Fiqh of Prayer (Solat)',
    instructor: 'Ustaz Abdul Somad',
    mosque: 'Masjid Al-Hidayah',
    rating: 4.9,
    students: 1240,
    duration: '8h 30m',
    lessons: 24,
    price: 'RM 49',
    priceNum: 49,
    category: 'Fiqh',
    level: 'Beginner',
    image:
        'https://images.unsplash.com/photo-1585036156171-384164a8c675?w=600&q=80',
    description:
        'Master the complete rulings and spiritual dimensions of Islamic prayer from wudu to salam.',
    videos: [
      CourseVideo(title: 'Introduction to Fiqh of Prayer', duration: '12:30', free: true),
      CourseVideo(title: 'Conditions of Valid Prayer', duration: '18:45', free: true),
      CourseVideo(title: 'Pillars of Prayer (Rukun Solat)', duration: '22:10', free: false),
      CourseVideo(title: 'Sunnah & Makruh in Prayer', duration: '20:00', free: false),
      CourseVideo(title: 'Common Mistakes in Prayer', duration: '15:30', free: false),
    ],
  ),
  Course(
    id: 2,
    title: 'Quran Tajweed Mastery',
    instructor: 'Datuk Prof. Dr. Muhaya Mohammad ',
    mosque: 'Masjid Omar Al-Khattab',
    rating: 4.8,
    students: 890,
    duration: '12h 15m',
    lessons: 36,
    price: 'RM 79',
    priceNum: 79,
    category: 'Quran',
    level: 'All Levels',
    image:
        'https://images.unsplash.com/photo-1589462135796-2b46e4bdd7fe?q=80&w=686&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description:
        'Learn the correct pronunciation rules of the Quran with certified Tajweed methodology.',
    videos: [
      CourseVideo(title: 'Introduction to Tajweed', duration: '10:00', free: true),
      CourseVideo(title: 'Makharijul Huruf', duration: '25:00', free: false),
      CourseVideo(title: 'Rules of Nun Sakinah', duration: '20:00', free: false),
      CourseVideo(title: 'Rules of Meem Sakinah', duration: '18:00', free: false),
    ],
  ),
  Course(
    id: 3,
    title: 'Islamic Aqidah Foundation',
    instructor: 'Ustaz Azhar Idrus',
    mosque: 'Masjid Al-Falah',
    rating: 4.7,
    students: 654,
    duration: '6h 45m',
    lessons: 20,
    price: 'RM 35',
    priceNum: 35,
    category: 'Aqidah',
    level: 'Beginner',
    image:
        'https://images.unsplash.com/photo-1693590614566-1d3ea9ef32f7?q=80&w=1074&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description:
        'Strengthen your understanding of Islamic creed and the six pillars of faith.',
    videos: [
      CourseVideo(title: 'What is Aqidah?', duration: '14:00', free: true),
      CourseVideo(title: 'Belief in Allah', duration: '20:00', free: false),
      CourseVideo(title: 'Belief in Angels', duration: '16:00', free: false),
    ],
  ),
  Course(
    id: 4,
    title: 'Seerah: Life of the Prophet',
    instructor: 'Ustaz Kazim Elias',
    mosque: 'Masjid Al-Amin',
    rating: 5.0,
    students: 2100,
    duration: '20h 00m',
    lessons: 52,
    price: 'FREE',
    priceNum: 0,
    category: 'Seerah',
    level: 'All Levels',
    image:
        'https://images.unsplash.com/photo-1676928117296-66bc2882ec6a?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description:
        'A comprehensive journey through the life, character, and legacy of Prophet Muhammad \uFDFA.',
    videos: [
      CourseVideo(title: 'Before the Prophethood', duration: '28:00', free: true),
      CourseVideo(title: 'First Revelation', duration: '22:00', free: true),
      CourseVideo(title: 'Early Muslims in Makkah', duration: '25:00', free: true),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
/// Equivalent of JS `Number.toLocaleString()` for thousands separators.
String formatNumber(int n) {
  return n.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

/// Network image with graceful loading + error fallback.
Widget _coverImage(String url) {
  return Image.network(
    url,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Container(color: AppColors.lightAccent);
    },
    errorBuilder: (context, error, stackTrace) => Container(
      color: AppColors.lightAccent,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined,
          color: AppColors.textGray),
    ),
  );
}

// ---------------------------------------------------------------------------
// Learn Screen (course list)
// ---------------------------------------------------------------------------
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _activeCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Course> get _filtered {
    final query = _searchQuery.toLowerCase();
    return kCourses.where((c) {
      final matchesCategory =
          _activeCategory == 'All' || c.category == _activeCategory;
      final matchesSearch = query.isEmpty ||
          c.title.toLowerCase().contains(query) ||
          c.instructor.toLowerCase().contains(query) ||
          c.mosque.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ---- Header (fixed) ----
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Islamic Learning',
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Learn from certified ustaz & ustazah',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search classes...',
                      hintStyle: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: AppColors.textGray,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          size: 16, color: AppColors.textGray),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 16, color: AppColors.textGray),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---- Scrollable content ----
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeaturedBanner(),
                  const SizedBox(height: 16),
                  _buildCategoryRow(),
                  const SizedBox(height: 16),
                  // Course cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (final course in _filtered) ...[
                          _CourseCard(course: course),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    final featuredCourse = kCourses[3]; // Seerah: Life of the Prophet
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CourseDetailScreen(course: featuredCourse),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 144,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _coverImage(featuredCourse.image),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xE6242424), Colors.transparent],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u2605 TOP RATED',
                        style: GoogleFonts.urbanist(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seerah: Life of the Prophet \uFDFA',
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'FREE \u00B7 52 lessons',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: kCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = kCategories[i];
          final active = cat == _activeCategory;
          return GestureDetector(
            onTap: () => setState(() => _activeCategory = cat),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: active
                    ? null
                    : Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Course card
// ---------------------------------------------------------------------------
class _CourseCard extends StatelessWidget {
  final Course course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final isFree = course.priceNum == 0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CourseDetailScreen(course: course),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            SizedBox(
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _coverImage(course.image),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0x99000000), Colors.transparent],
                      ),
                    ),
                  ),
                  // Price badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFree ? AppColors.green : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        course.price,
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isFree ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  // Category chip
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        course.category,
                        style: GoogleFonts.urbanist(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${course.instructor}',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _miniStat(
                            icon: Icons.star,
                            iconColor: AppColors.gold,
                            text: course.rating.toString(),
                            bold: true,
                          ),
                          const SizedBox(width: 12),
                          _miniStat(
                            icon: Icons.menu_book_outlined,
                            iconColor: AppColors.textGray,
                            text: '${course.lessons} lessons',
                          ),
                        ],
                      ),
                      Text(
                        course.level,
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
    );
  }

  Widget _miniStat({
    required IconData icon,
    required Color iconColor,
    required String text,
    bool bold = false,
  }) {
    return Row(
      children: [
        Icon(icon,
            size: 12,
            color: iconColor,
            fill: icon == Icons.star ? 1 : 0),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: bold ? AppColors.textDark : AppColors.textGray,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Course detail screen
// ---------------------------------------------------------------------------
class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _purchased = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEnrollment();
  }

  Future<void> _loadEnrollment() async {
    if (widget.course.priceNum == 0) {
      setState(() { _purchased = true; _loading = false; });
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() { _loading = false; });
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('enrollments')
        .doc(widget.course.id.toString())
        .get();
    if (mounted) {
      setState(() { _purchased = doc.exists; _loading = false; });
    }
  }

  Future<void> _saveEnrollment() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('enrollments')
        .doc(widget.course.id.toString())
        .set({'enrolledAt': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ---- Hero (fixed) ----
          SizedBox(
            height: 208,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _coverImage(course.image),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xB3000000),
                        Color(0x33000000),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ),
                // Title block
                Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          course.category,
                          style: GoogleFonts.urbanist(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.title,
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---- Scrollable content ----
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _detailStat(Icons.star, AppColors.gold,
                          course.rating.toString(),
                          bold: true, fill: true),
                      _detailStat(Icons.access_time, AppColors.textGray,
                          course.duration),
                      _detailStat(Icons.menu_book_outlined,
                          AppColors.textGray, '${course.lessons} lessons'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Instructor
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.lightAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.workspace_premium_outlined,
                              size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.instructor,
                              style: GoogleFonts.sora(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    course.description,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Course content
                  Text(
                    'Course Content',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < course.videos.length; i++) ...[
                    _videoTile(i, course.videos[i]),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ---- Purchase / continue bar (fixed) ----
          _buildBottomBar(course),
        ],
      ),
    );
  }

  Widget _detailStat(IconData icon, Color color, String text,
      {bool bold = false, bool fill = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color, fill: fill ? 1 : 0),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.urbanist(
            fontSize: bold ? 14 : 12,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: bold ? AppColors.textDark : AppColors.textGray,
          ),
        ),
      ],
    );
  }

  Widget _videoTile(int index, CourseVideo video) {
    final unlocked = video.free || _purchased;

    return GestureDetector(
      onTap: unlocked
          ? () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(video: video),
              ))
          : null,
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.white.withValues(alpha:0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  unlocked ? AppColors.lightAccent : const Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              unlocked ? Icons.play_arrow : Icons.lock_outline,
              size: 14,
              color: unlocked ? AppColors.primary : AppColors.textGray,
              fill: unlocked ? 1 : 0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${index + 1}. ${video.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: unlocked ? AppColors.textDark : AppColors.textGray,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (video.free && !_purchased)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'FREE',
                style: GoogleFonts.urbanist(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
                ),
              ),
            ),
          Text(
            video.duration,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _showPaymentSheet(Course course) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(course: course),
    );
    if (confirmed == true) {
      await _saveEnrollment();
      setState(() => _purchased = true);
    }
  }

  Widget _buildBottomBar(Course course) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.lightAccent)),
      ),
      child: _purchased
          ? SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: _primaryButtonStyle(),
                child: Text(
                  'Continue Learning \u2192',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Price',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                    Text(
                      course.price,
                      style: GoogleFonts.sora(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showPaymentSheet(course),
                    style: _primaryButtonStyle(),
                    child: Text(
                      'Enrol Now',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment bottom sheet
// ---------------------------------------------------------------------------
class _PaymentSheet extends StatefulWidget {
  final Course course;
  const _PaymentSheet({required this.course});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  // 0 = select method, 1 = processing, 2 = success
  int _step = 0;
  int _selectedMethod = 0;

  final List<Map<String, dynamic>> _methods = [
    {'label': 'Credit / Debit Card', 'icon': Icons.credit_card},
    {'label': 'Online Banking (FPX)', 'icon': Icons.account_balance},
    {'label': 'Touch \'n Go eWallet', 'icon': Icons.account_balance_wallet},
  ];

  Future<void> _pay() async {
    setState(() => _step = 1);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _step = 2);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _step == 0
            ? _buildSelectMethod()
            : _step == 1
                ? _buildProcessing()
                : _buildSuccess(),
      ),
    );
  }

  Widget _buildSelectMethod() {
    return Column(
      key: const ValueKey('select'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Complete Payment',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.course.title,
          style: GoogleFonts.urbanist(
            fontSize: 13,
            color: AppColors.textGray,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightAccent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: AppColors.textGray,
                ),
              ),
              Text(
                widget.course.price,
                style: GoogleFonts.sora(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Payment Method',
          style: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _methods.length; i++) ...[
          GestureDetector(
            onTap: () => setState(() => _selectedMethod = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedMethod == i
                      ? AppColors.primary
                      : AppColors.border,
                  width: _selectedMethod == i ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(_methods[i]['icon'] as IconData,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _methods[i]['label'] as String,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  if (_selectedMethod == i)
                    const Icon(Icons.check_circle,
                        size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _pay,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Pay ${widget.course.price}',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessing() {
    return SizedBox(
      key: const ValueKey('processing'),
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Processing payment...',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please do not close this screen',
              style: GoogleFonts.urbanist(
                fontSize: 13,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return SizedBox(
      key: const ValueKey('success'),
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Successful!',
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You are now enrolled in this course',
              style: GoogleFonts.urbanist(
                fontSize: 13,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Video player screen (mock)
// ---------------------------------------------------------------------------
class VideoPlayerScreen extends StatelessWidget {
  final CourseVideo video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          video.title,
          style: GoogleFonts.sora(fontSize: 14, color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Video area
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                color: const Color(0xFF1A1A1A),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      video.title,
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video.duration,
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Mock controls bar
          Container(
            color: const Color(0xFF111111),
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            child: Column(
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: 0,
                    minHeight: 4,
                    backgroundColor: Color(0xFF333333),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0:00',
                        style: GoogleFonts.urbanist(
                            fontSize: 12, color: Colors.white54)),
                    Row(
                      children: [
                        const Icon(Icons.replay_10,
                            color: Colors.white70, size: 28),
                        const SizedBox(width: 24),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 24),
                        const Icon(Icons.forward_10,
                            color: Colors.white70, size: 28),
                      ],
                    ),
                    Text(video.duration,
                        style: GoogleFonts.urbanist(
                            fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}