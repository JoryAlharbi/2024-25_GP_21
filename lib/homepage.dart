import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rawae_gp24/signup_page.dart'; // Adjust the path if necessary

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Log out the user
              await FirebaseAuth.instance.signOut();
              // Navigate back to the sign-in page (assuming it's called SignInPage)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SignUpPage()), // Replace with your SignInPage widget
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to the Home Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
