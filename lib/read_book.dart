import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReadBookPage extends StatefulWidget {
  final String threadID;

  const ReadBookPage({super.key, required this.threadID});

  @override
  _ReadBookPageState createState() => _ReadBookPageState();
}

class _ReadBookPageState extends State<ReadBookPage> {
  String bookTitle = "Loading...";
  String bookContent = "";
  double textSize = 16.0;
  List<Map<String, String>> characterImages = []; // List for character images

  @override
  void initState() {
    super.initState();
    fetchThreadDetails();
    fetchBookContent();
    fetchCharacterImages();
  }

  /// **Fetch Thread Title from Firestore**
  void fetchThreadDetails() async {
    DocumentSnapshot threadSnapshot = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadID)
        .get();

    if (threadSnapshot.exists) {
      setState(() {
        bookTitle = threadSnapshot['title'] ?? "Untitled";
      });
    } else {
      setState(() {
        bookTitle = "Untitled";
      });
    }
  }

  /// **Fetch content from Parts subcollection**
  void fetchBookContent() async {
    QuerySnapshot partsSnapshot = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadID)
        .collection('Parts')
        .orderBy('createdAt', descending: false)
        .get();

    if (partsSnapshot.docs.isNotEmpty) {
      setState(() {
        bookContent =
            partsSnapshot.docs.map((doc) => doc['content']).join("\n\n");
      });
    } else {
      setState(() {
        bookContent = "No content available.";
      });
    }
  }

  /// **Fetch Character Images from Firestore**
  Future<void> fetchCharacterImages() async {
    QuerySnapshot characterSnapshot = await FirebaseFirestore.instance
        .collection('Character')
        .where('thread',
            isEqualTo: widget.threadID) // Match characters with thread
        .get();

    List<Map<String, String>> characters = [];

    for (var doc in characterSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      characters.add({
        "name": data["CharacterName"] ?? "Unknown",
        "imageUrl": data["url"] ?? "assets/default_character.png",
      });
    }

    setState(() {
      characterImages = characters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2835),
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Color(0xFF9DB2CE), size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          bookTitle,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: const Color(0xFF2C3E50),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                context: context,
                builder: (context) => _buildTextSizeSelector(),
              );
            },
          ),
        ],
      ),
      body: bookContent.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD35400),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Character Images Row
                    if (characterImages.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Characters',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(228, 255, 255, 255),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: characterImages.length,
                          itemBuilder: (context, index) {
                            final character = characterImages[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Character Avatar
                                  Container(
                                    width: 70,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xFFA2DED0),
                                          width: 4),
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundImage: character['imageUrl']!
                                              .startsWith('assets/')
                                          ? AssetImage(character['imageUrl']!)
                                          : NetworkImage(character['imageUrl']!)
                                              as ImageProvider,
                                      backgroundColor: Colors.grey.shade300,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Character Name
                                  Text(
                                    character['name']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        color: Color(0xFF344C64),
                        height: 20,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ✅ Book Content
                    Text(
                      bookContent,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[300],
                        fontSize: textSize,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// **📌 Bottom Sheet for Text Size Adjustment**
  Widget _buildTextSizeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Adjust Text Size",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.text_decrease, color: Colors.white),
                onPressed: () {
                  setState(() {
                    textSize = (textSize - 2).clamp(12.0, 24.0);
                  });
                  Navigator.pop(context);
                },
              ),
              Text(
                "${textSize.toInt()}",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.text_increase, color: Colors.white),
                onPressed: () {
                  setState(() {
                    textSize = (textSize + 2).clamp(12.0, 24.0);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
