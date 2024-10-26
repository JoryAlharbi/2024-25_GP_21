import 'package:flutter/material.dart';
import 'package:rawae_gp24/bookmark.dart';
import 'package:rawae_gp24/genre_library.dart';
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:rawae_gp24/profile_page.dart';
import 'package:rawae_gp24/search.dart';

class LibraryPage extends StatelessWidget {
  final List<Map<String, dynamic>> genres = [
    {'name': 'Fantasy', 'image': 'assets/fantasy.png'},
    {'name': 'Drama', 'image': 'assets/drama.png'},
    {'name': 'Romance', 'image': 'assets/romance.png'},
    {'name': 'Comedy', 'image': 'assets/comedy.png'},
    {'name': 'Crime Fiction', 'image': 'assets/crime_fiction.png'},
    {'name': 'Adventure', 'image': 'assets/adventure.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            color: Color(0xFF1B2835),
          ),
          // Ellipses for decoration
          Positioned(
            top: -130,
            left: -174,
            child: Container(
              width: 397,
              height: 397,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFD35400).withOpacity(0.26),
                    Color(0xFFA2DED0).withOpacity(0.0),
                  ],
                  stops: [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),
          Positioned(
            top: 61,
            right: -160,
            child: Container(
              width: 397,
              height: 397,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF344C64).withOpacity(0.58),
                    Color(0xFFD35400).withOpacity(0.0),
                  ],
                  stops: [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            left: 100,
            child: Container(
              width: 397,
              height: 397,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFA2DED0).withOpacity(0.2),
                    Color(0xFFD35400).withOpacity(0.0),
                  ],
                  stops: [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),

          // Custom header with "Explore" and search icon
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explore',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: const Color(0xFF9DB2CE)),
                  iconSize: 30,
                  onPressed: () {
                    // Add search functionality or navigation here if needed
                  },
                ),
              ],
            ),
          ),
          // Main content: Genres grid
          Padding(
            padding: const EdgeInsets.only(top: 120.0, left: 16.0, right: 16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenreLibraryPage(
                          genre: genre['name'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          genre['image'],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        genre['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
