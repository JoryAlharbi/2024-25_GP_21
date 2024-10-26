import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rwe/bookmark.dart';
import 'package:rwe/edit_profile_page.dart';
import 'package:rwe/homepage.dart';
import 'package:rwe/library.dart';
import 'package:rwe/makethread.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isPublishedSelected = true;

  // Sample lists for books
  final List<Map<String, String>> publishedBooks = [
    {
      'imageUrl': 'assets/book.png',
      'title': 'Memories of the Sea',
    },
    {
      'imageUrl': 'assets/book.png',
      'title': 'Think Outside the Box',
    },
  ];

  final List<Map<String, String>> inProgressBooks = [
    {
      'imageUrl': 'assets/book2.png',
      'title': 'The Three Month Rule',
    },
    {
      'imageUrl': 'assets/book2.png',
      'title': 'New Adventures',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2835),
      body: Stack(
        children: [
          // Curved gradient background
          Container(
            height: 110,
            child: CustomPaint(
              painter: CurvePainter(),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD35400).withOpacity(0.8),
                      Color(0xFF344C64).withOpacity(0.8),
                      Color(0xFFA2DED0).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Main content of the profile page
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(height: 120), // Adjust for curved section
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[700],
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Handle change profile picture action
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Ross Ankunding',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Bridie40@yahoo.com',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFFA4A4A4),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD35400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Published and InProgress sections, with the books list inside
                Expanded(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(23, 32, 45, 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isPublishedSelected = true;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'Published',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isPublishedSelected
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                    if (isPublishedSelected)
                                      Container(
                                        height: 3,
                                        width: 60,
                                        color: Colors.white,
                                        margin: EdgeInsets.only(top: 4),
                                      ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isPublishedSelected = false;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'InProgress',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: !isPublishedSelected
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                    if (!isPublishedSelected)
                                      Container(
                                        height: 3,
                                        width: 30,
                                        color: Colors.white,
                                        margin: EdgeInsets.only(top: 4),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Expanded(
                            child: Center(
                              child: GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Number of columns
                                  crossAxisSpacing: 10, // Space between columns
                                  mainAxisSpacing: 10, // Space between rows
                                  childAspectRatio:
                                      0.7, // Adjust to control height
                                ),
                                itemCount: (isPublishedSelected
                                        ? publishedBooks
                                        : inProgressBooks)
                                    .length,
                                itemBuilder: (context, index) {
                                  final book = isPublishedSelected
                                      ? publishedBooks[index]
                                      : inProgressBooks[index];
                                  return BookCard(
                                    imageUrl: book['imageUrl']!,
                                    title: book['title']!,
                                  );
                                },
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
          ),
        ],
      ),
      // Navigation bar and floating action button code
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
                SizedBox(width: 40), // Space for the FloatingActionButton
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

// Custom Clipper for the curved bottom bar shape
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

// BookCard widget for the grid list
class BookCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  BookCard({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              imageUrl,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for the curved background shape
class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    var path = Path();
    path.lineTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.2,
      size.width,
      size.height * 0.6,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
