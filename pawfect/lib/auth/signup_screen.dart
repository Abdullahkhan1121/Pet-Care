

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _contactController = TextEditingController();

  String? _selectedRole;
  bool _loading = false;

  // ✅ Brand colors
  final Color _blue = const Color(0xFF1E3062);
  final Color _green = const Color(0xFF00B14F);

  final List<String> roles = ["Pet Owner", "Veterinarian", "Shelter"];

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCred.user!.uid;

      await FirebaseFirestore.instance.collection("Users").doc(uid).set({
        "User_Id": uid,
        "Name": _nameController.text.trim(),
        "Email": _emailController.text.trim(),
        "Password": _passwordController.text.trim(), // ⚠️ plain text, not safe
        "Phone": _contactController.text.trim(),
        "Role": _selectedRole,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(showSuccessMessage: true),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Something went wrong")),
        );
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Image.asset(
                "assets/logo.jpg", // ✅ match LoginScreen
                height: 100,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Sign Up",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _blue,
              ),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildField("Full Name", _nameController),
                  const SizedBox(height: 15),
                  _buildField(
                    "Email",
                    _emailController,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  _buildField(
                    "Password",
                    _passwordController,
                    obscure: true,
                    validator: (val) => val != null && val.length >= 6
                        ? null
                        : "Min 6 characters",
                  ),
                  const SizedBox(height: 15),
                  _buildField(
                    "Contact Number",
                    _contactController,
                    type: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    value: _selectedRole,
                    style: TextStyle(color: _blue),
                    decoration: _inputDecoration("Select Role"),
                    items: roles.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedRole = val),
                    validator: (val) =>
                        val == null ? "Please select a role" : null,
                  ),
                  const SizedBox(height: 25),
                  _loading
                      ? CircularProgressIndicator(color: _green)
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: _green, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _registerUser,
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LoginScreen(showSuccessMessage: false),
                    ),
                  );
                },
                child: Text(
                  "Already have an account? Login",
                  style: TextStyle(color: _green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _blue),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _green, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _blue, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      style: TextStyle(color: _blue),
      decoration: _inputDecoration(label),
      validator: validator ?? (val) => val!.isEmpty ? "Required field" : null,
    );
  }
}
