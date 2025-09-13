import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin screen: lists all shelters with status = "pending"
/// Admin can approve or change status directly.
class AdminShelterApprovalPage extends StatefulWidget {
  const AdminShelterApprovalPage({super.key});

  @override
  State<AdminShelterApprovalPage> createState() =>
      _AdminShelterApprovalPageState();
}

class _AdminShelterApprovalPageState extends State<AdminShelterApprovalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Shelter Approvals')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shelters')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No pending shelter requests.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final shelters = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: shelters.length,
            itemBuilder: (context, index) {
              final doc = shelters[index];
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.home_work, color: Colors.blueAccent),
                title: Text(data['name'] ?? 'Unnamed Shelter'),
                subtitle: Text(data['address'] ?? ''),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    await FirebaseFirestore.instance
                        .collection('shelters')
                        .doc(doc.id)
                        .update({'status': value});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status updated to $value')),
                    );
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'approved',
                      child: Row(
                        children: [
                          Icon(Icons.check, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Approve'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'pending',
                      child: Row(
                        children: [
                          Icon(Icons.refresh, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Keep Pending'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
