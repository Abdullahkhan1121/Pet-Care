import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect/admin/appbar.dart';
import 'package:pawfect/admin/drawer.dart';
import 'theme.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AdminAppBar(title: "Manage All Products"),
     drawer: AdminDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child:
                  Text("Error loading products", style: AdminAppTheme.errorText),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return Center(
              child:
                  Text("No products found", style: AdminAppTheme.errorText),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final title = product['title'] ?? 'No Title';
              final desc = product['description'] ?? 'No Description';
              final price = product['price'] ?? '0';
              final image = product['image'] ??
                  'https://via.placeholder.com/150'; // fallback image
              final status = product['status'] ?? 'Active';

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: AdminAppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Image.network(
                        image,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AdminAppTheme.heading2),
                          const SizedBox(height: 6),
                          Text(desc, style: AdminAppTheme.bodyText),
                          const SizedBox(height: 6),
                          Text("Price: \$${price.toString()}",
                              style: AdminAppTheme.bodyText),
                          const SizedBox(height: 6),
                          Text(
                            "Status: $status",
                            style: status == "Active"
                                ? AdminAppTheme.activeText
                                : AdminAppTheme.inactiveText,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: Text(
                                        "Are you sure you want to delete $title?"),
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
                                  // Soft Delete → update status
                                  await productsCollection
                                      .doc(product.id)
                                      .update({'status': 'Deleted'});
                                }
                              },
                            ),
                          ),
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
