import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//app packages to navigate
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/profile_page.dart';
import 'package:rawae_gp24/threads.dart';
import 'login_page.dart';
import 'signup_page.dart';

//firebase packages
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase
      .initializeApp(); // makes all Firebase services available globally, including the Realtime Database.
  await FirebaseAppCheck.instance.activate(); // Initialize Firebase App Check

  FirebaseAuth.instance
      .setLanguageCode('en'); // Set the language for Firebase Auth
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/threads': (context) => StoryView(),
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      body: Stack(
        children: [
          // Ellipse 1 (Top-left)
          Positioned(
            top: -230,
            left: -320,
            child: Container(
              width: 800, // Width matching the Figma design
              height: 800, // Height matching the Figma design
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD35400)
                        .withOpacity(0.26), // Orange with adjusted opacity
                    const Color(0xFFA2DED0)
                        .withOpacity(0.0), // Transparent mint
                  ],
                  stops: const [0.0, 1.0], // Smooth transition
                  radius: 0.3, // Control the spread
                ),
              ),
            ),
          ),

          // Ellipse 2 (Center-right)
          Positioned(
            top: 61,
            right: -340,
            child: Container(
              width: 800, // Width matching the Figma design
              height: 800, // Height matching the Figma design
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF344C64)
                        .withOpacity(0.58), // Dark blue with adjusted opacity
                    const Color(0xFFD35400)
                        .withOpacity(0.0), // Transparent orange
                  ],
                  stops: const [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),

          // Ellipse 3 (Bottom-center)
          Positioned(
            bottom: -240,
            left: 100,
            child: Container(
              width: 700, // Width matching the Figma design
              height: 807, // Height matching the Figma design
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA2DED0)
                        .withOpacity(0.2), // Light mint with adjusted opacity
                    const Color(0xFFD35400)
                        .withOpacity(0.0), // Transparent orange
                  ],
                  stops: const [0.0, 1],
                  radius: 0.3,
                ),
              ),
            ),
          ),

          // Main content positioned in the lower half
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 0.8, // Adjust width as needed
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome To',
                      style: GoogleFonts.poppins(
                        fontSize: 37,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rawae',
                      style: GoogleFonts.poppins(
                        fontSize: 37,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 27),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Container(
                        width: 318,
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
                            'Start',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
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
        ],
      ),
    );
  }
}
