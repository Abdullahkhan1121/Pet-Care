import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme.dart';
import 'vet_appbar.dart';
import 'vet_drawer.dart';

class AddHealthRecordPage extends StatefulWidget {
  const AddHealthRecordPage({super.key});

  @override
  State<AddHealthRecordPage> createState() => _AddHealthRecordPageState();
}

class _AddHealthRecordPageState extends State<AddHealthRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _conditionController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSaving = false;

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final currentVet = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('health_records').add({
      'petName': _petNameController.text.trim(),
      'species': _speciesController.text.trim(),
      'condition': _conditionController.text.trim(),
      'notes': _notesController.text.trim(),
      'vetEmail': currentVet?.email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _isSaving = false);
    Navigator.pop(context); // ✅ back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VetAppBar(title: "Add Health Record"),
      drawer: const VetDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _petNameController,
                decoration: const InputDecoration(labelText: "Pet Name"),
                validator: (val) => val!.isEmpty ? "Enter pet name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(labelText: "Species (Dog, Cat, etc.)"),
                validator: (val) => val!.isEmpty ? "Enter species" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(labelText: "Condition"),
                validator: (val) => val!.isEmpty ? "Enter condition" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Additional Notes"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: VetTheme.primaryButtonStyle,
                      onPressed: _saveRecord,
                      child: const Text("Save Record"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
