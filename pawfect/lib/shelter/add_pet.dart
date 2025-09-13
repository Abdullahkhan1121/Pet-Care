// lib/shelter/add_pet.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPetPage extends StatefulWidget {
  /// If `petDoc` is provided, page acts as Edit (pre-fills fields)
  final DocumentSnapshot? petDoc;
  const AddPetPage({super.key, this.petDoc});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _breed = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _species = TextEditingController();

  String gender = 'Male'; // default
  String adoptionStatus = 'available'; // always default when adding
  String? imageBase64; // current or picked image
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.petDoc != null) _loadFromDoc(widget.petDoc!);
  }

  void _loadFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    _name.text = data['name'] ?? '';
    _age.text = data['age']?.toString() ?? '';
    _breed.text = data['breed'] ?? '';
    _notes.text = data['notes'] ?? '';
    _species.text = data['species'] ?? '';
    gender = data['gender'] ?? 'Male';
    adoptionStatus = data['adoptionStatus'] ?? 'available';
    imageBase64 = data['image'];
  }

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final picked = await p.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => imageBase64 = base64Encode(bytes));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Not logged in')));
      setState(() => _loading = false);
      return;
    }

    final docData = <String, dynamic>{
      'name': _name.text.trim(),
      'age': int.tryParse(_age.text.trim()) ?? _age.text.trim(),
      'breed': _breed.text.trim(),
      'species': _species.text.trim(),
      'gender': gender,
      'notes': _notes.text.trim(),
      'adoptionStatus': adoptionStatus, // always "available" if new
      'image': imageBase64,
      'shelterId': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.petDoc == null) {
        // create
        docData['createdAt'] = FieldValue.serverTimestamp();
        docData['adoptionStatus'] = 'available'; // enforce available
        await _firestore.collection('Pets').add(docData);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Pet added (Available by default)')));
      } else {
        // update
        await _firestore
            .collection('Pets')
            .doc(widget.petDoc!.id)
            .update(docData);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Pet updated')));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _breed.dispose();
    _notes.dispose();
    _species.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.petDoc != null;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                  image: imageBase64 != null
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(imageBase64!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageBase64 == null
                    ? const Center(
                        child: Icon(Icons.add_a_photo,
                            size: 48, color: Colors.grey))
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _age,
                  decoration: const InputDecoration(labelText: 'Age (years)'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _breed,
                  decoration: const InputDecoration(labelText: 'Breed'),
                ),
              ),
            ]),
            const SizedBox(height: 8),

            // species as text field
            TextFormField(
              controller: _species,
              decoration: const InputDecoration(labelText: 'Species'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: gender,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Unknown', child: Text('Unknown')),
              ],
              onChanged: (v) => setState(() => gender = v ?? 'Male'),
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            const SizedBox(height: 8),

            // Adoption status only in edit mode
            if (isEditing)
              DropdownButtonFormField<String>(
                value: adoptionStatus,
                items: const [
                  DropdownMenuItem(value: 'available', child: Text('Available')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'adopted', child: Text('Adopted')),
                ],
                onChanged: (v) =>
                    setState(() => adoptionStatus = v ?? 'available'),
                decoration:
                    const InputDecoration(labelText: 'Adoption Status'),
              ),
            if (isEditing) const SizedBox(height: 8),

            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Health / Notes'),
              maxLines: 3,
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Save Changes' : 'Add Pet'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
