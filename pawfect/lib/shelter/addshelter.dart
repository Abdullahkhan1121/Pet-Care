import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect/shelter/appbar.dart';
import 'package:pawfect/shelter/drawer.dart';
import 'package:pawfect/shelter/sheltertheme.dart';

class AddShelterPage extends StatefulWidget {
  const AddShelterPage({super.key});

  @override
  State<AddShelterPage> createState() => _AddShelterPageState();
}

class _AddShelterPageState extends State<AddShelterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitShelter() async {
    if (_formKey.currentState!.validate()) {
      try {
        final shelterData = {
          "name": _nameController.text.trim(),
          "location": _locationController.text.trim(),
          "capacity": int.tryParse(_capacityController.text.trim()) ?? 0,
          "contact": _contactController.text.trim(),
          "description": _descriptionController.text.trim(),
          "createdAt": FieldValue.serverTimestamp(),
          "isDeleted": false,
        };

        await FirebaseFirestore.instance.collection("shelters").add(shelterData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✅ Shelter added successfully!"),
            backgroundColor: Sheltertheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Clear fields
        _nameController.clear();
        _locationController.clear();
        _capacityController.clear();
        _contactController.clear();
        _descriptionController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to add shelter: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShelterAppBar(title: "Add Shelter"),
      drawer: ShelterDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                  controller: _nameController,
                  label: "Shelter Name",
                  icon: Icons.home),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _locationController,
                  label: "Location",
                  icon: Icons.location_on),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _capacityController,
                label: "Capacity",
                icon: Icons.people,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _contactController,
                label: "Contact Number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: "Description",
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Sheltertheme.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitShelter,
                child: const Text(
                  "Add Shelter",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
