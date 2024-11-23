import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'character_edit.dart'; // Adjust the path to your character_edit.dart file
import 'threads.dart'; // Adjust the path to your threads.dart file
import 'package:cached_network_image/cached_network_image.dart';

class CharacterPreviewPage extends StatelessWidget {
  final String userName;
  final String threadId;
  final String storyText;
  final String userId; // Add userId as a required field
  final String publicUrl;
final List<String> characterTags;

  const CharacterPreviewPage({
    super.key,
    required this.userName,
    required this.threadId,
    required this.storyText,
    required this.userId,
    required this.publicUrl,
    required this.characterTags,
    
  });
static CharacterPreviewPage fromArguments(Map<String, dynamic> args) {
    return CharacterPreviewPage(
      userName: args['userName'] ?? '',
      threadId: args['threadId'] ?? '',
      storyText: args['storyText'] ?? '',
      userId: args['userId'] ?? '',
      publicUrl: args['publicUrl'] ?? '',
characterTags: List<String>.from(args['characterTags'] ?? []),     );

  }
  @override
  Widget build(BuildContext context) {
        print("CharacterPreviewPage URL: $publicUrl  hi ");
        print("CharacterPreviewPage URL: $threadId  hi ");
        print("CharacterPreviewPage URL: $userId  hi ");
        print("CharacterPreviewPage URL: $userName  hi ");
print("CharacterPreviewPage URL: $characterTags  hi ");
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
                  '$userName!',
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
      publicUrl, // The URL of the image
      fit: BoxFit.cover, // Ensure the image fits inside the circle
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
)


,
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
                          userName: userName, // Pass the userName
                         characterTags:characterTags,
                        ),
                      ),
                    );
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
                    // Replace the current page with the thread page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryView(
                          threadId: threadId,
                          userId: userId, // Pass the required userId
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
