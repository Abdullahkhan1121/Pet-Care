import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect/admin/appbar.dart';
import 'package:pawfect/admin/drawer.dart';
import 'theme.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminAppTheme.scaffoldBackground,
            appBar: const AdminAppBar(title: "Mange All Users"),
            drawer: AdminDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersCollection.where('role', isEqualTo: 'user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading users",
                style: AdminAppTheme.errorText,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return Center(
              child: Text(
                "No users found",
                style: AdminAppTheme.heading2,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final name = user['name'] ?? 'No Name';
              final email = user['email'] ?? 'No Email';
              final role = user['role'] ?? 'User';
              bool isActive = user['status'] == 'Inactive' ? false : true;

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
                      Text("Role: $role", style: AdminAppTheme.bodyText),
                      const SizedBox(height: 4),
                      Text(
                        "Status: ${isActive ? 'Active' : 'Inactive'}",
                        style: isActive
                            ? AdminAppTheme.activeText
                            : AdminAppTheme.inactiveText,
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 110,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Status Toggle
                        Switch(
                          value: isActive,
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                          onChanged: (value) async {
                            await usersCollection.doc(user.id).update({
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
                                content: Text("Are you sure you want to delete $name?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await usersCollection.doc(user.id).delete();
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
