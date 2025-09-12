import 'package:flutter/material.dart';
import 'package:pawfect/shelter/sheltertheme.dart';


class ShelterAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ShelterAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Sheltertheme.appBarTheme.backgroundColor,
      foregroundColor: Colors.black,
      elevation: Sheltertheme.appBarTheme.elevation,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
