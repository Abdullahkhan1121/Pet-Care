import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddShelterForm extends StatefulWidget {
  const AddShelterForm({super.key});

  @override
  State<AddShelterForm> createState() => _AddShelterFormState();
}

class _AddShelterFormState extends State<AddShelterForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedType;
  bool _loading = true;
  bool _saving = false;
  String? _status; // null, "pending", "approved"

  final List<String> _shelterTypes = const [
    'Nonprofit',
    'Government',
    'Private Rescue',
    'Foster Network',
  ];

  @override
  void initState() {
    super.initState();
    _loadShelter();
  }

  Future<void> _loadShelter() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('shelters').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      _status = data['status'] as String? ?? 'pending';

      // Prefill form if approved (optional)
      _nameController.text = data['name'] ?? '';
      _licenseController.text = data['licenseNumber'] ?? '';
      _selectedType = data['type'];
      _descriptionController.text = data['description'] ?? '';
      _yearController.text = data['yearEstablished'] ?? '';
      _addressController.text = data['address'] ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _saveShelter() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('shelters').doc(uid).set({
      'name': _nameController.text.trim(),
      'licenseNumber': _licenseController.text.trim(),
      'type': _selectedType,
      'description': _descriptionController.text.trim(),
      'yearEstablished': _yearController.text.trim(),
      'address': _addressController.text.trim(),
      'status': 'pending', // always set to pending when submitting
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Shelter information submitted. Waiting for admin approval.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If the request is still pending
    if (_status == 'pending') {
      return Scaffold(
        appBar: AppBar(title: const Text('Shelter Request')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Your shelter registration request is pending admin approval.\n\n'
              'Please wait until an admin reviews and approves your request.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    // If approved or no doc yet → show form
    return Scaffold(
      appBar: AppBar(title: const Text('Add / Update Shelter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Shelter Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Shelter Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter shelter name' : null,
              ),
              const SizedBox(height: 12),

              // Registration / License Number
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(
                    labelText: 'Registration / License Number (optional)'),
              ),
              const SizedBox(height: 12),

              // Type of Shelter (dropdown)
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type of Shelter'),
                items: _shelterTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Select shelter type' : null,
              ),
              const SizedBox(height: 12),

              // Description / Mission Statement
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Description / Mission Statement'),
                minLines: 3,
                maxLines: 5,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 12),

              // Year Established
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year Established'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter year established';
                  }
                  if (int.tryParse(val) == null) {
                    return 'Enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 20),

              _saving
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _saveShelter,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Shelter Info'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
