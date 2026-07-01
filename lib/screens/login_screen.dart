import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // To access your MasterScreen
import '../admin_screens/admin_master_screen.dart'; // To access your AdminMasterScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isAdminSelected = false; // Toggle state: false = User, true = Admin

  Future<void> signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Authenticate with Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      
      // 2. Route based on the selected role!
      if (_isAdminSelected) {
        // Route directly to the Admin Master Wrapper!
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminMasterScreen()), 
        );
      } else {
        // Route to Normal User Feed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MasterScreen()),
        );
      }

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "No account found for that email.";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = "Incorrect password.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F2ED),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mosque, size: 64, color: Color(0xFFC67C4E)),
                const SizedBox(height: 24),
                const Text(
                  "Welcome to JomMasjid",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF242424)),
                ),
                const SizedBox(height: 32),

                // --- CUSTOM ROLE TOGGLE ---
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isAdminSelected = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isAdminSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_isAdminSelected 
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] 
                                : [],
                            ),
                            child: Center(
                              child: Text(
                                "User", 
                                style: TextStyle(
                                  fontWeight: !_isAdminSelected ? FontWeight.bold : FontWeight.normal,
                                  color: !_isAdminSelected ? const Color(0xFFC67C4E) : Colors.grey.shade600
                                )
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isAdminSelected = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isAdminSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _isAdminSelected 
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] 
                                : [],
                            ),
                            child: Center(
                              child: Text(
                                "Admin", 
                                style: TextStyle(
                                  fontWeight: _isAdminSelected ? FontWeight.bold : FontWeight.normal,
                                  color: _isAdminSelected ? const Color(0xFFC67C4E) : Colors.grey.shade600
                                )
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- LOGIN FORM ---
                Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: _isAdminSelected ? "admin@masjid.com" : "matric@live.iium.edu.my",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
                const SizedBox(height: 20),

                Text("Password", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade500),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- SUBMIT BUTTON ---
                ElevatedButton(
                  onPressed: _isLoading ? null : signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688), // Teal color from your screenshot
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}