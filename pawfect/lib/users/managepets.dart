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

  // ✅ Pick image and return base64
  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return base64Encode(bytes);
  }

  // ✅ Add or Edit Pet Dialog
  Future<void> _showPetDialog({DocumentSnapshot? petDoc}) async {
    final nameCtrl = TextEditingController(text: petDoc?["name"]);
    final ageCtrl = TextEditingController(text: petDoc?["age"]);
    final breedCtrl = TextEditingController(text: petDoc?["breed"]);
    final speciesCtrl = TextEditingController(text: petDoc?["species"]);
    String gender = petDoc?["gender"] ?? "Male";
    String? petPicBase64 = petDoc?["photo"];
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(petDoc == null ? "Add New Pet" : "Edit Pet"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final img = await _pickImage();
                    if (img != null) {
                      setState(() => petPicBase64 = img);
                    }
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
                  onChanged: (val) => setState(() => gender = val!),
                  decoration: const InputDecoration(labelText: "Gender"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F80ED),
                foregroundColor: Colors.white,
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      final uid = _auth.currentUser?.uid;

                      if (uid == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User not logged in ❌")),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

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

                        Navigator.pop(context); // ✅ close after success
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error saving pet: $e")),
                        );
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Delete pet
  Future<void> _deletePet(DocumentSnapshot petDoc) async {
    await petDoc.reference.delete();
  }

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
                    final pet = pets[index].data() as Map<String, dynamic>;
                    final petPic = pet["photo"];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: petPic != null
                              ? MemoryImage(base64Decode(petPic))
                              : null,
                          child: petPic == null
                              ? const Icon(Icons.pets, color: Colors.grey)
                              : null,
                        ),
                        title: Text(pet["name"] ?? "Unnamed"),
                        subtitle: Text(
                            "${pet["breed"] ?? ""} • ${pet["species"] ?? ""} • ${pet["age"] ?? ""} yrs"),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == "edit") {
                              _showPetDialog(petDoc: pets[index]);
                            } else if (val == "delete") {
                              _deletePet(pets[index]);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: "edit", child: Text("Edit")),
                            const PopupMenuItem(value: "delete", child: Text("Delete")),
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
