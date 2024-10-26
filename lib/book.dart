import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/library.dart';
import 'package:rawae_gp24/bookmark.dart';
import 'package:rawae_gp24/profile_page.dart';
import 'package:rawae_gp24/read_book.dart';

class BookDetailsPage extends StatelessWidget {
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
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Book Cover Image
            Image.asset(
              'assets/book.png',
              height: 200,
            ),
            SizedBox(height: 20),
            // Book Title
            Text(
              'MEMORIES OF THE SEA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // Genres
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GenreChip(label: 'Fiction'),
                SizedBox(width: 10),
                GenreChip(label: 'Fantasy'),
              ],
            ),
            SizedBox(height: 10),
            // Authors
            Text(
              'Authors: Konrin, Reem, Sara, ...more',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(height: 20),
            // Description
            Text(
              'In a world where dreams bleed into reality, searching for a key to unlock a future that never existed. Time stumbles, shadows whisper, and the sky remembers what we’ve forgotten.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(height: 20),
            // Start Reading Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReadBookPage()),
                );
              },
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
                    'Start Reading',
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(0xFFD35400),
              width: 0,
            ),
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MakeThreadPage()),
              );
            },
            backgroundColor: Color(0xFFD35400),
            child: Icon(
              Icons.add,
              size: 36,
              color: Colors.white,
            ),
            elevation: 6,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: ClipPath(
          clipper: CustomBottomBarClipper(),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Color(0xFF1E2834),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.home),
                  color: Color(0xFF9DB2CE),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.library_books),
                  color: Color(0xFF9DB2CE),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LibraryPage()),
                    );
                  },
                ),
                SizedBox(width: 40), // Space for the FAB
                IconButton(
                  icon: Icon(Icons.bookmark),
                  color: Color(0xFF9DB2CE),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => BookmarkPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person),
                  color: Color(0xFFA2DED0),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GenreChip extends StatelessWidget {
  final String label;

  const GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

// Custom Clipper for the curved background shape
class CustomBottomBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;
    Path path = Path();

    path.lineTo(width * 0.25, 0);
    path.quadraticBezierTo(
      width * 0.5,
      height * 0.6,
      width * 0.75,
      0,
    );
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
