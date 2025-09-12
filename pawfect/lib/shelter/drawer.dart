import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect/shelter/sheltertheme.dart';

class ShelterDrawer extends StatelessWidget {
  const ShelterDrawer({super.key});

  Future<Map<String, String>> _getShelterInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        return {
          'name': snapshot['name'] ?? 'Shelter User',
          'email': snapshot['email'] ?? user.email ?? 'shelter@gmail.com',
        };
      }
    }
    return {'name': 'Shelter User', 'email': 'shelter@gmail.com'};
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 206, 206, 206), Sheltertheme.backgroundColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<Map<String, String>>(
              future: _getShelterInfo(),
              builder: (context, snapshot) {
                final name = snapshot.data?['name'] ?? "Shelter User";
                final email = snapshot.data?['email'] ?? "shelter@gmail.com";

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Sheltertheme.primaryColor,
                        Sheltertheme.secondaryColor
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  accountName: Text(name, style: Sheltertheme.bodyTextWhite),
                  accountEmail: Text(email, style: Sheltertheme.bodyTextWhite),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 40, color: Sheltertheme.primaryColor),
                  ),
                );
              },
            ),

            // Drawer Items
            _buildDrawerItem(context, Icons.dashboard, "Dashboard",
                '/shelterdash', Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(context, Icons.shopping_cart, "Manage Products",
                '/shelter-products', Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(context, Icons.home_work, "Manage Shelters",
                '/shelter-manage', Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(context, Icons.add_box, "Add Product",
                '/add-product', Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(context, Icons.add_home, "Add Shelter",
                '/add-shelter', Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(context, Icons.receipt_long, "Manage Orders",
                '/shelter-orders', Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(
                context, Icons.pets, "Add Pets", '/add-pets', Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(context, Icons.manage_accounts, "Manage Pets",
                '/shelter-pets', Color.fromARGB(255, 73, 163, 223)),


            // _buildDrawerItem(context, Icons.dashboard, "Dashboard",
            //     '/shelterdash', Colors.indigo),
            // _buildDrawerItem(context, Icons.shopping_cart, "Manage Products",
            //     '/shelter-products', Colors.green),
            // _buildDrawerItem(context, Icons.home_work, "Manage Shelters",
            //     '/shelter-manage', Colors.deepPurple),
            // _buildDrawerItem(context, Icons.add_box, "Add Product",
            //     '/add-product', Colors.teal),
            // _buildDrawerItem(context, Icons.add_home, "Add Shelter",
            //     '/add-shelter', Colors.orangeAccent),
            // _buildDrawerItem(context, Icons.receipt_long, "Manage Orders",
            //     '/shelter-orders', Colors.brown),
            // _buildDrawerItem(
            //     context, Icons.pets, "Add Pets", '/add-pets', Colors.pink),
            // _buildDrawerItem(context, Icons.manage_accounts, "Manage Pets",
            //     '/shelter-pets', Colors.blueGrey),

            const SizedBox(height: 20),

            // Logout Button styled as container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200], // ✅ Light grey background
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout",
                    style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title,
      String route, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200], // ✅ Light grey background
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => Navigator.pushReplacementNamed(context, route),
      ),
    );
  }
}
