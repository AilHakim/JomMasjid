import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Exact Colors mapped from your styles.css
  static const Color teal50 = Color(0xFFedfaf9);
  static const Color teal100 = Color(0xFFd9f4f2);
  static const Color teal200 = Color(0xFFb3e8e3);
  static const Color teal600 = Color(0xFF146c63); 
  static const Color teal700 = Color(0xFF115240); 
  static const Color teal900 = Color(0xFF082820); 
  
  static const Color neutral50 = Color(0xFFf5f7fa); 
  static const Color neutral150 = Color(0xFFdde5ee); 
  static const Color neutral500 = Color(0xFF526276); 
  static const Color neutral800 = Color(0xFF17293a); 
  static const Color neutral900 = Color(0xFF0e1f2b); 
  
  static const Color red700 = Color(0xFFb94135); 
  static const Color amber700 = Color(0xFFa64d25); 

  // 2. The Global Theme (Light)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: neutral50, 
    colorScheme: ColorScheme.fromSeed(
      seedColor: teal600,
      primary: teal600,
      secondary: neutral800,
      // FIXED: 'background' changed to 'surface' to remove the deprecation warning
      surface: neutral50, 
      error: red700,
    ),
    
    textTheme: GoogleFonts.dmSansTextTheme().copyWith(
      displayLarge: GoogleFonts.dmSerifDisplay(color: neutral800, fontWeight: FontWeight.normal),
      titleLarge: GoogleFonts.dmSans(color: neutral800, fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.dmSans(color: neutral500),
      bodyMedium: GoogleFonts.dmSans(color: neutral500),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: teal600,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9), 
        ),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: neutral800,
        backgroundColor: Colors.white,
        side: const BorderSide(color: neutral150, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    ),

    // FIXED: Changed 'CardTheme' to 'CardThemeData'
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 4, 
      shadowColor: Color(0x110E1F2B), 
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)), 
        side: BorderSide(color: neutral150, width: 1), 
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: neutral150, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: neutral150, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: teal600, width: 2),
      ),
      labelStyle: GoogleFonts.dmSans(color: neutral500, fontWeight: FontWeight.w600),
    ),
  );

  // FIXED: Added the missing darkTheme getter so main.dart stops throwing an error!
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: neutral900,
    colorScheme: ColorScheme.fromSeed(
      seedColor: teal600,
      brightness: Brightness.dark,
      surface: neutral900,
    ),
    cardTheme: const CardThemeData(
      color: neutral800,
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: neutral500, width: 1),
      ),
    ),
  );
}