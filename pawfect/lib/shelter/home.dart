import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect/shelter/appbar.dart';
import 'package:pawfect/shelter/drawer.dart';
import 'package:pawfect/shelter/sheltertheme.dart';

class ShelterDashboard extends StatelessWidget {
  const ShelterDashboard({super.key});

  Future<int> _getCount(String collection) async {
    final snapshot =
        await FirebaseFirestore.instance.collection(collection).get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ShelterAppBar(title: "Paw Fect"),
      drawer: const ShelterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard("Products", Icons.shopping_cart, "products", context,
                route: '/shelter-products'),
            _buildCard("Shelters", Icons.home_work, "shelters", context,
                route: '/shelter-manage'),
            _buildCard("Orders", Icons.receipt_long, "orders", context,
                route: '/shelter-orders'),
            _buildCard("Pets", Icons.pets, "pets", context,
                route: '/shelter-pets'),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, String collection,
      BuildContext context,
      {required String route}) {
    return FutureBuilder<int>(
      future: _getCount(collection),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return StatefulBuilder(
          builder: (context, setState) {
            bool isPressed = false;

            return GestureDetector(
              onTapDown: (_) => setState(() => isPressed = true),
              onTapUp: (_) {
                setState(() => isPressed = false);
                Navigator.pushNamed(context, route);
              },
              onTapCancel: () => setState(() => isPressed = false),
              child: AnimatedScale(
                scale: isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.white24,
                    onTap: () => Navigator.pushNamed(context, route),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF56CCF2), // Light Blue
                            Color(0xFF2F80ED), // Deep Blue
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF2F80ED),
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 42, color: Colors.white),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$count",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
