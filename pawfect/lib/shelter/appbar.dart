import 'package:flutter/material.dart';
import 'package:pawfect/shelter/sheltertheme.dart';

class ShelterAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ShelterAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: ShelterTheme.primaryColor, // ✅ corrected class name
      elevation: 4,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
