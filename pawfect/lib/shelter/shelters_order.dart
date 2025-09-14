import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SheltersOrder extends StatefulWidget {
  const SheltersOrder({super.key});

  @override
  State<SheltersOrder> createState() => _SheltersOrderState();
}

class _SheltersOrderState extends State<SheltersOrder> {
  final _auth = FirebaseAuth.instance;
  String _filter = "Pending"; // Default filter

  Future<void> _updateItemStatus(
    String orderId,
    String userId,
    List<dynamic> items,
    String productId,
  ) async {
    // 🔹 Update the item inside the order
    final updatedItems = items.map((i) {
      if (i['productId'] == productId) {
        return {...i, "status": "Delivered"};
      }
      return i;
    }).toList();

    // 🔹 Check if ALL items are delivered
    final allDelivered = updatedItems.every((i) => i['status'] == "Delivered");

    try {
      // ✅ Update in global orders
      await FirebaseFirestore.instance.collection("orders").doc(orderId).update({
        "items": updatedItems,
        "status": allDelivered ? "Delivered" : "Pending",
      });

      // ✅ Update in user's subcollection orders
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("orders")
          .doc(orderId)
          .update({
        "items": updatedItems,
        "status": allDelivered ? "Delivered" : "Pending",
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(allDelivered
                ? "Order marked fully Delivered ✅"
                : "Item status updated to Delivered"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating order: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shelter = _auth.currentUser;
    if (shelter == null) {
      return const Center(child: Text("Please login as a shelter."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shelter Orders"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // 🔹 Filter dropdown
          DropdownButton<String>(
            value: _filter,
            underline: const SizedBox(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _filter = value);
              }
            },
            items: const [
              DropdownMenuItem(
                  value: "All", child: Text("All", style: TextStyle(fontSize: 14))),
              DropdownMenuItem(
                  value: "Pending",
                  child: Text("Pending", style: TextStyle(fontSize: 14))),
              DropdownMenuItem(
                  value: "Delivered",
                  child: Text("Delivered", style: TextStyle(fontSize: 14))),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allOrders = snapshot.data!.docs;

          // Filter orders that contain this shelter's products
          var shelterOrders = allOrders.where((order) {
            final data = order.data() as Map<String, dynamic>;
            final items = (data['items'] as List<dynamic>? ?? []);
            return items.any((item) => item['shelterId'] == shelter.uid);
          }).toList();

          // 🔹 Apply status filter
          if (_filter != "All") {
            shelterOrders = shelterOrders.where((order) {
              final data = order.data() as Map<String, dynamic>;
              final status = data['status'] ?? "Pending";
              return status == _filter;
            }).toList();
          }

          if (shelterOrders.isEmpty) {
            return Center(child: Text("No $_filter orders for your products."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: shelterOrders.length,
            itemBuilder: (context, index) {
              final order = shelterOrders[index];
              final data = order.data() as Map<String, dynamic>;
              final items = (data['items'] as List<dynamic>? ?? []);
              final userId = data['userId'];
              final orderId = order.id;
              final orderStatus = data['status'] ?? "Pending";

              // Show only this shelter's products
              final shelterItems = items
                  .where((item) => item['shelterId'] == shelter.uid)
                  .toList();

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    "Order #${orderId.substring(0, 6)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    "Buyer: $userId\nStatus: $orderStatus",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  children: [
                    ...shelterItems.map((item) {
                      final imageBase64 = item['image'] ?? '';
                      final imageBytes = imageBase64.isNotEmpty
                          ? base64Decode(imageBase64)
                          : null;

                      final status = item['status'] ?? "Pending";

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
                            "₨${item['price']} x ${item['quantity']} \nStatus: $status"),
                        trailing: status == "Pending"
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(
                                      color: Colors.green, width: 1.5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                                onPressed: () => _updateItemStatus(
                                    orderId, userId, items, item['productId']),
                                child: const Text("Mark Delivered"),
                              )
                            : const Icon(Icons.check_circle,
                                color: Colors.green),
                      );
                    }).toList(),
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
