import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; 

void main() {
  runApp(const JomMasjidApp());
}

class JomMasjidApp extends StatelessWidget {
  const JomMasjidApp({super.key}); // FIXED: Super parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JomMasjid',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}