import 'package:flutter/material.dart';
import 'package:pawfect/vetinarian/theme.dart';
import 'package:pawfect/vetinarian/vet_appbar.dart';
import 'package:pawfect/vetinarian/vet_drawer.dart';

class VeterinarianHomeScreen extends StatefulWidget {
  const VeterinarianHomeScreen({super.key});

  @override
  State<VeterinarianHomeScreen> createState() => _VeterinarianHomeScreenState();
}

class _VeterinarianHomeScreenState extends State<VeterinarianHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VetAppBar(
        title: "Veterinarian Dashboard",
      ),
      drawer: VetDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              title: "Appointments",
              icon: Icons.calendar_today,
              color: VetTheme.primaryColor,
              onTap: () {
                Navigator.pushNamed(context, "/vetAppointments");
              },
            ),
            _buildDashboardCard(
              title: "Health Records",
              icon: Icons.medical_services,
              color: VetTheme.secondaryColor,
              onTap: () {
                Navigator.pushNamed(context, "/vetHealthRecords");
              },
            ),
            _buildDashboardCard(
              title: "Emergency Services",
              icon: Icons.emergency,
              color: Colors.redAccent,
              onTap: () {
                Navigator.pushNamed(context, "/vetEmergency");
              },
            ),
            _buildDashboardCard(
              title: "Profile",
              icon: Icons.person,
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, "/vetProfile");
              },
            ),
            _buildDashboardCard(
              title: "Settings",
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () {
                Navigator.pushNamed(context, "/vetSettings");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: VetTheme.cardDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 30,
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: VetTheme.heading2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
