// mosque_screen.dart
//
// Flutter port of the React "Nearby Mosques" screen.
// Asks for the device's location, queries OpenStreetMap's Overpass API for
// real mosques within a radius of that location, sorts them by distance,
// and lets the user open turn-by-turn directions in Google Maps.
//
// --- pubspec.yaml dependencies you'll need ---
//   dependencies:
//     flutter:
//       sdk: flutter
//     geolocator: ^14.0.3
//     google_fonts: ^6.2.1     # for Sora / Urbanist, optional but matches the design
//     url_launcher: ^6.3.0     # for the "Get Directions" button
//     http: ^1.2.0             # for querying the Overpass API
//
// --- Android: add to android/app/src/main/AndroidManifest.xml ---
//   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
//   <uses-permission android:name="android.permission.INTERNET"/>
//
//   Also add this as a SIBLING of <application>, inside <manifest>, so the
//   "Get Directions" button can actually launch Google Maps. Without this,
//   canLaunchUrl()/launchUrl() silently fail on Android 11+ due to package
//   visibility restrictions:
//
//   <queries>
//     <intent>
//       <action android:name="android.intent.action.VIEW" />
//       <data android:scheme="https" />
//     </intent>
//     <intent>
//       <action android:name="android.intent.action.VIEW" />
//       <data android:scheme="geo" />
//     </intent>
//   </queries>
//
// --- iOS: add to ios/Runner/Info.plist ---
//   <key>NSLocationWhenInUseUsageDescription</key>
//   <string>This app needs your location to find mosques near you.</string>

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────
// Color palette (mirrors the hex values used in the original Tailwind code)
// ─────────────────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFFF9F2ED);
  static const accent = Color(0xFFC67C4E);
  static const accentLight = Color(0xFFF6EBE4);
  static const textPrimary = Color(0xFF242424);
  static const textSecondary = Color(0xFF909090);
  static const success = Color(0xFF4EC67C);
  static const successBg = Color(0xFFE8F7EF);
  static const danger = Color(0xFFE84057);
  static const dangerBg = Color(0xFFF7E8E8);
  static const star = Color(0xFFF5A623);
  static const info = Color(0xFF4E8BC6);
  static const infoBg = Color(0xFFE8F0F7);
}

TextStyle sora({double size = 14, FontWeight weight = FontWeight.w600, Color? color}) =>
    GoogleFonts.sora(fontSize: size, fontWeight: weight, color: color ?? AppColors.textPrimary);

TextStyle urbanist({double size = 13, FontWeight weight = FontWeight.w400, Color? color}) =>
    GoogleFonts.urbanist(fontSize: size, fontWeight: weight, color: color ?? AppColors.textSecondary);

// ─────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────
class Mosque {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String image;
  final List<String> images;
  final String phone;
  final String website;
  final bool premium;
  final String description;

  /// Populated at runtime once the user's location is known.
  double? distanceInMeters;

  Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.images,
    required this.phone,
    required this.website,
    required this.premium,
    required this.description,
    this.distanceInMeters,
  });

  /// Human readable distance, e.g. "850 m" or "3.2 km".
  String get distanceLabel {
    if (distanceInMeters == null) return '—';
    if (distanceInMeters! < 1000) {
      return '${distanceInMeters!.toStringAsFixed(0)} m';
    }
    return '${(distanceInMeters! / 1000).toStringAsFixed(1)} km';
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Location service — wraps the geolocator package
// ─────────────────────────────────────────────────────────────────────────
class LocationService {
  /// Determines the current position of the device, handling the
  /// service-enabled and permission checks along the way.
  static Future<Position> determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
    );
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: settings,
      ).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      // GPS didn't lock in time — fall back to the last known fix rather
      // than failing outright. Still real device data, just possibly a
      // few minutes stale.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      return Future.error('Could not get a GPS fix in time. Try again outdoors or near a window.');
    }
  }

  /// Distance in meters between two coordinates.
  static double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Stream of live position updates (used for "Get Directions" / bearing if needed).
  static Stream<Position> positionStream({double distanceFilterMeters = 50}) {
    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilterMeters.toInt(),
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// Queries OpenStreetMap's Overpass API for Muslim places of worship
  /// within [radius] meters of the given coordinates.
  // Public Overpass instances to try, in order. The main server occasionally
  // rejects requests (e.g. HTTP 406/429) under load, so we fall back to a
  // mirror rather than failing outright.
  static const List<String> _overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
  ];

  static Future<List<Mosque>> fetchNearbyMosques(
    double lat,
    double lng, {
    double radius = 5000,
  }) async {
    final query = '''
      [out:json];
      (
        node["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
        way["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
        relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
      );
      out center tags;
    ''';

    http.Response? response;
    Object? lastError;

    for (final endpoint in _overpassEndpoints) {
      try {
        final candidate = await http
            .post(
              Uri.parse(endpoint),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': '*/*',
                // Overpass's usage policy asks for an identifiable client;
                // some mirrors are stricter about rejecting requests that
                // look anonymous/scripted without this.
                'User-Agent': 'JomMasjidApp/1.0 (contact: support@jommasjid.app)',
              },
              body: {'data': query},
            )
            .timeout(const Duration(seconds: 20));

        if (candidate.statusCode == 200) {
          response = candidate;
          break;
        }
        lastError = Exception(
          'Overpass endpoint $endpoint returned HTTP ${candidate.statusCode}',
        );
      } catch (e) {
        lastError = e;
        // Try the next mirror.
      }
    }

    if (response == null) {
      throw Exception(
        'Could not reach OpenStreetMap (Overpass) after trying ${_overpassEndpoints.length} servers. '
        'Last error: $lastError',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final elements = (data['elements'] as List?) ?? [];

    return elements.map((e) {
      final map = e as Map<String, dynamic>;
      // 'center' is provided for ways/relations because we requested "out center;"
      final latitude = (map['lat'] ?? map['center']?['lat'] ?? 0.0).toDouble();
      final longitude = (map['lon'] ?? map['center']?['lon'] ?? 0.0).toDouble();
      final tags = (map['tags'] as Map<String, dynamic>?) ?? {};

      return Mosque(
        id: (map['id'] as num?)?.toInt() ?? 0,
        name: tags['name'] ?? 'Surau / Mosque (Unnamed)',
        address: tags['addr:full'] ??
            tags['addr:street'] ??
            tags['addr:city'] ??
            'Address not listed on OSM',
        latitude: latitude,
        longitude: longitude,
        image: 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=600&q=80',
        images: const ['https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=600&q=80'],
        phone: tags['phone'] ?? tags['contact:phone'] ?? 'N/A',
        website: tags['website'] ?? tags['contact:website'] ?? 'N/A',
        premium: false,
        description: tags['description'] ?? 'A local mosque identified via OpenStreetMap.',
      );
    }).toList();
  }
}
// ─────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────
class MosqueScreen extends StatefulWidget {
  const MosqueScreen({super.key});

  @override
  State<MosqueScreen> createState() => _MosqueScreenState();
}

class _MosqueScreenState extends State<MosqueScreen> {
  // Above this radius (meters), treat the fix as too coarse to trust —
  // typically means it's Wi-Fi/IP-based rather than real GPS.
  static const double _lowAccuracyThresholdMeters = 1000;

  List<Mosque> _mosques = [];
  bool _isLoadingLocation = true;
  String? _locationError;
  Position? _resolvedPosition; // kept so you can see exactly what GPS returned

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// Mosques matching the current search query (by name or address).
  /// Falls back to the full list when the search box is empty.
  List<Mosque> get _filteredMosques {
    if (_searchQuery.trim().isEmpty) return _mosques;
    final q = _searchQuery.trim().toLowerCase();
    return _mosques
        .where((m) => m.name.toLowerCase().contains(q) || m.address.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadLocationAndSort();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationAndSort() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      // 1. Ask for (or confirm) location permission and get the device's coordinates.
      final position = await LocationService.determinePosition();

      // 2. Fetch real nearby mosques from OpenStreetMap.
      final liveMosques = await LocationService.fetchNearbyMosques(
        position.latitude,
        position.longitude,
      );

      // 3. Calculate exact distance from the user to each mosque.
      for (final mosque in liveMosques) {
        mosque.distanceInMeters = LocationService.distanceBetween(
          position.latitude,
          position.longitude,
          mosque.latitude,
          mosque.longitude,
        );
      }

      // 4. Sort nearest first.
      liveMosques.sort((a, b) => (a.distanceInMeters ?? double.infinity)
          .compareTo(b.distanceInMeters ?? double.infinity));

      setState(() {
        _mosques = liveMosques;
        _resolvedPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isLoadingLocation = false;
      });
    }
  }

  void _openMosqueDetail(Mosque mosque) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MosqueDetailScreen(mosque: mosque)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMosqueList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nearby Mosques', style: sora(size: 20, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 13, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(
                _isLoadingLocation
                    ? 'Locating you…'
                    : _locationError != null
                        ? 'Location unavailable · ${_mosques.length} mosques found'
                        : '${_filteredMosques.length} mosques found nearby',
                style: urbanist(size: 12),
              ),
              if (_locationError != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _loadLocationAndSort,
                  child: Text('Retry', style: urbanist(size: 12, color: AppColors.accent, weight: FontWeight.w600)),
                ),
              ],
            ],
          ),
          // TEMPORARY DEBUG LINE — remove once you've confirmed location is correct.
          // Shows exactly what GPS returned: coordinates + accuracy radius in meters.
          // A large accuracy value (e.g. 500-5000m) means the fix is coarse
          // (Wi-Fi/cell-based), not a true GPS lock — that's the usual cause
          // of "wrong" results.
          if (_resolvedPosition != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Debug: ${_resolvedPosition!.latitude.toStringAsFixed(5)}, '
                '${_resolvedPosition!.longitude.toStringAsFixed(5)} '
                '(±${_resolvedPosition!.accuracy.toStringAsFixed(0)}m)',
                style: urbanist(size: 10, color: AppColors.textSecondary),
              ),
            ),
          if (_resolvedPosition != null && _resolvedPosition!.accuracy > _lowAccuracyThresholdMeters)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your location fix is approximate (±${(_resolvedPosition!.accuracy / 1000).toStringAsFixed(1)} km). '
                      'On desktop browsers this is usually Wi-Fi/IP-based, not GPS. '
                      'Open this app on a phone outdoors for an accurate result.',
                      style: urbanist(size: 11, color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: urbanist(size: 14, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Search mosques...',
                            hintStyle: urbanist(size: 14),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => _searchController.clear(),
                          child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: const Icon(Icons.filter_list, size: 20, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMosqueList() {
    if (_isLoadingLocation) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (_locationError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 36, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'Couldn\'t get your location or nearby mosques.\n$_locationError',
                textAlign: TextAlign.center,
                style: urbanist(size: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadLocationAndSort,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                child: const Text('Try Again', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_mosques.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No mosques found within range of your location.',
            textAlign: TextAlign.center,
            style: urbanist(size: 12),
          ),
        ),
      );
    }

    final results = _filteredMosques;

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 32, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'No mosques match "$_searchQuery".',
                textAlign: TextAlign.center,
                style: urbanist(size: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final mosque = results[index];
        return MosqueCard(mosque: mosque, onTap: () => _openMosqueDetail(mosque));
      },
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────
// Mosque list card
// ─────────────────────────────────────────────────────────────────────────
class MosqueCard extends StatelessWidget {
  final Mosque mosque;
  final VoidCallback onTap;

  const MosqueCard({super.key, required this.mosque, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  children: [
                    Image.network(mosque.image, fit: BoxFit.cover, width: 112, height: 112),
                    if (mosque.premium)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                          child: const Icon(Icons.star, size: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mosque.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: sora(size: 14)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 10, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(mosque.address,
                                    maxLines: 1, overflow: TextOverflow.ellipsis, style: urbanist(size: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.navigation, size: 10, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Text(mosque.distanceLabel, style: urbanist(size: 11, weight: FontWeight.w600, color: AppColors.accent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────
// Detail screen
// ─────────────────────────────────────────────────────────────────────────
class MosqueDetailScreen extends StatefulWidget {
  final Mosque mosque;
  const MosqueDetailScreen({super.key, required this.mosque});

  @override
  State<MosqueDetailScreen> createState() => _MosqueDetailScreenState();
}

class _MosqueDetailScreenState extends State<MosqueDetailScreen> {
  final PageController _pageController = PageController();
  int _activeImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openDirections() async {
    final mosque = widget.mosque;
    final coords = '${mosque.latitude},${mosque.longitude}';

    // Try a couple of formats — geo: opens the native maps app directly on
    // Android if one is installed; the https link is the universal fallback
    // that works on iOS and Android, and falls back to a browser if no maps
    // app is installed at all.
    final candidates = <Uri>[
      Uri.parse('geo:$coords?q=$coords(${Uri.encodeComponent(mosque.name)})'),
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$coords'),
    ];

    for (final uri in candidates) {
      try {
        // Calling launchUrl directly (skipping a canLaunchUrl pre-check) is
        // the recommended approach — canLaunchUrl can return false on
        // Android 11+ due to package-visibility restrictions even when the
        // launch itself would succeed.
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return;
      } catch (_) {
        // Try the next candidate.
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps. Is it installed?')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosque = widget.mosque;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildGallery(mosque)),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(mosque.description, style: urbanist(size: 13.5, weight: FontWeight.w400).copyWith(height: 1.5)),
                      const SizedBox(height: 16),
                      _buildContactCard(mosque),
                      const SizedBox(height: 12),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          _buildCta(),
        ],
      ),
    );
  }

  Widget _buildGallery(Mosque mosque) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: mosque.images.length,
            onPageChanged: (i) => setState(() => _activeImageIndex = i),
            itemBuilder: (context, i) => Image.network(mosque.images[i], fit: BoxFit.cover),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x99000000)],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_left, color: Colors.white),
                ),
              ),
            ),
          ),
          if (mosque.premium)
            Positioned(
              top: 16,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 10, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('PREMIUM', style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          if (mosque.images.length > 1)
            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(mosque.images.length, (i) {
                  final active = i == _activeImageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mosque.name, style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(mosque.distanceLabel, style: GoogleFonts.urbanist(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Mosque mosque) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _ContactRow(icon: Icons.location_on, text: mosque.address),
          const SizedBox(height: 12),
          _ContactRow(icon: Icons.phone, text: mosque.phone),
          const SizedBox(height: 12),
          _ContactRow(icon: Icons.public, text: mosque.website, color: AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildCta() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.accentLight)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _openDirections,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.navigation, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text('Get Directions', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _ContactRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: urbanist(size: 13, color: color ?? AppColors.textPrimary))),
      ],
    );
  }
}