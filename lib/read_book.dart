import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReadBookPage extends StatefulWidget {
  final String threadID; // Book ID from Firestore

  const ReadBookPage({super.key, required this.threadID});

  @override
  _ReadBookPageState createState() => _ReadBookPageState();
}

class _ReadBookPageState extends State<ReadBookPage> {
  String bookTitle = "";
  String bookContent = "";

  @override
  void initState() {
    super.initState();
    fetchBookContent();
  }

  void fetchBookContent() async {
    DocumentSnapshot bookDoc = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadID)
        .get();

    if (bookDoc.exists) {
      setState(() {
        bookTitle = bookDoc['title'];
        bookContent =
            bookDoc['content']; // Ensure Firestore has a "content" field
      });
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          bookTitle.isEmpty ? "Loading..." : bookTitle,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: bookContent.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD35400)),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookContent,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[300],
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
