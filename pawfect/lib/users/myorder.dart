// lib/users/myorder.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawfect/users/product_detail.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final _auth = FirebaseAuth.instance;
  String selectedFilter = "All"; // ✅ All, Pending, Delivered

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text("Please login to view orders"));
    }

    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: ["All", "Pending", "Delivered", "Cancelled"].map((filter) {
              final isSelected = selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => selectedFilter = filter);
                  },
                  selectedColor: const Color(0xFF2F80ED),
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Orders list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("orders")
                .orderBy("createdAt", descending: true) // 🔹 use same field as when placing
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              // Filter by order status
              final filtered = docs.where((doc) {
                final status = doc['status'] ?? "Pending";
                if (selectedFilter == "All") return true;
                return status == selectedFilter;
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text("No orders found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final order = filtered[index];
                  final data = order.data() as Map<String, dynamic>;
                  final items = (data['items'] as List<dynamic>? ?? []);
                  final total = (data['totalPrice'] ?? 0).toDouble();
                  final status = data['status'] ?? "Pending";

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(
                        "Order #${order.id.substring(0, 6)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        "Status: $status\nTotal: ₨${total.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      children: [
                        ...items.map((item) {
                          final imageBase64 = item['image'] ?? '';
                          final imageBytes = imageBase64.isNotEmpty
                              ? base64Decode(imageBase64)
                              : null;

                          return ListTile(
                            leading: imageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(imageBytes,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain),
                                  )
                                : const Icon(Icons.image, size: 40),
                            title: Text(item['name'] ?? "Unknown"),
                            subtitle: Text(
                                "₨${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'} x ${item['quantity'] ?? 1}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios,
                                  color: Color(0xFF2F80ED)),
                              onPressed: () async {
  final productDoc = await FirebaseFirestore.instance
      .collection("PetStore")
      .doc(item['productId'])
      .get();

  if (!productDoc.exists) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product no longer exists")),
      );
    }
    return;
  }

  if (context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: productDoc),
      ),
    );
  }
},

                            ),
                          );
                        }).toList(),

                        // Cancel button only for pending orders
                        if (status == "Pending")
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side:
                                    const BorderSide(color: Colors.red, width: 1.5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(user.uid)
                                    .collection("orders")
                                    .doc(order.id)
                                    .update({"status": "Cancelled"});

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Order cancelled")),
                                  );
                                }
                              },
                              child: const Text("Cancel Order",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
