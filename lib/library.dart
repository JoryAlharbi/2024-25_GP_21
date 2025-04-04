import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawae_gp24/bookmark.dart';
import 'package:rawae_gp24/genre_library.dart';
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:rawae_gp24/profile_page.dart';
import 'package:rawae_gp24/search.dart';
import 'package:rawae_gp24/custom_navigation_bar.dart'; // Import CustomNavigationBar
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryPage extends StatelessWidget {
  final List<Map<String, dynamic>> genres = [
    {
      'id': 'EUw4wq33ai6Xxe6jbDUY',
      'name': 'Fantasy',
      'image': 'assets/fantasy.png',
      'color': Color(0xFFFF69B4),
    },
    {
      'id': 'XJDqFYj72YT0hBL25yOb',
      'name': 'Drama',
      'image': 'assets/drama.png',
      'color': Color(0xFFFF69B4),
    },
    {
      'id': 'fkO0jS1GlUQcWb5yeCOq',
      'name': 'Thriller',
      'image': 'assets/Thriller.png',
      'color': Color(0xFFFF69B4),
    },
    {
      'id': 'KyMtx16Rq28JCMrKKzF7',
      'name': 'Romance',
      'image': 'assets/romance.png',
      'color': Color(0xFFFF69B4),
    },
    {
      'id': '2NlCMfmRJAUaLADs8t6Q',
      'name': 'Comedy',
      'image': 'assets/comedy.png',
      'color': Color(0xFFFF69B4),
    },
    {
      'id': 'XJpqFJy72Y7bh0L25y0b',
      'name': 'Crime Fiction',
      'image': 'assets/crime_fiction.png',
      'color': Color(0xFFFF69B4),
    },
    {
      'id': 'awLGlCFxrS60Kvzq2eq6',
      'name': 'Horror',
      'image': 'assets/horror.png',
      'color': Color(0xFFFF69B4),
    },
    {
      'id': 'YRdkEdiEZ9NZeQIMDTi',
      'name': 'Adventure',
      'image': 'assets/adventure.png',
      'color': Color(0xFFFF69B4),
    },
    {
      'id': 'jBZ5tvemmCEpG5NHTyaj',
      'name': 'Mystery',
      'image': 'assets/Mystery.png',
      'color': Color(0xFFFF69B4),
    },
    {
      'id': 'qCmOjByIJWjGeLjUMfb4',
      'name': 'Historical',
      'image': 'assets/Historical.png',
      'color': Color(0xFFFF69B4),
    },
  ];

  LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      body: Stack(
        children: [
          // Ellipse 1 (Top-left)
          Positioned(
            top: -230,
            left: -320,
            child: Container(
              width: 800,
              height: 800,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD35400).withOpacity(0.26),
                    const Color(0xFFA2DED0).withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),
          // Ellipse 2 (Center-right)
          Positioned(
            top: 61,
            right: -340,
            child: Container(
              width: 800,
              height: 800,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF344C64).withOpacity(0.58),
                    const Color(0xFFD35400).withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),
          // Ellipse 3 (Bottom-center)
          Positioned(
            bottom: -240,
            left: 100,
            child: Container(
              width: 700,
              height: 807,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA2DED0).withOpacity(0.2),
                    const Color(0xFFD35400).withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),
          // Main body content
          Column(
            children: [
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Explore',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF9DB2CE)),
                      iconSize: 30,
                      onPressed: () {
                        // Add search functionality if needed
                      },
                    ),
                  ],
                ),
              ),
              // Main content: Genres grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                                genreID: genre['id'],
                                genreName: genre['name'],
                              ),
                            ),
                          );
                        },
                        child: FlippableGenreCard(
                          genreName: genre['name'],
                          genreId: genre['id'],
                          frontImagePath: genre['image'],
                          backgroundColor: genre['color'],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
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
        child: const Icon(
          Icons.add,
          size: 36,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavigationBar(selectedIndex: 1),
    );
  }
}

class FlippableGenreCard extends StatefulWidget {
  final String genreName;
  final String genreId;
  final String frontImagePath;
  final Color backgroundColor;

  const FlippableGenreCard({
    super.key,
    required this.genreName,
    required this.genreId,
    required this.frontImagePath,
    required this.backgroundColor,
  });

  @override
  State<FlippableGenreCard> createState() => _FlippableGenreCardState();
}

class _FlippableGenreCardState extends State<FlippableGenreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFlipped = false;
  String? bookCoverUrl;
  String? bookTitle;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: pi).animate(_controller);

    fetchMostViewedBook();
    maybeFlip();
  }

  Future<void> fetchMostViewedBook() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Thread')
        .where('genreID',
            arrayContains:
                FirebaseFirestore.instance.doc('Genre/${widget.genreId}'))
        .orderBy('totalView', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      setState(() {
        bookCoverUrl = data['bookCoverUrl'];
        bookTitle = data['title'];
      });
    }
  }

  void maybeFlip() {
    Future.delayed(Duration(milliseconds: Random().nextInt(4000)), () {
      if (mounted) {
        _controller.forward();
        setState(() {
          isFlipped = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFront() {
    return Container(
      color: widget.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(widget.frontImagePath, height: 60),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      color: widget.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (bookCoverUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  Image.network(bookCoverUrl!, height: 80, fit: BoxFit.cover),
            ),
          const SizedBox(height: 8),
          Text(
            bookTitle ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isBack = _animation.value > pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(_animation.value),
          child: isBack ? _buildBack() : _buildFront(),
        );
      },
    );
  }
}
