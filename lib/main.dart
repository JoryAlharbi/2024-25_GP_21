import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// App packages to navigate
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/profile_page.dart';
import 'package:rawae_gp24/threads.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'character_page.dart';
// Firebase packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance.setLanguageCode('en');
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/character_page':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CharacterPreviewPage.fromArguments(args),
            );
          case '/threads':
            final args = settings.arguments as Map<String, String>;
            final threadId = args['threadId']!;
            final userId = args['userId']!;
            return MaterialPageRoute(
              builder: (context) =>
                  StoryView(threadId: threadId, userId: userId),
            );
          default:
            return MaterialPageRoute(builder: (context) => HomePage());
        }
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        _storeDeviceToken(token);
      }
    }).catchError((error) {
      // Handle token retrieval failure
      print("Error retrieving token: $error");
    });
  }

  Future<void> _storeDeviceToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Writer')
          .doc(user.uid)
          .update({'deviceToken': token});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      body: Stack(
        children: [
          // Gradient decorations
          Positioned(
            top: -230,
            left: -320,
            child: Container(
              width: 800,
              height: 800,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD35400).withOpacity(0.26),
                    const Color(0xFFA2DED0).withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),
          Positioned(
            top: 61,
            right: -340,
            child: Container(
              width: 800,
              height: 800,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF344C64).withOpacity(0.58),
                    const Color(0xFFD35400).withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -240,
            left: 100,
            child: Container(
              width: 700,
              height: 807,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA2DED0).withOpacity(0.2),
                    const Color(0xFFD35400).withOpacity(0.0),
                  ],
                  stops: const [0.0, 1],
                  radius: 0.3,
                ),
              ),
            ),
          ),
          // Welcome content
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 0.8,
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
