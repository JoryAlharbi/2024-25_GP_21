import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rawae_gp24/signup_page.dart'; // Adjust the path if necessary

import 'package:google_fonts/google_fonts.dart';
import 'package:rawae_gp24/bookmark.dart';
import 'package:rawae_gp24/library.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:rawae_gp24/profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 112, 28, 28),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: Color(0xFF9DB2CE)),
            iconSize: 31,
            onPressed: () {
              // Handle search functionality
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scrollable genres
          SizedBox(height: 10),
          Container(
            height: 34.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GenreButton('Thriller'),
                GenreButton('Fantasy'),
                GenreButton('Fiction'),
                GenreButton('Romance'),
                GenreButton('Mystery'),
                // Add more genres as needed
              ],
            ),
          ),
          SizedBox(height: 10),
          Divider(color: const Color.fromARGB(150, 143, 143, 143)),
          SizedBox(height: 20),
          // Books list
          Expanded(
            child: ListView.builder(
              itemCount: 3, // number of books
              itemBuilder: (context, index) {
                return BookListItem(
                  title: 'Book Title $index',
                  genre: 'Genre $index',
                  isPopular: index == 0,
                  userIcons: 3,
                );
              },
            ),
          ),
        ],
      ),
      // Here is the navigation bar and floating action button.
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
                  icon: Icon(Icons.home_rounded),
                  color: Color(0xFFA2DED0),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.library_books_rounded),
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
                  color: Color(0xFF9DB2CE),
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

class GenreButton extends StatelessWidget {
  final String genre;
  GenreButton(this.genre);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(61, 71, 83, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: () {
          // Handle genre filter
        },
        child: Text(
          genre,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }
}

class BookListItem extends StatelessWidget {
  final String title;
  final String genre;
  final bool isPopular;
  final int userIcons;

  BookListItem({
    required this.title,
    required this.genre,
    required this.isPopular,
    required this.userIcons,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to ThreadsPage when any part of the book item is tapped
        Navigator.pushNamed(context, '/threads'); // Replace with actual route
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Larger book cover image
            Container(
              width: 80.0, // Adjust width for larger cover
              height: 120.0, // Adjust height for proportionate cover
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                image: DecorationImage(
                  image: AssetImage('assets/book.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16.0), // Space between image and text
            // Book title and subtitle
            Expanded(
              child: Container(
                height:
                    120.0, // Match height of the image to constrain the column
                child: Stack(
                  children: [
                    // Align the title and subtitle at the top
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isPopular)
                              Icon(
                                Icons.local_fire_department,
                                color: Color(0xFFD35400),
                                size: 18.0,
                              ),
                          ],
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          genre,
                          style: GoogleFonts.poppins(
                            color: Color(0xFF9DB2CE),
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    // Align user icons at the bottom-right
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Row(
                        children: List.generate(
                          userIcons,
                          (index) => Transform.translate(
                            offset: Offset(-10.0 * index, 0),
                            child: Icon(
                              Icons.account_circle_rounded,
                              color: const Color.fromARGB(255, 110, 125, 147),
                              size: 35.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
