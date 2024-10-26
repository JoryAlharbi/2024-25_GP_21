import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'homepage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscured = true;
  final _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Login Failed"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2835),
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
                    Color(0xFFA2DED0).withOpacity(0.1),
                    Color(0xFF1B2835).withOpacity(0.15),
                    Color(0xFFD35400).withOpacity(0.2),
                    Color(0xFF1B2835).withOpacity(0.1),
                  ],
                  radius: 1.5,
                  center: Alignment.centerRight,
                  stops: [0.0, 0.2, 0.85, 1],
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
                      'Welcome Back!',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Welcome back, we missed you.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFA4A4A4),
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
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
                            color: Color(0xFFA4A4A4),
                          ),
                          prefixIcon:
                              Icon(Icons.person, color: Color(0xFFA4A4A4)),
                          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
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
                            color: Color(0xFFA4A4A4),
                          ),
                          prefixIcon: Icon(Icons.key, color: Color(0xFFA4A4A4)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFFA4A4A4),
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    GestureDetector(
                      onTap: _login,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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
                            'Log in',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFB6B6B6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Sign up',
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
