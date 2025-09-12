import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawfect/shelter/appbar.dart';
import 'package:pawfect/shelter/drawer.dart';
import 'package:pawfect/shelter/sheltertheme.dart';

class ManageSheltersPage extends StatefulWidget {
  const ManageSheltersPage({super.key});

  @override
  State<ManageSheltersPage> createState() => _ManageSheltersPageState();
}

class _ManageSheltersPageState extends State<ManageSheltersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Delete shelter
  Future<void> _deleteShelter(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this shelter?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection("shelters").doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Shelter deleted successfully")),
      );
    }
  }

  // Edit shelter
  Future<void> _editShelter(DocumentSnapshot shelterDoc) async {
    final nameController = TextEditingController(text: shelterDoc['name']);
    final locationController =
        TextEditingController(text: shelterDoc['location']);
    final capacityController =
        TextEditingController(text: shelterDoc['capacity'].toString());
    final contactController =
        TextEditingController(text: shelterDoc['contact']);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Shelter"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Shelter Name"),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Capacity"),
              ),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: "Contact Info"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Sheltertheme.primaryColor,
            ),
            onPressed: () async {
              await _firestore.collection("shelters").doc(shelterDoc.id).update({
                "name": nameController.text.trim(),
                "location": locationController.text.trim(),
                "capacity": int.tryParse(capacityController.text.trim()) ?? 0,
                "contact": contactController.text.trim(),
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Shelter updated successfully")),
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShelterAppBar(title: "Manage Shelters"),
      drawer: ShelterDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("shelters")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No shelters found",
                style: Sheltertheme.bodyText,
              ),
            );
          }

          final shelters = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: shelters.length,
            itemBuilder: (ctx, i) {
              final shelter = shelters[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.home_work, color: Sheltertheme.primaryColor),
                  title: Text(
                    shelter['name'],
                    style: Sheltertheme.heading2,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📍 Location: ${shelter['location']}"),
                      Text("👥 Capacity: ${shelter['capacity']}"),
                      Text("📞 Contact: ${shelter['contact']}"),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 10,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editShelter(shelter),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteShelter(shelter.id),
                      ),
                    ],
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
