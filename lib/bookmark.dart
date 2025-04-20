import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rawae_gp24/book.dart';
import 'package:rawae_gp24/custom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rawae_gp24/makethread.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<Map<String, String>> bookmarkedBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookmarkedThreads();
  }

  /// **Fetch the bookmarked threads for the current user**
  Future<void> fetchBookmarkedThreads() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final bookmarkQuery = await FirebaseFirestore.instance
          .collection('BookMark')
          .where('userID', isEqualTo: userId)
          .get();

      if (bookmarkQuery.docs.isEmpty) {
        setState(() {
          bookmarkedBooks = [];
        });
        return;
      }

      List<Map<String, String>> books = [];

      for (var doc in bookmarkQuery.docs) {
        String threadID = doc['threadID'];

        final threadSnapshot = await FirebaseFirestore.instance
            .collection('Thread')
            .doc(threadID)
            .get();

        if (threadSnapshot.exists) {
          final threadData = threadSnapshot.data() as Map<String, dynamic>;

          // Extract data safely
          final String title = threadData['title'] ?? 'Untitled';
          final String? imageUrl = threadData['bookCoverUrl'];

          books.add({
            'title': title,
            'image': imageUrl ?? '', // Ensure there's always a value
            'threadID': threadID, // Store threadID for navigation
          });
        }
      }

      setState(() {
        bookmarkedBooks = books;
        isLoading = false;
      });

      print("✅ Bookmarked Books Count: ${bookmarkedBooks.length}");
    } catch (e) {
      print("❌ Error fetching bookmarks: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 112, 28, 28),
        elevation: 0,
        automaticallyImplyLeading: false, // ✅ No back arrow change
      ),
      body: SafeArea(
        // ✅ Ensures no extra space above "Bookmarked"
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0), // ✅ Keep horizontal padding only
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bookmarked', // ✅ Kept original text style
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                  height: 20), // ✅ Controlled spacing below "Bookmarked"
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD35400),
                        ),
                      )
                    : bookmarkedBooks.isEmpty
                        ? const Center(
                            child: Text(
                              "No bookmarks yet",
                              style: TextStyle(color: Colors.white60),
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: bookmarkedBooks.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 19.0,
                              crossAxisSpacing: 22.0,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              final book = bookmarkedBooks[index];

                              return GestureDetector(
                                onTap: () {
                                  // Navigate to BookDetailsPage when a book cover is clicked
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookDetailsPage(
                                          threadID: book['threadID']!),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 190,
                                      width: 132,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        image: book['image']!.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    book['image']!),
                                                fit: BoxFit.cover,
                                              )
                                            : const DecorationImage(
                                                image: AssetImage(
                                                    'assets/placeholder_book.png'),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      book['title']!,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
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
      bottomNavigationBar: CustomNavigationBar(selectedIndex: 2),
    );
  }
}
