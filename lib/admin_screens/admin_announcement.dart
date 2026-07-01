import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart'; // Adjust this path if your login screen is elsewhere

class AdminAnnouncementScreen extends StatefulWidget {
  const AdminAnnouncementScreen({super.key});

  @override
  State<AdminAnnouncementScreen> createState() => _AdminAnnouncementScreenState();
}

class _AdminAnnouncementScreenState extends State<AdminAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _mosqueNameController = TextEditingController();
  final _locationController = TextEditingController(); // NEW: Location
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageController = TextEditingController(); // NEW: Optional Image
  
  String _selectedTag = 'Announcement';
  bool _isLoading = false;

  Future<void> _postAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Generate a dynamic avatar based on the Mosque Name typed in
      String encodedName = Uri.encodeComponent(_mosqueNameController.text.trim());
      String dynamicAvatar = 'https://ui-avatars.com/api/?name=$encodedName&background=C67C4E&color=fff';

      // 2. Add exactly the fields the Feed is looking for
      await FirebaseFirestore.instance.collection('announcements').add({
        'mosque': _mosqueNameController.text.trim(),
        'location': _locationController.text.trim(),
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'tag': _selectedTag,
        // If image field is empty,
        'image': _imageController.text.isNotEmpty 
            ? _imageController.text 
            : 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=600&q=80',
        'avatar': dynamicAvatar,
        'time': FieldValue.serverTimestamp(), // Firebase server time
        'likes': 0,
        'comments': 0,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement successfully posted!', style: TextStyle(color: Colors.white))),
      );

      // Clear the specific fields, but keep Mosque Name & Location to save admin time!
      _titleController.clear();
      _contentController.clear();
      _imageController.clear();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post announcement. Check connection.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _mosqueNameController.dispose();
    _locationController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F2ED),
      appBar: AppBar(
        title: const Text("Post Update", style: TextStyle(color: Color(0xFF242424), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF242424)),
        actions: [
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
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://raw.githubusercontent.com/AilHakim/jom-masjid-assets/main/images/profile_image/IMG_0426.PNG'),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC67C4E)))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Mosque & Location
                  Row(
                    children: [
                      Expanded(flex: 3, child: _buildTextField(_mosqueNameController, "Mosque Name")),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: _buildTextField(_locationController, "Location (e.g. KL)")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  _buildTextField(_titleController, "Announcement Title"),
                  const SizedBox(height: 16),
                  
                  // Content Input
                  _buildTextField(_contentController, "Details / Content", maxLines: 5),
                  const SizedBox(height: 16),

                  // Image URL (Optional)
                  _buildTextField(_imageController, "Image URL (Optional)", isRequired: false),
                  const SizedBox(height: 16),

                  // Tag Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTag,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    items: <String>['Announcement', 'Event']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontFamily: 'Urbanist')),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTag = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _postAnnouncement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC67C4E),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Post to Feed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper Widget
  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Urbanist'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Urbanist'),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Required';
        }
        return null;
      },
    );
  }
}