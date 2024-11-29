import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'character_edit.dart'; // Adjust the path to your character_edit.dart file
import 'threads.dart'; // Adjust the path to your threads.dart file
import 'package:cached_network_image/cached_network_image.dart';

class CharacterPreviewPage extends StatefulWidget {
  final String charName;
  final String threadId;
  final String storyText;
  final String userId;
  final String publicUrl;
  final String description;  // Changed from List<String> to String
  final String partId;

  const CharacterPreviewPage({
    super.key,
    required this.charName,
    required this.threadId,
    required this.storyText,
    required this.userId,
    required this.publicUrl,
    required this.description,  // Accepts String
    required this.partId,
  });

  static CharacterPreviewPage fromArguments(Map<String, dynamic> args) {
    return CharacterPreviewPage(
      charName: args['charName'] ?? '',
      threadId: args['threadId'] ?? '',
      storyText: args['storyText'] ?? '',
      userId: args['userId'] ?? '',
      publicUrl: args['publicUrl'] ?? '',
      description: args['description'] ?? '',  // Ensure it's a String
      partId: args['partId'] ?? '',
      

    );
  }

  @override
  _CharacterPreviewPageState createState() => _CharacterPreviewPageState();
}

class _CharacterPreviewPageState extends State<CharacterPreviewPage> {
  String? updatedPublicUrl;
  String? updatedDescription;  // Changed to String

  @override
  void initState() {
    super.initState();
    updatedPublicUrl = widget.publicUrl;
    updatedDescription = widget.description;  // Directly assign String description
    print('Updated Public URL: $updatedPublicUrl');
    print('Updated Description: $updatedDescription');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 112, 28, 28),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                  widget.charName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                // Circular profile image placeholder
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2A3B4D),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      updatedPublicUrl ?? widget.publicUrl, // Use the updated URL
                      key: ValueKey(updatedPublicUrl), // Add key to force reload
                      fit: BoxFit.cover, 
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // Image loaded
                        } else {
                          return Center(child: CircularProgressIndicator()); // Show loading indicator
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, color: Colors.red); // Show error icon
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Show description as a text
                Text(
                  updatedDescription ?? widget.description, // Use the updated description
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 211, 211, 211),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
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
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCharacterPage(
                          userName: widget.charName,
                          description: widget.description,  // Pass description as a String
                          threadId: widget.threadId,
                          partId: widget.partId,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        updatedPublicUrl = result['publicUrl'];
                        updatedDescription = result['description'];  // Update with the new description
                        print("Updated Public URL: $updatedPublicUrl");
                        print("Updated Description: $updatedDescription");
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3B4D),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
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
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryView(
                          threadId: widget.threadId,
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD35400),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
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
