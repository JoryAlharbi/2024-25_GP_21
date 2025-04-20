import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:rawae_gp24/read_book.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rawae_gp24/custom_navigation_bar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  double averageRating = 0.0;
  int totalRatings = 0;
  bool hasRated = false;
  double userRating = 0;

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

  Future<void> markBookAsRead(String threadID) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final threadRef =
        FirebaseFirestore.instance.collection('Thread').doc(threadID);

    await threadRef.update({
      'readers': FieldValue.arrayUnion([user.uid])
    });
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

    // Fetch ratings
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadID)
        .collection('Ratings')
        .get();

    if (ratingsSnapshot.docs.isNotEmpty) {
      double total = 0;
      int count = 0;
      double currentUserRating = 0;
      bool currentUserHasRated = false;

      for (var doc in ratingsSnapshot.docs) {
        double r = (doc['rating'] ?? 0).toDouble();
        total += r;
        count++;
        if (doc.id == FirebaseAuth.instance.currentUser?.uid) {
          currentUserRating = r;
          currentUserHasRated = true;
        }
      }

      setState(() {
        averageRating = total / count;
        totalRatings = count;
        userRating = currentUserRating;
        hasRated = currentUserHasRated;
      });
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
              // Average Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingBarIndicator(
                    rating: averageRating,
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 24.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    averageRating.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "  ($totalRatings ratings)",
                    style: const TextStyle(color: Colors.white38),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Description with "Description: "
              Text(
                "Description: ${bookData!['description'] ?? 'Not available.'}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              // Start Reading Button
              GestureDetector(
                onTap: () async {
                  await markBookAsRead(widget.threadID);
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
              const SizedBox(height: 20),
              Text(
                'Rate this book:',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  submitRating(widget.threadID, rating.toInt());
                  setState(() {
                    userRating = rating;
                    hasRated = true;
                  });
                },
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

  Future<void> submitRating(String threadID, int rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final threadDoc = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(threadID)
        .get();
    final readers = List<String>.from(threadDoc['readers'] ?? []);

    if (!readers.contains(user.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You need to read the book before rating."),
      ));
      return;
    }

    await FirebaseFirestore.instance
        .collection('Thread')
        .doc(threadID)
        .collection('Ratings')
        .doc(user.uid)
        .set({
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Rating submitted. Thanks!"),
    ));

    fetchBookDetails(); // Refresh to show updated average
  }
}
