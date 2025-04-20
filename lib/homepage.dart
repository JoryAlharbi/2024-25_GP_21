import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'threads.dart';
import 'makethread.dart';
import 'custom_navigation_bar.dart';
import 'genre_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SearchPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedGenreName;
  int selectedIndex = 0;
  String? selectedGenreRef; // Track the selected genre reference for filtering
    final GlobalKey _fabKey = GlobalKey();
 @override
  void initState() {
    super.initState();
    // Start the tutorial after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialService.startHomeTutorial(context, _fabKey);
    });
  }


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

  Future<List<String>> _getContributors(String threadId) async {
    final threadDoc = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(threadId)
        .get();
    final List<dynamic> contributorRefs = threadDoc['contributors'] ?? [];

    List<String> profileImageUrls = [];
    for (var ref in contributorRefs) {
      if (ref is DocumentReference) {
        final userSnapshot = await ref.get();
        if (userSnapshot.exists) {
          final data = userSnapshot.data() as Map<String, dynamic>;
          final profileImageUrl = data['profileImageUrl'] ??
              ''; // Default to empty string if missing
          profileImageUrls.add(profileImageUrl);
        }
      }
    }
    return profileImageUrls;
  }

  Future<void> _toggleGenreFilter(String genreName) async {
    setState(() {
      selectedGenreRef = null; // Clear the filter while processing
    });

    if (genreName == 'null') {
      // If "ALL" is clicked, reseting the filter
      setState(() {
        selectedGenreRef = null;
        selectedGenreName = null;
      });
      return;
    }
    // Fetch the genre reference corresponding to the genreName
    final genreQuery = await FirebaseFirestore.instance
        .collection('Genre')
        .where('genreName', isEqualTo: genreName)
        .get();

    if (genreQuery.docs.isNotEmpty) {
      final genreRef = genreQuery.docs.first.reference;
      setState(() {
        if (selectedGenreRef == genreRef.path) {
          selectedGenreRef =
              null; // Reset filter if clicking the same genre again
          selectedGenreName = null;
        } else {
          selectedGenreRef = genreRef.path; // Set new genre filter
          selectedGenreName = genreName;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(
        child: Text(
          "Please log in to view the homepage.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color(0x00701C1C),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // 🔔 Notification Bell with Red Dot
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Thread')
                .where('status', isEqualTo: 'in_progress')
                .where('bellClickers',
                    arrayContains: FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              bool showRedDot = false;

              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final isWriting = doc['isWriting'] ?? false;
                  if (!isWriting) {
                    showRedDot = true;
                    break;
                  }
                }
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Color(0xFF9DB2CE)),
                    iconSize: 30,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationsPage()),
                      );
                    },
                  ),
                  if (showRedDot)
                    const Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.red,
                      ),
                    ),
                ],
              );
            },
          ),

          // 🔍 Search Icon
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF9DB2CE)),
            iconSize: 31,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchPage(status: "in_progress"),
                ),
              );
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                GenreButton(
                  'All',
                  isSelected: selectedGenreName == null,
                  onPressed: () => _toggleGenreFilter('null'),
                ),
                GenreButton(
                  'Thriller',
                  isSelected: selectedGenreName == 'Thriller',
                  onPressed: () => _toggleGenreFilter('Thriller'),
                ),
                GenreButton(
                  'Fantasy',
                  isSelected: selectedGenreName == 'Fantasy',
                  onPressed: () => _toggleGenreFilter('Fantasy'),
                ),
                GenreButton(
                  'Fiction',
                  isSelected: selectedGenreName == 'Fiction',
                  onPressed: () => _toggleGenreFilter('Fiction'),
                ),
                GenreButton(
                  'Romance',
                  isSelected: selectedGenreName == 'Romance',
                  onPressed: () => _toggleGenreFilter('Romance'),
                ),
                GenreButton(
                  'Mystery',
                  isSelected: selectedGenreName == 'Mystery',
                  onPressed: () => _toggleGenreFilter('Mystery'),
                ),
                GenreButton(
                  'Science Fiction',
                  isSelected: selectedGenreName == 'Science Fiction',
                  onPressed: () => _toggleGenreFilter('Science Fiction'),
                ),
                GenreButton(
                  'Comedy',
                  isSelected: selectedGenreName == 'Comedy',
                  onPressed: () => _toggleGenreFilter('Comedy'),
                ),
                GenreButton(
                  'Drama',
                  isSelected: selectedGenreName == 'Drama',
                  onPressed: () => _toggleGenreFilter('Drama'),
                ),
                GenreButton(
                  'Adventure',
                  isSelected: selectedGenreName == 'Adventure',
                  onPressed: () => _toggleGenreFilter('Adventure'),
                ),
                GenreButton(
                  'Horror',
                  isSelected: selectedGenreName == 'Horror',
                  onPressed: () => _toggleGenreFilter('Horror'),
                ),
                GenreButton(
                  'Historical',
                  isSelected: selectedGenreName == 'Historical',
                  onPressed: () => _toggleGenreFilter('Historical'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color.fromARGB(222, 62, 72, 72)),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedGenreRef == null
                  ? FirebaseFirestore.instance
                      .collection('Thread')
                      .where('status', isEqualTo: 'in_progress')
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('Thread')
                      .where('status', isEqualTo: 'in_progress')
                      .where('genreID',
                          arrayContains:
                              FirebaseFirestore.instance.doc(selectedGenreRef!))
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

                  DocumentSnapshot? mostPopularThread;
                  int highestViewCount = -1;

                  for (var thread in threads) {
                    final data = thread.data() as Map<String, dynamic>;
                    final int totalViews = data['totalView'] ?? 0;
                    if (totalViews > highestViewCount) {
                      highestViewCount = totalViews;
                      mostPopularThread = thread;
                    }
                  }

                  return ListView.builder(
                    itemCount: threads.length,
                    itemBuilder: (context, index) {
                      final threadData =
                          threads[index].data() as Map<String, dynamic>;
                      final List<dynamic> genreRefs =
                          threadData['genreID'] ?? [];
                      final String? bookCoverUrl = threadData['bookCoverUrl'];
                      final String threadId = threads[index].id;

                      bool isPopular = mostPopularThread?.id == threadId;

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
                            isPopular: isPopular,
                            bookCoverUrl: bookCoverUrl,
                            threadId: threadId,
                            userId: userId,
                            getContributors: _getContributors,
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
            key: _fabKey, // Add this key for the tutorial
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
  final String? bookCoverUrl;
  final String threadId;
  final String userId;
  final Future<List<String>> Function(String threadId) getContributors;

  const BookListItem({
    super.key,
    required this.title,
    required this.genre,
    required this.isPopular,
    this.bookCoverUrl,
    required this.threadId,
    required this.userId,
    required this.getContributors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryView(threadId: threadId, userId: userId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88.0,
              height: 132.0,
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
                              const Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Icon(
                                  Icons.local_fire_department,
                                  color: Color(
                                      0xFFD35400), // Orange color for fire icon
                                  size: 18.0,
                                ),
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
                      child: FutureBuilder<List<String>>(
                        future: getContributors(threadId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 35.0,
                              height: 35.0,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFD35400)), // Orange color
                              ),
                            );
                          } else if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text(
                              " ", //No Contributors
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12.0),
                            );
                          } else {
                            final profileImageUrls = snapshot.data!;
                            return Row(
                              children: List.generate(
                                profileImageUrls.length,
                                (index) => Transform.translate(
                                  offset: Offset(-10.0 * index, 0),
                                  child: ClipOval(
                                    child: Image.network(
                                      profileImageUrls[index],
                                      width: 35.0,
                                      height: 35.0,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.account_circle_rounded,
                                          color: Color.fromARGB(
                                              255, 110, 125, 147),
                                          size: 35.0,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
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
