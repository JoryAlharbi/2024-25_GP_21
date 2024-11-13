import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'threads.dart';
import 'makethread.dart';
import 'custom_navigation_bar.dart';
import 'genre_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  Future<String> _getGenreNames(List<dynamic> genreRefs) async {
    List<String> genreNames = [];
    for (var genreRef in genreRefs) {
      if (genreRef is DocumentReference) {
        final genreSnapshot = await genreRef.get();
        if (genreSnapshot.exists) {
          genreNames.add(genreSnapshot['genreName'] ?? 'Unknown Genre');
        }
      }
    }
    return genreNames.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color(0x00701C1C),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF9DB2CE)),
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
          const SizedBox(height: 10),
          SizedBox(
            height: 34.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GenreButton('Thriller'),
                GenreButton('Fantasy'),
                GenreButton('Fiction'),
                GenreButton('Romance'),
                GenreButton('Mystery'),
                GenreButton('Science Fiction'),
                GenreButton('Comedy'),
                GenreButton('Drama'),
                GenreButton('Adventure'),
                GenreButton('Romance'),
                GenreButton('Horror'),
                GenreButton('Historical'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color.fromARGB(222, 62, 72, 72)),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Thread')
                  .where('status', isEqualTo: 'in_progress')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No threads available.'));
                } else {
                  final threads = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: threads.length,
                    itemBuilder: (context, index) {
                      final threadData =
                          threads[index].data() as Map<String, dynamic>;
                      final List<dynamic> genreRefs =
                          threadData['genreID'] ?? [];
                      final String? bookCoverUrl = threadData['bookCoverUrl'];
                      final String threadId = threads[index].id;

                      return FutureBuilder<String>(
                        future: _getGenreNames(genreRefs),
                        builder: (context, genreSnapshot) {
                          if (!genreSnapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final genreNames = genreSnapshot.data!;
                          return BookListItem(
                            title: threadData['title'] ?? 'Untitled',
                            genre: genreNames,
                            isPopular: index == 0,
                            userIcons: 3,
                            bookCoverUrl: bookCoverUrl,
                            threadId: threadId,
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MakeThreadPage()),
              );
            },
            backgroundColor: const Color(0xFFD35400),
            elevation: 6,
            child: const Icon(
              Icons.add_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavigationBar(selectedIndex: selectedIndex),
    );
  }
}

class BookListItem extends StatelessWidget {
  final String title;
  final String genre;
  final bool isPopular;
  final int userIcons;
  final String? bookCoverUrl;
  final String threadId;

  const BookListItem({
    super.key,
    required this.title,
    required this.genre,
    required this.isPopular,
    required this.userIcons,
    this.bookCoverUrl,
    required this.threadId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryView(threadId: threadId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80.0,
              height: 120.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                image: DecorationImage(
                  image: bookCoverUrl != null
                      ? NetworkImage(bookCoverUrl!)
                      : const AssetImage('assets/book.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: SizedBox(
                height: 120.0,
                child: Stack(
                  children: [
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
                              const Icon(
                                Icons.local_fire_department,
                                color: Color(0xFFD35400),
                                size: 18.0,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          genre,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF9DB2CE),
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Row(
                        children: List.generate(
                          userIcons,
                          (index) => Transform.translate(
                            offset: Offset(-10.0 * index, 0),
                            child: const Icon(
                              Icons.account_circle_rounded,
                              color: Color.fromARGB(255, 110, 125, 147),
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
