import 'package:flutter/material.dart';

class VetTheme {
  // 🎨 Gradient for headers, buttons etc.
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌟 Core Colors
  static const Color primaryColor = Color(0xFF2F80ED);
  static const Color secondaryColor = Color(0xFF56CCF2);
  static const Color accentColor = Color(0xFF27AE60); // Green for health/approval
  static const Color dangerColor = Color(0xFFE74C3C); // Red for emergencies
  static const Color scaffoldBackground = Color(0xFFF5F7FA);

  // 🧑‍⚕️ AppBar Theme
  static AppBarTheme appBarTheme = const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 1,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.black),
  );

  // 🪪 Card Decoration
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 3),
          ),
        ],
      );

  // ✍️ Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // 🔥 FIXED: const hata diya, ab safe use hoga
  static TextStyle heading2 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static const TextStyle bodyTextWhite = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  // 🔘 Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  );

  static ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: dangerColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  );

  static ButtonStyle successButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: accentColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  );
}
