import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ManageProfilePage extends StatefulWidget {
  const ManageProfilePage({super.key});

  @override
  State<ManageProfilePage> createState() => _ManageProfilePageState();
}

class _ManageProfilePageState extends State<ManageProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  String? _profilePicBase64;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser?.uid;
    _email = _auth.currentUser?.email;
    if (uid == null) return;

    final doc = await _firestore.collection("Users").doc(uid).get();
    final data = doc.data();

    if (data != null) {
      _nameController.text = data["Name"] ?? "";
      _aboutController.text = data["About"] ?? "";
      _profilePicBase64 = data["ProfilePic"];
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection("Users").doc(uid).update({
      "Name": _nameController.text,
      "About": _aboutController.text,
      "ProfilePic": _profilePicBase64,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully ✅")),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final ext = picked.name.split(".").last.toLowerCase();
    if (!(ext == "jpg" || ext == "jpeg" || ext == "png")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unsupported image format ❌")),
      );
      return;
    }

    final bytes = await picked.readAsBytes();
    final base64Image = base64Encode(bytes);

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _profilePicBase64 = base64Image;
    });

    await _firestore.collection("Users").doc(uid).update({
      "ProfilePic": base64Image,
    });
  }

  Future<void> _removeProfilePic() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _profilePicBase64 = null;
    });

    await _firestore.collection("Users").doc(uid).update({
      "ProfilePic": null,
    });
  }

  Future<void> _changePasswordDialog() async {
    final TextEditingController passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "New Password",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _auth.currentUser?.updatePassword(passController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password changed successfully ✅"),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Profile"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profilePicBase64 != null
                        ? MemoryImage(base64Decode(_profilePicBase64!))
                        : null,
                    child: _profilePicBase64 == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: PopupMenuButton<String>(
                      icon: const CircleAvatar(
                        backgroundColor: Color(0xFF2F80ED),
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                      onSelected: (value) {
                        if (value == "Change") {
                          _pickImage();
                        } else if (value == "Remove") {
                          _removeProfilePic();
                        }
                      },
                      itemBuilder: (context) {
                        final items = <PopupMenuEntry<String>>[
                          const PopupMenuItem(
                            value: "Change",
                            child: Text("Change Picture"),
                          ),
                        ];
                        if (_profilePicBase64 != null) {
                          items.add(
                            const PopupMenuItem(
                              value: "Remove",
                              child: Text("Remove Picture"),
                            ),
                          );
                        }
                        return items;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Email Display
            Text(
              _email ?? "No Email",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Name Field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 16),

            // 🔹 About Me Field
            TextField(
              controller: _aboutController,
              decoration: const InputDecoration(labelText: "About Me"),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // 🔹 Change Password Button
            ElevatedButton.icon(
              onPressed: _changePasswordDialog,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.lock),
              label: const Text("Change Password"),
            ),
            const SizedBox(height: 24),

            // 🔹 Save Button
            ElevatedButton.icon(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
