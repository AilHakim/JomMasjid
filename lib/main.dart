import 'package:flutter/material.dart';
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
      title: 'Fixed Bottom Bar',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const MasterScreen(), // Load the Master Screen first
    );
  }
}

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  // 1. Keep track of which tab is currently selected (Starts at 0)
  int _selectedIndex = 3; // Starting at 3 to match the "Events" tab in your image

  // 2. Create a list of all your different screens
  // Instead of simple Text, these would normally be your full custom screen widgets 
  // like FeedScreen(), MosquesScreen(), etc.
  final List<Widget> _pages = [
    const Center(child: Text('Feed Page', style: TextStyle(fontSize: 24))),
    const MosqueScreen(),
    const Center(child: Text('Prayer Page', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Events Page', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Learn Page', style: TextStyle(fontSize: 24))),
    const DonationScreen(),
  ];

  // 3. The function that runs when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the index and redraw the screen!
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Finance App'),
      ),
      // 4. THE BODY: Display the page from the list that matches the selected index
      body: _pages[_selectedIndex], 
      
      // 5. THE FIXED BOTTOM BAR
      bottomNavigationBar: BottomNavigationBar(
        // IMPORTANT: If you have more than 3 items, you MUST set type to fixed, 
        // otherwise Flutter hides the text and makes them weirdly animated.
        type: BottomNavigationBarType.fixed, 
        
        currentIndex: _selectedIndex, // Tells the bar which icon to highlight
        onTap: _onItemTapped,         // Tells the bar what to do when clicked
        
        selectedItemColor: Colors.orange, // The color of the active tab
        unselectedItemColor: Colors.grey, // The color of inactive tabs
        
        // The actual icons and labels matching your image
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