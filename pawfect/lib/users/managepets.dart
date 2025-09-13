import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class Managepets extends StatefulWidget {
  const Managepets({super.key});

  @override
  State<Managepets> createState() => _ManagepetsState();
}

class _ManagepetsState extends State<Managepets> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ---------- CONFIG ----------
  // Max allowed raw image bytes (adjust if needed). Keep modest to stay well under Firestore doc limits.
  static const int _maxRawImageBytes = 400 * 1024; // 400 KB
  // ----------------------------

  // ✅ Pick image and return base64 (null = cancelled or rejected)
  Future<String?> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    try {
      final bytes = await picked.readAsBytes();

      // check size
      if (bytes.length > _maxRawImageBytes) {
        final kb = (bytes.length / 1024).toStringAsFixed(0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Selected image is too large (${kb} KB). Please pick an image under ${(_maxRawImageBytes / 1024).round()} KB, or compress it."),
          ),
        );
        return null;
      }

      final base64Image = base64Encode(bytes);
      return base64Image;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to read image: ${e.toString()}")),
      );
      return null;
    }
  }

  // ---------- Add or Edit Pet Dialog ----------
  Future<void> _showPetDialog({DocumentSnapshot? petDoc}) async {
    final nameCtrl = TextEditingController(text: petDoc?["name"] ?? "");
    final ageCtrl = TextEditingController(text: petDoc?["age"] ?? "");
    final breedCtrl = TextEditingController(text: petDoc?["breed"] ?? "");
    final speciesCtrl = TextEditingController(text: petDoc?["species"] ?? "");
    String gender = petDoc?["gender"] ?? "Male";
    String? petPicBase64 = petDoc?["photo"];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(builder: (context, setState) {
          Future<void> _save() async {
            final uid = _auth.currentUser?.uid;
            if (uid == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User not logged in")),
              );
              return;
            }

            // prepare data
            final data = {
              "uid": uid,
              "name": nameCtrl.text.trim(),
              "age": ageCtrl.text.trim(),
              "breed": breedCtrl.text.trim(),
              "species": speciesCtrl.text.trim(),
              "gender": gender,
              "photo": petPicBase64,
              "createdAt": FieldValue.serverTimestamp(),
            };

            setState(() => isSaving = true);
            try {
              if (petDoc == null) {
                await _firestore
                    .collection("Users")
                    .doc(uid)
                    .collection("Pets")
                    .add(data);
              } else {
                await petDoc.reference.update(data);
              }

              // success -> close dialog and show confirmation
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(petDoc == null
                      ? "Pet added successfully ✅"
                      : "Pet updated successfully ✅"),
                ),
              );
            } catch (e) {
              // surface the error
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text("Failed to save pet: ${e.toString()}")),
              );
            } finally {
              if (mounted) setState(() => isSaving = false);
            }
          }

          return AlertDialog(
            title: Text(petDoc == null ? "Add New Pet" : "Edit Pet"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar with overlay + icon
                  GestureDetector(
                    onTap: () async {
                      final img = await _pickImage(context);
                      if (img != null) setState(() => petPicBase64 = img);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: petPicBase64 != null
                              ? MemoryImage(base64Decode(petPicBase64!))
                              : null,
                          child: petPicBase64 == null
                              ? const Icon(Icons.pets, size: 40, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF2F80ED),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.add, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fields
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ageCtrl,
                    decoration: const InputDecoration(labelText: "Age"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: breedCtrl,
                    decoration: const InputDecoration(labelText: "Breed"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: speciesCtrl,
                    decoration: const InputDecoration(labelText: "Species"),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => gender = val);
                    },
                    decoration: const InputDecoration(labelText: "Gender"),
                  ),
                  const SizedBox(height: 8),
                  // helpful hint about image limit
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Image limit: ${(_maxRawImageBytes / 1024).round()} KB (recommended)",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F80ED),
                  foregroundColor: Colors.white,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Save"),
              ),
            ],
          );
        });
      },
    );
  }

  // ---------- Delete pet ----------
  Future<void> _deletePet(DocumentSnapshot petDoc) async {
    try {
      await petDoc.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pet deleted ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: ${e.toString()}")),
      );
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pets"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: uid == null
          ? const Center(child: Text("Please log in"))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("Users")
                  .doc(uid)
                  .collection("Pets")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final pets = snapshot.data?.docs ?? [];

                if (pets.isEmpty) {
                  return const Center(child: Text("No pets added yet 🐾"));
                }

                return ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final petDoc = pets[index];
                    final pet = petDoc.data() as Map<String, dynamic>;
                    final petPic = pet["photo"] as String?;
                    ImageProvider? avatar;
                    if (petPic != null && petPic.isNotEmpty) {
                      try {
                        avatar = MemoryImage(base64Decode(petPic));
                      } catch (_) {
                        avatar = null;
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: avatar,
                          child: avatar == null ? const Icon(Icons.pets, color: Colors.grey) : null,
                        ),
                        title: Text(pet["name"] ?? "Unnamed"),
                        subtitle: Text(
                          "${pet["breed"] ?? ""} • ${pet["species"] ?? ""} • ${pet["age"] ?? ""} yrs",
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == "edit") {
                              _showPetDialog(petDoc: petDoc);
                            } else if (val == "delete") {
                              _deletePet(petDoc);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: "edit", child: Text("Edit")),
                            PopupMenuItem(value: "delete", child: Text("Delete")),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPetDialog(),
        backgroundColor: const Color(0xFF2F80ED),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
