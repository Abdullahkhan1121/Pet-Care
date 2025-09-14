import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailPage extends StatefulWidget {
  final DocumentSnapshot product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _auth = FirebaseAuth.instance; // ✅ Added

  List<DocumentSnapshot> otherProducts = [];
  bool loadingProducts = true;

  final Color _blue = const Color(0xFF2F80ED);
  final Color _green = Colors.green;

  @override
  void initState() {
    super.initState();
    fetchOtherProducts();
  }

  Future<void> fetchOtherProducts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('PetStore').get();

      setState(() {
        otherProducts =
            snapshot.docs.where((p) => p.id != widget.product.id).toList();
        loadingProducts = false;
      });
    } catch (e) {
      setState(() => loadingProducts = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  void goToProduct(DocumentSnapshot product) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  /// ✅ Add to Cart function
  Future<void> addToCart(DocumentSnapshot product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final data = product.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .doc(product.id)
        .set({
      "productId": product.id,
      "name": data['name'],
      "price": data['price'],
      "image": data['image'],
      "quantity": 1,
      "shelterId": data['shelterId'],
      "createdAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.product.data() as Map<String, dynamic>;
    final imageBytes = data['image'] != null && data['image'] != ''
        ? base64Decode(data['image'] as String)
        : null;

    final expiryTimestamp = data['expiryDate'] as Timestamp?;
    final expiryDate = expiryTimestamp?.toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Store'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    )
                  : const Center(child: Icon(Icons.image, size: 50)),
            ),

            const SizedBox(height: 16),
            Text(
              data['name'] ?? 'Unknown',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              data['description'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            if (expiryDate != null)
              Text(
                "Expiry: ${expiryDate.day.toString().padLeft(2, '0')}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.year}",
                style: TextStyle(fontSize: 14, color: Colors.red[700]),
              ),

            const SizedBox(height: 16),
            Text(
              "₨${(data['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),

            // ✅ Correct Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: _green, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => addToCart(widget.product), // ✅ fixed here
                child: const Text("Add to Cart", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),

            // Other Products Section
            const Text("Other Products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            loadingProducts
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: otherProducts.length,
                      itemBuilder: (context, index) {
                        final product = otherProducts[index];
                        final prodData =
                            product.data() as Map<String, dynamic>;
                        final imageBase64 = prodData['image'] ?? '';
                        final imageBytes = imageBase64.isNotEmpty
                            ? base64Decode(imageBase64)
                            : null;

                        return GestureDetector(
                          onTap: () => goToProduct(product),
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: imageBytes != null
                                        ? SizedBox(
                                            height: 120,
                                            width: double.infinity,
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: Image.memory(imageBytes),
                                            ),
                                          )
                                        : Container(
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Center(
                                                child:
                                                    Icon(Icons.image, size: 50)),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prodData['name'] ?? 'Unknown',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "₨${(prodData['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                "Added to wishlist")));
                                              },
                                              icon: const Icon(
                                                  Icons.favorite_border,
                                                  color: Colors.red),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  addToCart(product), // ✅ fixed
                                              icon: const Icon(
                                                  Icons.shopping_cart,
                                                  color: Color(0xFF2F80ED)),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
