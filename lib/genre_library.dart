import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Import Poppins font
import 'package:rawae_gp24/book.dart';
import 'package:rawae_gp24/custom_navigation_bar.dart';

class GenreLibraryPage extends StatefulWidget {
  final String genreID;
  final String genreName;

  const GenreLibraryPage(
      {super.key, required this.genreID, required this.genreName});

  @override
  _GenreLibraryPageState createState() => _GenreLibraryPageState();
}

class _GenreLibraryPageState extends State<GenreLibraryPage> {
  List<Map<String, dynamic>> threads = [];

  @override
  void initState() {
    super.initState();
    fetchThreadsByGenre();
  }

  void fetchThreadsByGenre() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Thread')
        .where('status', isEqualTo: 'Published')
        .where('genreID',
            arrayContains:
                FirebaseFirestore.instance.doc('Genre/${widget.genreID}'))
        .get();

    setState(() {
      threads = querySnapshot.docs.map((doc) {
        Map<String, dynamic> threadData = doc.data() as Map<String, dynamic>;
        threadData['docID'] =
            doc.id; // ✅ Store Firestore document ID inside the thread data
        return threadData;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        title: Text(
          widget.genreName,
          style: GoogleFonts.poppins(
            // ✅ Changed font to Poppins
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // ✅ Prevents title from being centered
        titleSpacing: 0, // ✅ Removes extra spacing between the icon & text
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF9DB2CE), size: 26), // ✅ Slightly larger arrow
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: threads.isEmpty
          ? const Center(
              child: Text("No threads available",
                  style: TextStyle(color: Colors.white, fontSize: 16)))
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: threads.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 19.0,
                  crossAxisSpacing: 22.0,
                  childAspectRatio: 0.7),
              itemBuilder: (context, index) {
                final thread = threads[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          print(
                              "📢 Navigating to BookDetailsPage with Firestore document ID: ${thread['docID']}");
                          return BookDetailsPage(
                              threadID: thread['docID']); // ✅ Use docID
                        },
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Image.network(thread['bookCoverUrl'],
                          height: 200, width: 130, fit: BoxFit.cover),
                      const SizedBox(height: 8.0),
                      Text(thread['title'],
                          style: GoogleFonts.poppins(
                              // ✅ Poppins for consistency
                              color: Colors.white,
                              fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
