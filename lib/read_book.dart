import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadBookPage extends StatelessWidget {
  final String bookTitle;

  ReadBookPage({this.bookTitle = 'MEMORIES OF THE SEA'});

  final String bookContent = '''
    In a world where dreams bleed into reality, Evelyn embarked on a journey across the seas. The whispers of the ocean were her only companions, guiding her toward a future that held more mysteries than she could fathom.
    
    Each wave that crashed against the bow of her small boat seemed to carry a fragment of her past, reminding her of the life she once knew. Yet, she pressed on, knowing that the key to her destiny lay beyond the horizon.
    
    The sky painted itself with shades of twilight as Evelyn ventured deeper into the unknown. Stars began to twinkle, reflecting on the calm waters, weaving a path of light that she felt destined to follow.
    
    She clutched a worn map in her hands, its edges frayed and faded, but the promise of adventure shimmered in her eyes. For Evelyn, the sea was not just a vast expanse of water, but a living tapestry of secrets, waiting to be discovered.
    
    As the night grew darker, the line between reality and dreams blurred, and Evelyn found herself questioning what was real. But she knew one thing for certain—she would find what she sought, no matter how far the sea carried her.
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: Color(0xFF1B2835),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          bookTitle,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookContent,
                style: GoogleFonts.poppins(
                  color: Colors.grey[300],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
