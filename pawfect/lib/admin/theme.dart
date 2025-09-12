import 'package:flutter/material.dart';

class AdminAppTheme {
  // ------------------- 🎨 Gradients -------------------
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF6DD5FA), Color(0xFFFFFFFF), Color(0xFF2980B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient drawerHeaderGradient = LinearGradient(
    colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ------------------- 🧭 AppBar -------------------
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

  // ------------------- 🖼️ Background -------------------
  static const Color scaffoldBackground = Color(0xFFF5F7FA);

  // ------------------- 📦 Cards & Containers -------------------
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: cardShadow,
      );

  static BoxDecoration drawerItemDecoration({Color? color}) => BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      );

  // ------------------- ✍️ Text Styles -------------------
  static const TextStyle heading1 = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black);

  static const TextStyle heading2 = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black);

  static const TextStyle bodyText =
      TextStyle(fontSize: 16, color: Colors.black87);

  static const TextStyle bodyTextWhite =
      TextStyle(fontSize: 16, color: Colors.white);

  static const TextStyle errorText = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red);

  static const TextStyle activeText = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green);

  static const TextStyle inactiveText = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red);

  // ------------------- 🔘 Buttons -------------------
  static ButtonStyle primaryButtonStyle = ButtonStyle(
    shape: MaterialStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    padding: const MaterialStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
    backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
    elevation: const MaterialStatePropertyAll(4),
  );

  static Widget gradientButton({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // ------------------- 🌟 Shadows -------------------
  static List<BoxShadow> cardShadow = const [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6,
      offset: Offset(2, 3),
    ),
  ];
}
