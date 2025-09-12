import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAppbar extends StatelessWidget implements PreferredSizeWidget {
  const UserAppbar({super.key});

  static const List<Color> _gradientColors = [
    Color(0xFF56CCF2), // Light Blue
    Color(0xFF2F80ED), // Deep Blue
  ];

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "PawfectCare",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications'); // TODO: add route
          },
        ),
        // IconButton(
        //   icon: const Icon(Icons.logout),
        //   onPressed: () => _logout(context),
        // ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
