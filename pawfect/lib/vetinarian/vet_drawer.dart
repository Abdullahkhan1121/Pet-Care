import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect/vetinarian/theme.dart';

class VetDrawer extends StatelessWidget {
  const VetDrawer({super.key});

  Future<Map<String, dynamic>?> _getVetData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('vets')
        .doc(user.uid)
        .get();

    if (snapshot.exists) {
      return snapshot.data();
    } else {
      return {"name": "Veterinarian", "email": user.email};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(gradient: VetTheme.mainGradient),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// 🔹 Top Vet Profile Box
            FutureBuilder<Map<String, dynamic>?>(
              future: _getVetData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const DrawerHeader(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                var vetData = snapshot.data!;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: VetTheme.cardDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.medical_services,
                            size: 35, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vetData["name"] ?? "Veterinarian",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(vetData["email"] ?? "vet@gmail.com",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            /// 🔹 Drawer Navigation Items
            _buildDrawerItem(context, Icons.home, "Home", '/vet-home'),
            _buildDrawerItem(
                context, Icons.add_circle, "Add Health Record", '/add-health-record'),
            _buildDrawerItem(context, Icons.pets, "Manage Health Records",
                '/vet-health'),
            _buildDrawerItem(
                context, Icons.event, "Appointments", '/vet-appointments'),
            _buildDrawerItem(
                context, Icons.warning, "Emergency", '/vet-emergency'),

            const SizedBox(height: 20),

            /// 🔹 Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: VetTheme.cardDecoration(color: Colors.redAccent),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text("Logout",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Reusable Drawer Item Builder
  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, String route) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: VetTheme.cardDecoration(),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => Navigator.pushReplacementNamed(context, route),
      ),
    );
  }
}
