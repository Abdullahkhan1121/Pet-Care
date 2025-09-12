import 'package:flutter/material.dart';

class Sheltertheme {
  // 🎨 Brand Colors
  static const Color primaryColor = Color(0xFF2980B9); // Blue
  static const Color secondaryColor = Color(0xFF6DD5FA); // Light Blue
  static const Color accentColor = Color(0xFF27AE60); // Green for highlights
  static const Color backgroundColor = Color(0xFFF5F6FA); // Light background
  static const Color cardColor = Colors.white;

  // 🔹 AppBar Theme
  static AppBarTheme appBarTheme = const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.black,
    elevation: 2,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  );

  // 🔹 Card Decoration
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 3),
          ),
        ],
      );

  // 🔹 Drawer / Container Decoration
  static BoxDecoration containerDecoration({Color? color}) => BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      );

  // 🔹 Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static const TextStyle bodyTextWhite = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  // 🔹 Button Theme
  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}
