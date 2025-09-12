import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect/vetinarian/vet_appbar.dart';
import 'vet_drawer.dart';
import 'package:pawfect/vetinarian/theme.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  void markResolved(String id) {
    FirebaseFirestore.instance
        .collection('emergencies')
        .doc(id)
        .update({'status': 'resolved'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VetAppBar(title: "Emergency Alerts"),
      drawer: VetDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('emergencies').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final emergencies = snapshot.data!.docs;
          return ListView.builder(
            itemCount: emergencies.length,
            itemBuilder: (context, index) {
              var em = emergencies[index];
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: VetTheme.cardDecoration(),
                child: ListTile(
                  title: Text("Pet: ${em['petName']}"),
                  subtitle: Text("Issue: ${em['issue']} | Status: ${em['status']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => markResolved(em.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
