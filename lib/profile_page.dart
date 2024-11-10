import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawae_gp24/bookmark.dart';
import 'package:rawae_gp24/edit_profile_page.dart';
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/library.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawae_gp24/custom_navigation_bar.dart'; // Import your CustomNavigationBar

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isPublishedSelected = true;

  final List<Map<String, String>> publishedBooks = [
    {'imageUrl': 'assets/book.png', 'title': 'Memories of the Sea'},
    {'imageUrl': 'assets/book.png', 'title': 'Think Outside the Box'},
  ];

  final List<Map<String, String>> inProgressBooks = [
    {'imageUrl': 'assets/book2.png', 'title': 'The Three Month Rule'},
    {'imageUrl': 'assets/book2.png', 'title': 'New Adventures'},
  ];

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      body: Stack(
        children: [
          SizedBox(
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
                      const Color(0xFFD35400).withOpacity(0.8),
                      const Color(0xFF344C64).withOpacity(0.8),
                      const Color(0xFFA2DED0).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 120),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[700],
                      child: const Icon(Icons.person,
                          size: 60, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Handle change profile picture action
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  user?.displayName ?? 'razan',
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.email ?? 'No email available',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: const Color(0xFFA4A4A4)),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD35400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                  ),
                  child: Text(
                    'Edit Profile',
                    style:
                        GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
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
                                        margin: const EdgeInsets.only(top: 4),
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
                                        margin: const EdgeInsets.only(top: 4),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Center(
                              child: GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.7,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MakeThreadPage()),
          );
        },
        backgroundColor: const Color(0xFFD35400),
        elevation: 6,
        child: const Icon(Icons.add, size: 36, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavigationBar(selectedIndex: 3),
    );
  }
}

// BookCard widget for the grid list
class BookCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  const BookCard({super.key, required this.imageUrl, required this.title});

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
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
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
        size.width * 0.5, size.height * 1.2, size.width, size.height * 0.6);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
