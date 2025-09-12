import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect/shelter/appbar.dart';
import 'package:pawfect/shelter/drawer.dart';
import 'package:pawfect/shelter/sheltertheme.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();

  // Images
  final ImagePicker _picker = ImagePicker();
  List<Uint8List> _selectedImages = [];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _expiryController.dispose();
    _dosageController.dispose();
    _weightController.dispose();
    _materialController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  // Pick multiple images (works on web + mobile)
  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 70);

      if (pickedFiles.isNotEmpty) {
        List<Uint8List> imageBytes = [];
        for (var file in pickedFiles) {
          final bytes = await file.readAsBytes();
          imageBytes.add(bytes);
        }

        setState(() {
          _selectedImages = imageBytes;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ No images selected"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error picking images: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate() &&
        _selectedCategory != null &&
        _selectedImages.isNotEmpty) {
      try {
        // Convert images to base64
        List<String> base64Images =
            _selectedImages.map((bytes) => base64Encode(bytes)).toList();

        // Product data
        final productData = {
          "category": _selectedCategory,
          "name": _nameController.text.trim(),
          "price": double.tryParse(_priceController.text.trim()) ?? 0,
          "description": _descController.text.trim(),
          "images": base64Images,
          "createdAt": FieldValue.serverTimestamp(),
          "isDeleted": false,
        };

        if (_selectedCategory == "Medicine") {
          productData["expiryDate"] = _expiryController.text.trim();
          productData["dosage"] = _dosageController.text.trim();
        } else if (_selectedCategory == "Food") {
          productData["expiryDate"] = _expiryController.text.trim();
          productData["weight"] = _weightController.text.trim();
        } else if (_selectedCategory == "Accessories") {
          productData["material"] = _materialController.text.trim();
          productData["size"] = _sizeController.text.trim();
        }

        await FirebaseFirestore.instance
            .collection("products")
            .add(productData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Product added in $_selectedCategory category!"),
            backgroundColor: Sheltertheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Clear fields
        _nameController.clear();
        _priceController.clear();
        _descController.clear();
        _expiryController.clear();
        _dosageController.clear();
        _weightController.clear();
        _materialController.clear();
        _sizeController.clear();
        setState(() {
          _selectedCategory = null;
          _selectedImages = [];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to add product: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete the form and select images"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShelterAppBar(title: "Add Products"),
      drawer: const ShelterDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Select Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category,
                      color: Sheltertheme.primaryColor),
                ),
                items: ["Medicine", "Food", "Accessories"].map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select a category" : null,
              ),
              const SizedBox(height: 20),

              // ✅ Show Image Picker only after category is selected
              if (_selectedCategory != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Sheltertheme.primaryColor,
                    ),
                    onPressed: _pickImages,
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text(
                      "Pick Images",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _selectedImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],

              if (_selectedCategory != null) ..._buildCategoryFields(),

              if (_selectedCategory != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Sheltertheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitProduct,
                  child: const Text(
                    "Add Product",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategoryFields() {
    List<Widget> fields = [
      _buildTextField(
        controller: _nameController,
        label: "Product Name",
        icon: Icons.shopping_bag,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _priceController,
        label: "Price",
        icon: Icons.attach_money,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _descController,
        label: "Description",
        icon: Icons.description,
        maxLines: 3,
      ),
      const SizedBox(height: 16),
    ];

    if (_selectedCategory == "Medicine") {
      fields.addAll([
        _buildTextField(
          controller: _expiryController,
          label: "Expiry Date",
          icon: Icons.calendar_today,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _dosageController,
          label: "Dosage Instructions",
          icon: Icons.medical_information,
        ),
      ]);
    } else if (_selectedCategory == "Food") {
      fields.addAll([
        _buildTextField(
          controller: _expiryController,
          label: "Expiry Date",
          icon: Icons.calendar_today,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _weightController,
          label: "Weight",
          icon: Icons.scale,
        ),
      ]);
    } else if (_selectedCategory == "Accessories") {
      fields.addAll([
        _buildTextField(
          controller: _materialController,
          label: "Material",
          icon: Icons.layers,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _sizeController,
          label: "Size",
          icon: Icons.straighten,
        ),
      ]);
    }

    return fields;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? "Please enter $label" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Sheltertheme.primaryColor),
        labelText: label,
        labelStyle: const TextStyle(color: Sheltertheme.primaryColor),
        filled: true,
        fillColor: Colors.grey.shade100,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Sheltertheme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Sheltertheme.secondaryColor, width: 2),
        ),
      ),
    );
  }
}
