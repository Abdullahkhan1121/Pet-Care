import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({super.key});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  final _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Drawer(
        child: Center(child: Text("No user logged in")),
      );
    }

    return Drawer(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No user data found"));
          }

          final user = snapshot.data!.data() as Map<String, dynamic>;
          final base64Pic = user["ProfilePic"] as String?;
          ImageProvider? profileImage;

          if (base64Pic != null && base64Pic.isNotEmpty) {
            try {
              profileImage = MemoryImage(base64Decode(base64Pic));
            } catch (e) {
              profileImage = null;
            }
          }

          return Column(
            children: [
              // 🔹 Profile Section
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImage,
                      child: profileImage == null
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user["Name"] ?? "Guest User",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      user["Email"] ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // 🔹 Navigation Section
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Manage Profile"),
                      onTap: () => Navigator.pushNamed(context, "/profile"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.pets),
                      title: const Text("My Pets"),
                      onTap: () => Navigator.pushNamed(context, "/pets"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.health_and_safety),
                      title: const Text("Health Tracking"),
                      onTap: () => Navigator.pushNamed(context, "/health"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text("Appointments"),
                      onTap: () =>
                          Navigator.pushNamed(context, "/appointments"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.store),
                      title: const Text("Pet Store"),
                      onTap: () => Navigator.pushNamed(context, "/petstore"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.article),
                      title: const Text("My Blogs"),
                      onTap: () => Navigator.pushNamed(context, "/myblogs"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.feedback),
                      title: const Text("Feedback"),
                      onTap: () => Navigator.pushNamed(context, "/feedback"),
                    ),
                  ],
                ),
              ),

              // 🔹 Logout
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout",
                    style: TextStyle(color: Colors.red)),
                onTap: () => _logout(context),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
