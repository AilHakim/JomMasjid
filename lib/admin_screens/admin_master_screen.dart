import 'package:flutter/material.dart';
import 'admin_announcement.dart';
import 'admin_donation_screen.dart';

class AdminMasterScreen extends StatefulWidget {
  const AdminMasterScreen({super.key});

  @override
  State<AdminMasterScreen> createState() => _AdminMasterScreenState();
}

class _AdminMasterScreenState extends State<AdminMasterScreen> {
  int _selectedIndex = 0;

  // This list holds the actual screens we want to display
  final List<Widget> _adminPages = [
    const AdminAnnouncementScreen(),
    const AdminDonationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack is magic! It keeps all pages loaded in the background 
      // so you don't lose the text you typed when switching tabs.
      body: IndexedStack(
        index: _selectedIndex,
        children: _adminPages,
      ),
      
      // The ONE permanent footer for the entire Admin experience
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFc67c4e),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Donations',
          ),
        ],
      ),
    );
  }
}