import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect/admin/appbar.dart';
import 'package:pawfect/admin/drawer.dart';
import 'theme.dart';

class VeterinariansPage extends StatefulWidget {
  const VeterinariansPage({super.key});

  @override
  State<VeterinariansPage> createState() => _VeterinariansPageState();
}

class _VeterinariansPageState extends State<VeterinariansPage> {
  final CollectionReference vetsCollection =
      FirebaseFirestore.instance.collection('veterinarians');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(title: "Manage All Veterians"),
      drawer: AdminDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: vetsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error loading veterinarians",
                  style: AdminAppTheme.errorText),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final vets = snapshot.data!.docs;

          if (vets.isEmpty) {
            return Center(
              child: Text("No veterinarian data found",
                  style: AdminAppTheme.errorText),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vets.length,
            itemBuilder: (context, index) {
              final vet = vets[index];
              final name = vet['name'] ?? 'No Name';
              final email = vet['email'] ?? 'No Email';
              final specialization = vet['specialization'] ?? 'General Vet';
              bool isActive = vet['status'] == 'Inactive' ? false : true;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: AdminAppTheme.cardDecoration(),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(name, style: AdminAppTheme.heading2),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(email, style: AdminAppTheme.bodyText),
                      const SizedBox(height: 4),
                      Text("Specialization: $specialization",
                          style: AdminAppTheme.bodyText),
                      const SizedBox(height: 4),
                      Text(
                        isActive ? "Status: Active" : "Status: Inactive",
                        style: isActive
                            ? AdminAppTheme.activeText
                            : AdminAppTheme.inactiveText,
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Status Toggle
                        Switch(
                          value: isActive,
                          onChanged: (value) async {
                            await vetsCollection.doc(vet.id).update({
                              'status': value ? 'Active' : 'Inactive'
                            });
                          },
                        ),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Delete"),
                                content: Text(
                                    "Are you sure you want to delete $name?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await vetsCollection.doc(vet.id).delete();
                            }
                          },
                        ),
                      ],
                    ),
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
