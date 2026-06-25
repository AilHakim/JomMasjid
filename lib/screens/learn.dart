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
    instructor: 'Ustaz Dr. Hafiz',
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
      CourseVideo(
          title: 'Introduction to Fiqh of Prayer',
          duration: '12:30',
          free: true),
      CourseVideo(
          title: 'Conditions of Valid Prayer', duration: '18:45', free: true),
      CourseVideo(
          title: 'Pillars of Prayer (Rukun Solat)',
          duration: '22:10',
          free: false),
      CourseVideo(
          title: 'Sunnah & Makruh in Prayer', duration: '20:00', free: false),
      CourseVideo(
          title: 'Common Mistakes in Prayer', duration: '15:30', free: false),
    ],
  ),
  Course(
    id: 2,
    title: 'Quran Tajweed Mastery',
    instructor: 'Ustazah Nurul Ain',
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
        'https://images.unsplash.com/photo-1567878578-f24aa7e63e3f?w=600&q=80',
    description:
        'Learn the correct pronunciation rules of the Quran with certified Tajweed methodology.',
    videos: [
      CourseVideo(
          title: 'Introduction to Tajweed', duration: '10:00', free: true),
      CourseVideo(title: 'Makharijul Huruf', duration: '25:00', free: false),
      CourseVideo(
          title: 'Rules of Nun Sakinah', duration: '20:00', free: false),
      CourseVideo(
          title: 'Rules of Meem Sakinah', duration: '18:00', free: false),
    ],
  ),
  Course(
    id: 3,
    title: 'Islamic Aqidah Foundation',
    instructor: 'Ustaz Ismail Kassim',
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
        'https://images.unsplash.com/photo-1542931287-023b922fa89b?w=600&q=80',
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
    instructor: 'Ustaz Rahim Bakar',
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
        'https://images.unsplash.com/photo-1588776814546-1ffbb2c3e0c9?w=600&q=80',
    description:
        'A comprehensive journey through the life, character, and legacy of Prophet Muhammad \uFDFA.',
    videos: [
      CourseVideo(
          title: 'Before the Prophethood', duration: '28:00', free: true),
      CourseVideo(title: 'First Revelation', duration: '22:00', free: true),
      CourseVideo(
          title: 'Early Muslims in Makkah', duration: '25:00', free: true),
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

  List<Course> get _filtered => _activeCategory == 'All'
      ? kCourses
      : kCourses.where((c) => c.category == _activeCategory).toList();

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
                // Search bar (visual, matches original)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          size: 16, color: AppColors.textGray),
                      const SizedBox(width: 12),
                      Text(
                        'Search classes...',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: AppColors.textGray,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 144,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _coverImage(
                  'https://images.unsplash.com/photo-1585036156171-384164a8c675?w=600&q=80'),
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
                      'FREE \u00B7 52 lessons \u00B7 2,100 students',
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
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                        color: AppColors.primary.withOpacity(0.8),
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
                    'by ${course.instructor} \u00B7 ${course.mosque}',
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
                            icon: Icons.people_outline,
                            iconColor: AppColors.textGray,
                            text: formatNumber(course.students),
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
  late bool _purchased = widget.course.priceNum == 0;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

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
                        color: Colors.white.withOpacity(0.2),
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
                      _detailStat(Icons.people_outline, AppColors.textGray,
                          '${formatNumber(course.students)} students'),
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
                            Text(
                              course.mosque,
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                color: AppColors.textGray,
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.white.withOpacity(0.6),
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
    );
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
                    onPressed: () => setState(() => _purchased = true),
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