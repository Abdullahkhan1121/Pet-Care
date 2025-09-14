import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawfect/users/myorder.dart';
import 'package:pawfect/users/product_detail.dart';
import 'package:pawfect/users/mycart.dart';
import 'package:pawfect/users/user_drawer.dart';

class PetStore extends StatelessWidget {
  const PetStore({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pet Store"),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          bottom: const TabBar(
            labelColor: Color(0xFF2F80ED),
            unselectedLabelColor: Colors.black54,
            indicatorColor: Color(0xFF2F80ED),
            tabs: [
              Tab(icon: Icon(Icons.store), text: "PetStore"),
              Tab(icon: Icon(Icons.list_alt), text: "MyOrders"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Mycart()),
                ); // ✅ navigate to MyCart page
              },
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer(); // ✅ open wishlist sidebar
                },
              ),
            ),
          ],
        ),
        drawer: UserDrawer(),
        endDrawer: const WishlistDrawer(), // ✅ Wishlist sidebar
        body: const TabBarView(
          children: [
            PetStoreTab(),
            MyOrdersPage(),
          ],
        ),
      ),
    );
  }
}

// -------------------- PetStore Tab --------------------
class PetStoreTab extends StatefulWidget {
  const PetStoreTab({super.key});

  @override
  State<PetStoreTab> createState() => _PetStoreTabState();
}

class _PetStoreTabState extends State<PetStoreTab> {
  final _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> allProducts = [];
  List<DocumentSnapshot> filteredProducts = [];
  bool isLoading = true;
  String selectedCategory = 'All';

  final List<String> categories = ['All', 'Food', 'Grooming', 'Toys', 'Health'];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('PetStore').get();
      setState(() {
        allProducts = snapshot.docs;
        filteredProducts = allProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      filteredProducts = category == 'All'
          ? allProducts
          : allProducts
              .where((product) => product['category'] == category)
              .toList();
    });
  }

  void goToDetail(DocumentSnapshot product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

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
    "productId": product.id,               // ✅ add productId
    "name": data['name'],
    "price": data['price'],
    "image": data['image'],
    "quantity": 1,
    "shelterId": data['shelterId'],        // ✅ add shelterId
    "createdAt": FieldValue.serverTimestamp(),
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Added to cart")),
  );
}


  Future<void> toggleWishlist(DocumentSnapshot product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final wishRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .doc(product.id);

    final snap = await wishRef.get();
    if (snap.exists) {
      await wishRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from wishlist")),
      );
    } else {
      await wishRef.set({
        "name": product['name'],
        "price": product['price'],
        "image": product['image'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to wishlist")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Categories
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => filterByCategory(category),
                  selectedColor: const Color(0xFF2F80ED),
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Products Grid
        Expanded(
          child: filteredProducts.isEmpty
              ? const Center(child: Text("No products available"))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredProducts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final imageBase64 = product['image'] ?? '';
                    final imageBytes =
                        imageBase64.isNotEmpty ? base64Decode(imageBase64) : null;

                    return GestureDetector(
                      onTap: () => goToDetail(product),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
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
                                          child: Icon(Icons.image, size: 50)),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['description'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "₨${product['price']?.toStringAsFixed(2) ?? '0.00'}",
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
                                        onPressed: () => toggleWishlist(product),
                                        icon: const Icon(Icons.favorite_border,
                                            color: Colors.red),
                                      ),
                                      IconButton(
                                        onPressed: () => addToCart(product),
                                        icon: const Icon(Icons.shopping_cart,
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
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// -------------------- Wishlist Sidebar --------------------
class WishlistDrawer extends StatelessWidget {
  const WishlistDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Drawer(
        child: Center(child: Text("Please login to see wishlist")),
      );
    }

    return Drawer(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("wishlist")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text("No items in wishlist"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final doc = items[index];
              final data = doc.data() as Map<String, dynamic>;
              final imageBase64 = data['image'] ?? '';
              final imageBytes =
                  imageBase64.isNotEmpty ? base64Decode(imageBase64) : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(imageBytes,
                              width: 50, height: 50, fit: BoxFit.contain),
                        )
                      : const Icon(Icons.image, size: 40),
                  title: Text(data['name'] ?? "Unknown"),
                  subtitle: Text(
                      "₨${(data['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart,
                            color: Color(0xFF2F80ED)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailPage(product: doc),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.uid)
                              .collection("wishlist")
                              .doc(doc.id)
                              .delete();
                        },
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
