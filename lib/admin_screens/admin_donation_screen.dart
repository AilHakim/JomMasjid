import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        title: const Text("Add New Campaign", style: TextStyle(color: Color(0xFF242424), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF242424)),
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
    );
  }

  // A helper widget to keep the code clean and match your app's aesthetic
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