import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect/shelter/appbar.dart';
import 'package:pawfect/shelter/drawer.dart';

class ShelterDashboard extends StatefulWidget {
  const ShelterDashboard({super.key});

  @override
  State<ShelterDashboard> createState() => _ShelterDashboardState();
}

class _ShelterDashboardState extends State<ShelterDashboard> {
  String? _status; // null / pending / approved
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchShelterStatus();
  }

  Future<void> _fetchShelterStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('shelters')
        .doc(user.uid)
        .get();

    setState(() {
      if (!doc.exists) {
        _status = null;
      } else {
        _status = doc.data()?['status'] as String? ??
            (doc.data()?['approved'] == true ? "approved" : "pending");
      }
      _loading = false;
    });
  }

  bool get _isApproved => _status == "approved";
  bool get _isNewOrPending => _status == null || _status == "pending";

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const ShelterAppBar(title: "Shelter Dashboard"),
      drawer: const ShelterDrawer(), // <-- only your drawer widget now
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: _buildCards(context),
        ),
      ),
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    final cards = <Widget>[];

    // Add Shelter card (only if not approved)
    if (_isNewOrPending) {
      cards.add(
        _buildCard(
          "Add Shelter",
          Icons.add_home,
          context,
          route: '/add-shelter',
          enabled: true,
        ),
      );
    }

    // Other shelter features (always visible but disabled until approved)
    cards.addAll([
      _buildCard("Manage Products", Icons.shopping_cart, context,
          route: '/shelter-products', enabled: _isApproved),
      _buildCard("Orders", Icons.receipt_long, context,
          route: '/shelter-orders', enabled: _isApproved),
     _buildCard("Pet Listings", Icons.list_alt, context,
          route: '/pet-listings', enabled: _isApproved),
      _buildCard("Adoption Requests", Icons.favorite, context,
          route: '/adoption-requests', enabled: _isApproved),
      _buildCard("Success Stories", Icons.emoji_emotions, context,
          route: '/success-stories', enabled: _isApproved),
      _buildCard("Volunteer Signup", Icons.group_add, context,
          route: '/volunteer-form', enabled: _isApproved),
      _buildCard("Donation Intents", Icons.volunteer_activism, context,
          route: '/donation-form', enabled: _isApproved),
    ]);

    return cards;
  }

  Widget _buildCard(
    String title,
    IconData icon,
    BuildContext context, {
    required String route,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? () => Navigator.pushNamed(context, route) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled
                  ? [const Color(0xFF56CCF2), const Color(0xFF2F80ED)]
                  : [Colors.grey.shade400, Colors.grey.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
