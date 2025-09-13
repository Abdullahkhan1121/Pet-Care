import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Added for shelterId
import 'package:intl/intl.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance; // ✅ for current user

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String category = "Food";
  String? productPicBase64;
  DateTime? expiryDate;
  bool _loading = false;

  // ✅ Pick product image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        productPicBase64 = base64Encode(bytes);
      });
    }
  }

  // ✅ Pick expiry date
  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => expiryDate = picked);
    }
  }

  // ✅ Save Product
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final productData = {
        "name": nameCtrl.text,
        "category": category,
        "price": double.tryParse(priceCtrl.text) ?? 0.0,
        "stock": int.tryParse(stockCtrl.text) ?? 0,
        "description": descCtrl.text,
        "image": productPicBase64, // ✅ renamed for clarity
        "shelterId": user.uid, // ✅ filter support
        if (category == "Food" || category == "Health")
          "expiryDate":
              expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
        "createdAt": FieldValue.serverTimestamp(), // ✅ ordering
      };

      await _firestore.collection("PetStore").add(productData);

      // ✅ Clear form after save
      nameCtrl.clear();
      priceCtrl.clear();
      stockCtrl.clear();
      descCtrl.clear();
      setState(() {
        category = "Food";
        productPicBase64 = null;
        expiryDate = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Product added successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving product: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ✅ Product Image Picker (rectangular card)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                    image: productPicBase64 != null
                        ? DecorationImage(
                            image: MemoryImage(base64Decode(productPicBase64!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: productPicBase64 == null
                      ? const Center(
                          child: Icon(Icons.add_photo_alternate,
                              size: 50, color: Colors.grey),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Product Name"),
                validator: (val) => val!.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: category,
                items: const [
                  DropdownMenuItem(value: "Food", child: Text("Food")),
                  DropdownMenuItem(value: "Grooming", child: Text("Grooming")),
                  DropdownMenuItem(value: "Toys", child: Text("Toys")),
                  DropdownMenuItem(value: "Health", child: Text("Health")),
                ],
                onChanged: (val) => setState(() => category = val!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Enter price" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: stockCtrl,
                decoration: const InputDecoration(labelText: "Stock Quantity"),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Enter stock quantity" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),

              // ✅ Expiry Date (only for Food/Health)
              if (category == "Food" || category == "Health")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Expiry Date",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickExpiryDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          expiryDate != null
                              ? DateFormat("dd MMM yyyy").format(expiryDate!)
                              : "Select Date",
                          style: TextStyle(
                              color: expiryDate != null
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

              // ✅ Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Product",
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
