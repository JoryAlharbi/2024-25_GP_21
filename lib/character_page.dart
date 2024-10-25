import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'character_edit.dart'; // Adjust the path to your character_edit.dart file
import 'threads.dart'; // Adjust the path to your threads.dart file

class CharacterPreviewPage extends StatelessWidget {
  final String userName;

  CharacterPreviewPage({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 112, 28, 28),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Say Hi to,',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$userName!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                // Circular profile image placeholder
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2A3B4D),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_circle_rounded,
                      size: 140,
                      color: Color(0xFF9DB2CE),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Positioned buttons in the bottom right half of the screen
          Positioned(
            bottom: 40,
            right: 20,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the edit character page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCharacterPage(
                          userName: 'Hailey',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A3B4D),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Replace the current page with the thread page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StoryView(), // Replace with your threads page class
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD35400),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
