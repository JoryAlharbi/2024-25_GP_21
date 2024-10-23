import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for saving user data
import 'package:image_picker/image_picker.dart'; // Image picker for profile picture
import 'dart:io'; // To handle image files

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  XFile? _image; // Selected image
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isObscured = true;

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });
  }

  // Function to handle user sign-up and upload image
  void signUpAction() async {
    try {
      // Sign up with Firebase Auth
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null && _image != null) {
        // Upload image to Firebase Storage
        File imageFile = File(_image!.path);
        String fileName = '${user.uid}/profile_picture.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

        await storageRef.putFile(imageFile);
        String downloadURL = await storageRef.getDownloadURL();

        // Save user info to Firestore
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'profilePicture': downloadURL,
        });

        // Navigate to another screen or show success message
        print('User signed up and image uploaded!');
      }
    } catch (e) {
      print('Error during sign-up: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835), // Dark background color
      body: Stack(
        children: [
          // Radial gradient background layer
          Positioned(
            top: 108, // Adjust Y position as needed
            left: -2, // Adjust X position as needed
            child: Container(
              width: 447,
              height: 803,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA2DED0).withOpacity(0.2), // Light mint
                    const Color(0xFFD35400).withOpacity(0.2), // Orange
                    const Color(0xFFA2DED0).withOpacity(0.2), // Light mint
                  ],
                  radius: 1.5,
                  center: Alignment.topCenter,
                  stops: const [0.0, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(59),
              ),
            ),
          ),
          // Main content positioned in the center
          Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Create. Collaborate. Inspire',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA4A4A4),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Profile picture picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _image != null
                            ? FileImage(File(_image!.path))
                            : null,
                        child: _image == null
                            ? const Icon(Icons.camera_alt,
                                color: Colors.white, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Username Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _usernameController,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFA4A4A4),
                          ),
                          prefixIcon: const Icon(Icons.person,
                              color: Color(0xFFA4A4A4)),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _emailController,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFA4A4A4),
                          ),
                          prefixIcon:
                              const Icon(Icons.email, color: Color(0xFFA4A4A4)),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFA4A4A4),
                          ),
                          prefixIcon:
                              const Icon(Icons.key, color: Color(0xFFA4A4A4)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFFA4A4A4),
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Sign up Button
                    GestureDetector(
                      onTap: signUpAction, // Call sign-up action here
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF344C64),
                              Color(0xFFD35400),
                              Color(0xFFA2DED0),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}