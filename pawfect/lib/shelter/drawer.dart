import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect/shelter/sheltertheme.dart';

class ShelterDrawer extends StatefulWidget {
  const ShelterDrawer({super.key});

  @override
  State<ShelterDrawer> createState() => _ShelterDrawerState();
}

class _ShelterDrawerState extends State<ShelterDrawer> {
  bool _loading = true;
  bool _isApproved = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('shelters')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final status = doc.data()?['status'] as String?;
        final approvedField = doc.data()?['approved'] == true;
        setState(() {
          _isApproved = status == "approved" || approvedField;
          _loading = false;
        });
        return;
      }
    }
    setState(() {
      _isApproved = false;
      _loading = false;
    });
  }

  Future<Map<String, dynamic>> _getShelterInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        return {
          'Name': snapshot['Name'] ?? 'Shelter User',
          'Email': snapshot['Email'] ?? user.email ?? 'shelter@gmail.com',
        };
      }
    }
    return {'Name': 'Shelter User', 'Email': 'shelter@gmail.com'};
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Drawer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: ShelterTheme.mainGradient,
        ),
        child: Column(
          children: [
            /// 🔹 Top Shelter Profile Box
            FutureBuilder<Map<String, dynamic>>(
              future: _getShelterInfo(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const DrawerHeader(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                final shelterData = snapshot.data!;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: ShelterTheme.cardDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.home_work,
                            size: 35, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shelterData["Name"] ?? "Shelter User",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              shelterData["Email"] ?? "shelter@gmail.com",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            /// 🔹 Navigation items (greyed-out if not approved)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                      context, Icons.dashboard, "Dashboard", '/shelterdash'),
                  _buildDrawerItem(context, Icons.shopping_cart,
                      "Manage Products", '/shelter-products'),
                  _buildDrawerItem(context, Icons.home_work, "Manage Shelters",
                      '/shelter-manage'),
                  _buildDrawerItem(
                      context, Icons.add_box, "Add Product", '/add-product'),
                  _buildDrawerItem(
                      context, Icons.add_home, "Add Shelter", '/add-shelter'),
                  _buildDrawerItem(context, Icons.receipt_long,
                      "Manage Orders", '/shelter-orders'),
                  _buildDrawerItem(
                      context, Icons.pets, "Add Pets", '/add-pets'),
                  _buildDrawerItem(context, Icons.manage_accounts,
                      "Manage Pets", '/shelter-pets'),
                ],
              ),
            ),

            /// 🔹 Logout Button (always active)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: ShelterTheme.cardDecoration(color: Colors.redAccent),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Drawer Item Builder
  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, String route) {
    final enabled = _isApproved;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShelterTheme.cardDecoration(),
        child: ListTile(
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          onTap: enabled
              ? () => Navigator.pushReplacementNamed(context, route)
              : null,
        ),
      ),
    );
  }
}
