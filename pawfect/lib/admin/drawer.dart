import 'package:flutter/material.dart';
import 'theme.dart';

class AdminDrawer extends StatelessWidget {
  final String? adminEmail;

  const AdminDrawer({super.key, this.adminEmail});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AdminAppTheme.mainGradient,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: AdminAppTheme.drawerHeaderGradient,
              ),
              accountName: const Text(
                "Administrator",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                adminEmail ?? "admin@gmail.com",
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.orange),
              ),
            ),

            // Drawer Items
            _buildDrawerItem(
                context, Icons.dashboard, "Dashboard", '/dashboard', const Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(
                context, Icons.people, "Users", '/users', const Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(
                context, Icons.medical_services, "Veterinarians", '/Vets', const Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(
                context, Icons.home_work, "Shelters", '/shelters', const Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(
                context, Icons.shopping_bag, "Products", '/products', const Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(
                context, Icons.event, "Appointments", '/appointments', const Color.fromARGB(255, 73, 163, 223)),
            _buildDrawerItem(
                context, Icons.event, "Approve Shelter", '/admin-approve', const Color.fromARGB(255, 73, 163, 223)),

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
                title: const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, String route, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200], // ✅ Light grey background like ShelterDrawer
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
