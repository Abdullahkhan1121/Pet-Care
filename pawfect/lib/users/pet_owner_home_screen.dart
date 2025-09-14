import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect/users/pet_store.dart';
import 'package:pawfect/users/user_appbar.dart';
import 'package:pawfect/users/user_drawer.dart';

class PetOwnerHomeScreen extends StatefulWidget {
  const PetOwnerHomeScreen({super.key});

  @override
  State<PetOwnerHomeScreen> createState() => _PetOwnerHomeScreenState();
}

class _PetOwnerHomeScreenState extends State<PetOwnerHomeScreen> {
  int _selectedIndex = 0;
  final _auth = FirebaseAuth.instance;

  // ✅ Fetch User Data (optional, for greeting)
  Future<Map<String, dynamic>?> _getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();
    return doc.data();
  }

  // ✅ Bottom Nav Pages
  final List<Widget> _pages = [
    const _DashboardGrid(),
    const Center(child: Text("📖 Blogs Page (TODO)")),
  
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: const UserAppbar(),

      drawer: const UserDrawer(), // ✅ working drawer

      // ✅ Main Content
      body: _pages[_selectedIndex],

      // ✅ Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: const Color(0xFF00B14F), // ✅ Brand Green
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Blogs"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Pet Store"),
        ],
      ),
    );
  }
}

//
// 🔹 Dashboard Grid with Animated Gradient Cards + Ripple
//
class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid();

  static const List<Color> _gradientColors = [
    Color(0xFF56CCF2), // Light Blue
    Color(0xFF2F80ED), // Deep Blue
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAnimatedCard("My Pets", Icons.pets, context, "/pets"),
          _buildAnimatedCard("Health Tracking", Icons.health_and_safety, context, "/health"),
          _buildAnimatedCard("Appointments", Icons.calendar_month, context, "/appointments"),
          _buildAnimatedCard("Pet Store", Icons.store, context, "/petstore"),
          _buildAnimatedCard("My Blogs", Icons.article, context, "/myblogs"),
          _buildAnimatedCard("Feedback", Icons.feedback, context, "/feedback"),
        ],
      ),
    );
  }

  // 🔹 Animated Gradient Card with Ripple
  static Widget _buildAnimatedCard(
      String title, IconData icon, BuildContext context, String route) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;

        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),   // shrink
          onTapUp: (_) {
            setState(() => isPressed = false);                 // back to normal
            Navigator.pushNamed(context, route);               // navigate
          },
          onTapCancel: () => setState(() => isPressed = false), // cancel press
          child: AnimatedScale(
            scale: isPressed ? 0.95 : 1.0, // ✅ scaling effect
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white24, // ✅ Ripple color
                onTap: () => Navigator.pushNamed(context, route),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: _gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _gradientColors.last.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
