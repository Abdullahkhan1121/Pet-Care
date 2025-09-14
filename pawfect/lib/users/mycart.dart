import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Mycart extends StatefulWidget {
  const Mycart({super.key});

  @override
  State<Mycart> createState() => _MycartState();
}

class _MycartState extends State<Mycart> {
  final _auth = FirebaseAuth.instance;
  final Color _blue = const Color(0xFF2F80ED);
  final Color _green = Colors.green;

  double totalPrice = 0.0;
  bool _placingOrder = false;

  Future<void> updateQuantity(String docId, int newQty) async {
    if (newQty <= 0) {
      await removeFromCart(docId);
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .collection("cart")
          .doc(docId)
          .update({"quantity": newQty});
    }
  }

  Future<void> removeFromCart(String docId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("cart")
        .doc(docId)
        .delete();
  }

  Future<void> placeOrder(List<QueryDocumentSnapshot> cartItems) async {
  setState(() => _placingOrder = true);

  final userId = _auth.currentUser!.uid;

  // ✅ Prepare full order data
  final orderData = {
    "userId": userId,
    "items": cartItems.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        "productId": data['productId'] ?? doc.id,
        "name": data['name'],
        "price": data['price'],
        "image": data['image'],
        "quantity": data['quantity'],
        "shelterId": data['shelterId'],
      };
    }).toList(),
    "totalPrice": totalPrice,
    "paymentMethod": "Cash on Delivery",
    "status": "Pending",
    "createdAt": FieldValue.serverTimestamp(),
  };

  try {
    // ✅ Save to global orders collection
    final orderRef =
        await FirebaseFirestore.instance.collection("orders").add(orderData);

    // ✅ Save under user's orders
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("orders")
        .doc(orderRef.id)
        .set(orderData);

    // ✅ Save under each shelter’s orders, but only THEIR products
    final sheltersMap = <String, List<Map<String, dynamic>>>{};

    for (var doc in cartItems) {
      final data = doc.data() as Map<String, dynamic>;
      final shelterId = data['shelterId'];
      if (shelterId != null) {
        sheltersMap.putIfAbsent(shelterId, () => []);
        sheltersMap[shelterId]!.add({
          "productId": data['productId'] ?? doc.id,
          "name": data['name'],
          "price": data['price'],
          "image": data['image'],
          "quantity": data['quantity'],
          "shelterId": shelterId,
        });
      }
    }

    for (final entry in sheltersMap.entries) {
      await FirebaseFirestore.instance
          .collection("shelters")
          .doc(entry.key)
          .collection("orders")
          .doc(orderRef.id)
          .set({
        ...orderData,
        "items": entry.value, // ✅ only that shelter’s items
      });
    }

    // ✅ Clear cart
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in cartItems) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing order: $e")),
      );
    }
  } finally {
    if (mounted) setState(() => _placingOrder = false);
  }
}


  void _confirmOrder(List<QueryDocumentSnapshot> cartItems) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Payment Method"),
        content: const Text("Currently only Cash on Delivery is available."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: _green, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              placeOrder(cartItems);
            },
            child:
                const Text("Cash on Delivery", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Center(child: Text("Please login to view cart."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("cart")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data!.docs;

          if (cartItems.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
          }

          // Calculate total price
          totalPrice = cartItems.fold(0.0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['price'] ?? 0).toDouble();
            final qty = (data['quantity'] ?? 1) as int;
            return sum + price * qty;
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final data = item.data() as Map<String, dynamic>;

                    final imageBase64 = data['image'] ?? '';
                    final imageBytes = imageBase64.isNotEmpty
                        ? base64Decode(imageBase64)
                        : null;

                    final name = data['name'] ?? "Unknown";
                    final price = (data['price'] ?? 0).toDouble();
                    final quantity = (data['quantity'] ?? 1) as int;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(imageBytes,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.contain),
                              )
                            : const Icon(Icons.image, size: 50),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("₨${price.toStringAsFixed(2)}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () =>
                                  updateQuantity(item.id, quantity - 1),
                            ),
                            Text(quantity.toString(),
                                style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () =>
                                  updateQuantity(item.id, quantity + 1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Total + Place Order
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Total: ₨${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _placingOrder
                        ? Center(
                            child: CircularProgressIndicator(color: _green),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: _green, width: 1.5),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _confirmOrder(cartItems),
                            child: const Text("Place Order",
                                style: TextStyle(fontSize: 18)),
                          ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
