import 'package:flutter/material.dart';
import 'package:jom_masjid/screens/mosques.dart'; // Make sure this matches your folder path
// import 'screens/donation_screen.dart';
// import 'screens/feed.dart';
// import 'screens/learn.dart';
import 'package:firebase_core/firebase_core.dart'; // NEW
import 'firebase_options.dart'; // NEW
import 'screens/donation_screen.dart';
import 'screens/feed.dart';
import 'screens/mosques.dart';
import 'screens/learn.dart';


void main() async {
  // Ensure Flutter is fully loaded before launching Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Boot up Firebase using the auto-generated settings
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const JomMasjidApp());
}

class JomMasjidApp extends StatelessWidget {
  const JomMasjidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jom Masjid',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        // Match the primary color used in the Mosque screen
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC67C4E)),
      ),
      home: const MasterScreen(),
    );
  }
}

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  // START AT 1: So the app instantly loads the Mosque Screen when testing
  int _selectedIndex = 1;

  // Placeholder pages (Replace these with your actual screen widgets later)
  final List<Widget> _pages = [
    const Center(child: Text('Feed Page', style: TextStyle(fontSize: 24))),
    const MosqueScreen(), // This points to the file below
    const Center(child: Text('Prayer Page', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Events Page', style: TextStyle(fontSize: 24))),
    const LearnScreen(),
    const DonationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // I commented out the AppBar so the Mosque UI goes to the top of the screen
      // appBar: AppBar(title: const Text('Islamic Finance App')), 
      body: _pages[_selectedIndex], 
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, 
        selectedItemColor: const Color(0xFFC67C4E), // Match the UI theme
        unselectedItemColor: Colors.grey, 
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Mosques'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Prayer'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'More'),
        ],
      ),
    );
  }
}