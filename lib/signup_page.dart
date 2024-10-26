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
  bool _isLoading = false;
  bool _isSuccessful = false;

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });
  }

  void signUpAction() async {
    setState(() {
      _isLoading = true;
      _isSuccessful = false;
    });

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null && _image != null) {
        File imageFile = File(_image!.path);
        String fileName = '${user.uid}/profile_picture.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

        await storageRef.putFile(imageFile);
        String downloadURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Writer')
            .doc(user.uid)
            .set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'profilePicture': downloadURL,
        });

        // Set state to show the success state
        setState(() {
          _isLoading = false;
          _isSuccessful = true;
        });

        // Delay for 1 second to show the checkmark, then navigate
        await Future.delayed(Duration(seconds: 1));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog("Please select a profile image.");
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccessful = false;
      });

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

      _showErrorDialog(errorMessage);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccessful = false;
      });

      _showErrorDialog("An error occurred. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sign Up Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
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
                    _buildTextField(
                      controller: _usernameController,
                      hint: 'Username',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.key,
                      obscureText: _isObscured,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFFA4A4A4),
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: _isLoading ? null : signUpAction,
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
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                    key: ValueKey("loading"),
                                  )
                                : _isSuccessful
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 28,
                                        key: ValueKey("check"),
                                      )
                                    : Text(
                                        'Sign Up',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                        key: ValueKey("signUpText"),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA4A4A4),
          ),
          prefixIcon: Icon(icon, color: Color(0xFFA4A4A4)),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
