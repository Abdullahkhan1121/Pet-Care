import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect/vetinarian/vet_appbar.dart';
import 'vet_drawer.dart';
import 'theme.dart';

class HealthRecordsPage extends StatelessWidget {
  const HealthRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentVet = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const VetAppBar(title: "My Pet Health Records"),
      drawer: const VetDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('health_records')
            .where('vetEmail', isEqualTo: currentVet?.email) // ✅ sirf vet ke records
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No health records found."));
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              var record = records[index];
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: VetTheme.cardDecoration(),
                child: ListTile(
                  leading: const Icon(Icons.pets, color: VetTheme.primaryColor),
                  title: Text(record['petName']),
                  subtitle: Text("Condition: ${record['condition']}"),
                  trailing: Text("Species: ${record['species']}"),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: VetTheme.primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/add-health-record'); // ✅ navigate to form
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
