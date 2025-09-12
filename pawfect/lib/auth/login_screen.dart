
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfect/admin/home.dart';
import 'package:pawfect/admin/mangeusers.dart';
import 'package:pawfect/shelter/home.dart';
import 'package:pawfect/users/pet_owner_home_screen.dart';
import 'package:pawfect/vetinarian/home.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool showSuccessMessage;
  const LoginScreen({super.key, this.showSuccessMessage = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  // ✅ Fixed brand colors
  final Color _blue = const Color(0xFF1E3062);
  final Color _green = const Color(0xFF00B14F);

  @override
  void initState() {
    super.initState();
    if (widget.showSuccessMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered Successfully")),
        );
      });
    }
  }

  Future<void> _loginUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCredential.user?.uid;
      if (uid == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User record not found")));
        return;
      }

      final role = userDoc["Role"];

      if (role == "Admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (role == "Pet Owner") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PetOwnerHomeScreen()),
        );
      } else if (role == "Veterinarian") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VeterinarianHomeScreen()),
        );
      } else if (role == "Shelter") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ShelterDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email to reset password"),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Failed to send reset email")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            const SizedBox(height: 80),
            Center(
              child: Image.asset(
                "assets/logo.png", // ✅ make sure file + pubspec.yaml match
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Login",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildTextField("Email", _emailController),
            const SizedBox(height: 20),
            _buildTextField("Password", _passwordController, obscure: true),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resetPassword,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: _blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _loading
                ? Center(child: CircularProgressIndicator(color: _green))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: _green, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _loginUser,
                    child: const Text("Login", style: TextStyle(fontSize: 18)),
                  ),
            const SizedBox(height: 30),
            Text(
              "By Logging in, you agree to our Terms & Privacy Policy",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey, // ✅ safe fixed color
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: _green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: _blue),
      decoration: InputDecoration(
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
      ),
    );
  }
}
