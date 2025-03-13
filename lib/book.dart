import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:rawae_gp24/read_book.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rawae_gp24/custom_navigation_bar.dart';

class BookDetailsPage extends StatefulWidget {
  final String threadID;

  const BookDetailsPage({super.key, required this.threadID});

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  Map<String, dynamic>? bookData;
  List<String> authors = [];
  bool isBookmarked = false; // Track bookmark status

  @override
  void initState() {
    super.initState();
    fetchBookDetails();
    checkIfBookmarked();
  }

  /// Fetch author names from Firestore references
  Future<List<String>> fetchAuthors(List<dynamic> authorRefs) async {
    List<String> authorNamesList = [];

    for (var authorRef in authorRefs) {
      if (authorRef is DocumentReference) {
        DocumentSnapshot authorDoc = await authorRef.get();
        if (authorDoc.exists) {
          authorNamesList.add(authorDoc['name'] ?? 'Unknown');
        }
      }
    }
    return authorNamesList;
  }

  /// Fetch book details from Firestore
  void fetchBookDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadID)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<dynamic> authorRefs = data['contributors'] ?? [];
      List<String> authorNames = await fetchAuthors(authorRefs);

      setState(() {
        bookData = data;
        authors = authorNames;
      });
    } else {
      print("❌ Thread not found in Firestore.");
    }
  }

  /// Check if the user has bookmarked this thread
  Future<void> checkIfBookmarked() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final bookmarkQuery = await FirebaseFirestore.instance
        .collection('BookMark')
        .where('userID', isEqualTo: userId)
        .where('threadID', isEqualTo: widget.threadID)
        .get();

    setState(() {
      isBookmarked = bookmarkQuery.docs.isNotEmpty;
    });
  }

  /// Add bookmark
  Future<void> addBookmark() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('BookMark').add({
      'userID': userId,
      'threadID': widget.threadID,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      isBookmarked = true;
    });
  }

  /// Remove bookmark
  Future<void> removeBookmark() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final bookmarkQuery = await FirebaseFirestore.instance
        .collection('BookMark')
        .where('userID', isEqualTo: userId)
        .where('threadID', isEqualTo: widget.threadID)
        .get();

    for (var doc in bookmarkQuery.docs) {
      await doc.reference.delete();
    }

    setState(() {
      isBookmarked = false;
    });
  }

  /// Toggle Bookmark
  Future<void> toggleBookmark() async {
    if (isBookmarked) {
      await removeBookmark();
    } else {
      await addBookmark();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2835),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF9DB2CE), size: 28),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 36,
                color: isBookmarked ? Color(0xFF9DB2CE) : Color(0xFF9DB2CE),
              ),
              onPressed: toggleBookmark,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (bookData != null) ...[
              // Book Cover with Placeholder if None
              bookData!['bookCoverUrl'] != null &&
                      bookData!['bookCoverUrl'].isNotEmpty
                  ? Image.network(
                      bookData!['bookCoverUrl'],
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/placeholder_book.png',
                      height: 200,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 20),
              // Title
              Text(
                bookData!['title'] ?? 'Untitled',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Authors
              Text(
                "Authors: ${authors.join(', ')}",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 10),
              // Description with "Description: "
              Text(
                "Description: ${bookData!['description'] ?? 'Not available.'}",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              // Start Reading Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReadBookPage(threadID: widget.threadID),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MakeThreadPage()),
          );
        },
        backgroundColor: const Color.fromRGBO(211, 84, 0, 1),
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
