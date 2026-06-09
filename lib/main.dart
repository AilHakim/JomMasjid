import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'core/app_routes.dart';

void main() async {
  // Required for initializing Firebase, Location, or other native services later
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const JomMasjidApp());
}

class JomMasjidApp extends StatelessWidget {
  const JomMasjidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JomMasjid',
      debugShowCheckedModeBanner: false,
      
      // Professional Theme Management
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, // Automatically adapts if user's phone is in Dark Mode
      themeMode: ThemeMode.system, 
      
      // Professional Route Management
      initialRoute: AppRoutes.homeRoute,
      routes: AppRoutes.getRoutes(),
    );
  }
}