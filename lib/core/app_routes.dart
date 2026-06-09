import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  // We only need the Home Route here now! 
  // All other screens are navigated to dynamically via MasjidDetailScreen.
  static const String homeRoute = '/';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      homeRoute: (context) => const HomeScreen(),
    };
  }
}