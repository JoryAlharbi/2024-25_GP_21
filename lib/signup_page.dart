import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'homepage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isObscured = true;

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });
  }

  void signUpAction() async {
    try {
      // Attempt to create a user with email and password
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null && _image != null) {
        // Upload the profile image to Firebase Storage
        File imageFile = File(_image!.path);
        String fileName = '${user.uid}/profile_picture.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

        await storageRef.putFile(imageFile);
        String downloadURL = await storageRef.getDownloadURL();

        // Save user information in Firestore
        FirebaseFirestore.instance.collection('Writer').doc(user.uid).set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'profilePicture': downloadURL,
        });

        // Show success message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              "Sign Up Successful",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Your account has been created successfully.",
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text(
                  "OK",
                  style: GoogleFonts.poppins(
                    color: Color(0xFFD35400),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage =
            "The password provided is too weak. Please use a stronger password.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "An account already exists with this email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid.";
      } else {
        errorMessage = "Failed to sign up. Please try again.";
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Sign Up Failed",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            errorMessage,
            style: GoogleFonts.poppins(
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                  color: Color(0xFFD35400),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Sign Up Failed",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "An error occurred. Please try again.",
            style: GoogleFonts.poppins(
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                  color: Color(0xFFD35400),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      body: Stack(
        children: [
          Positioned(
            top: 108,
            left: -2,
            child: Container(
              width: 447,
              height: 803,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA2DED0).withOpacity(0.1),
                    const Color(0xFF1B2835).withOpacity(0.15),
                    const Color(0xFFD35400).withOpacity(0.2),
                    const Color(0xFF1B2835).withOpacity(0.1),
                  ],
                  radius: 1.5,
                  center: Alignment.centerRight,
                  stops: const [0.0, 0.2, 0.85, 1],
                ),
                borderRadius: BorderRadius.circular(59),
              ),
            ),
          ),
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
                    GestureDetector(
                      onTap: signUpAction,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFB6B6B6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Log in',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFD35400),
                            ),
                          ),
                        ),
                      ],
                    ),
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
