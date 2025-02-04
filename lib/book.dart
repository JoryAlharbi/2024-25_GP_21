import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rawae_gp24/read_book.dart';
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

  @override
  void initState() {
    super.initState();
    fetchBookDetails();
  }

  /// **Fetch only author names from Firestore**
  Future<List<String>> fetchAuthors(List<dynamic> authorRefs) async {
    List<String> authorNamesList = [];

    for (var authorRef in authorRefs) {
      if (authorRef is DocumentReference) {
        DocumentSnapshot authorDoc = await authorRef.get();

        if (authorDoc.exists) {
          authorNamesList
              .add(authorDoc['name'] ?? 'Unknown'); // ✅ Only get names
        }
      }
    }

    return authorNamesList;
  }

  /// **Fetch book details, including authors, from Firestore**
  void fetchBookDetails() async {
    print(
        "📢 Fetching book details for Firestore document ID: ${widget.threadID}");

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Thread') // 🔍 Searching in 'Thread' collection
        .doc(widget.threadID) // ✅ Use Firestore document ID here
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print("✅ Book found: ${data['title']}");

      List<dynamic> authorRefs =
          data['contributors'] ?? []; // ✅ Get list of author references

      // Fetch author names only
      List<String> authorNames = await fetchAuthors(authorRefs);

      setState(() {
        bookData = data;
        authors = authorNames; // ✅ Store only names
      });
    } else {
      print("❌ Book not found in Firestore. Check the document ID.");
    }
  }

  /// **Build the Authors Section**
  Widget buildAuthorsSection() {
    if (authors.isEmpty) {
      return Text(
        "Authors: Unknown",
        style: TextStyle(color: Colors.grey[400], fontSize: 14),
      );
    }

    return Text(
      "Authors: ${authors.join(', ')}", // ✅ Display names as a comma-separated list
      style: TextStyle(color: Colors.grey[400], fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2835),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (bookData != null) ...[
              Image.network(
                bookData!['bookCoverUrl'],
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported,
                      size: 100, color: Colors.grey);
                },
              ),
              const SizedBox(height: 20),
              Text(
                bookData!['title'],
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildAuthorsSection(), // ✅ Now shows authors dynamically
              const SizedBox(height: 20),
              Text(
                bookData!['description'] ?? "No description available.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ReadBookPage(threadID: widget.threadID)),
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
              const CircularProgressIndicator(), // ✅ Show loading until book data is fetched
          ],
        ),
      ),
    );
  }
}
