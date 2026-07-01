import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_announcement.dart'; // Import the announcement screen
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart';

class AdminDonationScreen extends StatefulWidget {
  const AdminDonationScreen({super.key});

  @override
  State<AdminDonationScreen> createState() => _AdminDonationScreenState();
}

class _AdminDonationScreenState extends State<AdminDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers to grab the text the admin types in
  final _titleController = TextEditingController();
  final _mosqueController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  final _goalController = TextEditingController();
  final _daysController = TextEditingController();
  
  bool _isLoading = false;
  int _selectedIndex = 1; // 1 = Donations is selected

  // Handle Bottom Navigation taps
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Don't reload if already on the page
    
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Navigate to Announcements
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminAnnouncementScreen()),
      );
    }
  }

  Future<void> submitCampaign() async {
    // 1. Check if all required fields are filled out
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      // 2. Add a completely new document to the 'donations' collection
      await FirebaseFirestore.instance.collection('donations').add({
        'title': _titleController.text,
        'mosque': _mosqueController.text,
        'description': _descController.text,
        'image': _imageController.text.isNotEmpty 
            ? _imageController.text 
            : 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=600&q=80',
        'raised': 0, // A new campaign always starts at RM 0
        'goal': double.parse(_goalController.text),
        'donors': 0, // Starts with 0 donors
        'daysLeft': int.parse(_daysController.text),
        'category': 'General',
        'verified': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Campaign Added Successfully!", style: TextStyle(color: Colors.white))),
      );
      
      // 3. Clear the form so they can add another one
      _titleController.clear();
      _mosqueController.clear();
      _descController.clear();
      _imageController.clear();
      _goalController.clear();
      _daysController.clear();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add campaign. Check connection.")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F2ED),
      appBar: AppBar(
        title: const Text("Post Announcement", // (Or "Add New Campaign" for the donation page)
            style: TextStyle(color: Color(0xFF242424), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF242424)),
        
        // --- ADD THESE ACTIONS FOR THE PROFILE & LOGOUT ---
        actions: [
          // 1. Profile Picture
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://raw.githubusercontent.com/AilHakim/jom-masjid-assets/main/images/profile_image/IMG_0426.PNG', // Placeholder Admin Image
              ),
            ),
          ),
          
          // 2. The 3-Bar Menu (Hamburger / Dropdown)
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Color(0xFF242424)),
            onSelected: (value) async {
              if (value == 'logout') {
                // A. Sign out of Firebase securely
                await FirebaseAuth.instance.signOut();
                
                // B. Make sure the widget is still mounted before navigating
                if (!context.mounted) return;
                
                // C. Redirect to Login Screen and destroy the Admin history stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // This prevents the user from clicking the Android "Back" button to get back into the admin page
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8), // Extra padding for the right edge
        ],
        // --- END ACTIONS ---
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFC67C4E)))
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildTextField(_titleController, "Campaign Title (e.g., Roof Repair)"),
                const SizedBox(height: 16),
                _buildTextField(_mosqueController, "Mosque Name"),
                const SizedBox(height: 16),
                _buildTextField(_descController, "Description", maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField(_imageController, "Image URL (Optional)", isRequired: false),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_goalController, "Target Goal (RM)", isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_daysController, "Days Active", isNumber: true)),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: submitCampaign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC67C4E),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  child: const Text("Publish Campaign", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                )
              ],
            ),
          ),
      // --- THE NEW FOOTER ---
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

  // Helper widget
  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}