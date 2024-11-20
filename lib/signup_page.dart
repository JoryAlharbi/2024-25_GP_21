import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;
  bool _isSuccessful = false;
  String _passwordStrength = "";
  File? _profileImage;

  // Function to pick an image
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Password strength checker function
  String checkPasswordStrength(String password) {
    if (password.length < 6) {
      return "Weak";
    } else if (password.length < 10) {
      return "Moderate";
    } else {
      return "Strong";
    }
  }

  // Sign up action
  void signUpAction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Passwords Do Not Match"),
          content: Text("Please make sure both passwords are the same."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      // Upload profile image if selected
      String? profileImageUrl;
      if (_profileImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user!.uid}.jpg');
        await ref.putFile(_profileImage!);
        profileImageUrl = await ref.getDownloadURL();
      }

      /// to add in the writer collection ther writer info
      if (user != null) {
        await user
            .sendEmailVerification(); //send a validation email to the email

        FirebaseFirestore.instance.collection('Writer').doc(user.uid).set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'profileImageUrl': profileImageUrl ?? '',
        });

        setState(() {
          _isSuccessful = true;
        });

        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code == 'weak-password'
          ? "The password provided is too weak. Please use a stronger password."
          : e.code == 'email-already-in-use'
              ? "An account already exists with this email."
              : e.code == 'invalid-email'
                  ? "The email address is not valid."
                  : "Failed to sign up. Please try again.";

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Sign Up Failed"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

////////////////////////
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
                child: Form(
                  key: _formKey,
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
                      GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? Icon(Icons.add_a_photo,
                                  color: Colors.white, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 25),
                      TextFormField(
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
                        validator: (value) => value != null && value.length >= 3
                            ? null
                            : 'Username must be at least 3 characters',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
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
                        validator: (value) => value != null &&
                                RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
                                    .hasMatch(value)
                            ? null
                            : 'Enter a valid email address',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        onChanged: (value) {
                          setState(() {
                            _passwordStrength = checkPasswordStrength(value);
                          });
                        },
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
                        validator: (value) => value != null && value.length >= 6
                            ? null
                            : 'Password must be at least 6 characters',
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Password Strength: $_passwordStrength',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _passwordStrength == "Strong"
                              ? Colors.green
                              : _passwordStrength == "Moderate"
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _isObscured,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
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
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null; // Valid
                        },
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: signUpAction,
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF344C64),
                                Color(0xFFD35400),
                                Color(0xFFA2DED0),
                              ],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: _isLoading
                                ? CircularProgressIndicator() // Show loading indicator while signing up
                                : Text(
                                    'Create Account',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
