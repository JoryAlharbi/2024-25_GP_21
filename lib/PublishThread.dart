import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';

class PublishThreadPage extends StatefulWidget {
  final String threadID;

  const PublishThreadPage({super.key, required this.threadID});

  @override
  _PublishThreadPageState createState() => _PublishThreadPageState();
}

class _PublishThreadPageState extends State<PublishThreadPage> {
  TextEditingController summaryController = TextEditingController();
  String? bookCoverUrl;
  bool isLoading = true;
  bool isGeneratingCover = false;
  bool isGeneratingSummary = false;

  @override
  void initState() {
    super.initState();
    fetchThreadData();
  }

  /// **Fetches thread details, generates summary if missing**
  Future<void> fetchThreadData() async {
    setState(() => isLoading = true);

    DocumentSnapshot threadDoc = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadID)
        .get();

    if (threadDoc.exists) {
      String? existingSummary = threadDoc['description'];
      bookCoverUrl = threadDoc['bookCoverUrl'];

      if (existingSummary != null && existingSummary.isNotEmpty) {
        setState(() {
          summaryController.text = existingSummary;
          isLoading = false;
        });
      } else {
        await generateSummaryFromParts();
      }
    }
  }

  /// **Generates summary from thread parts**
  Future<void> generateSummaryFromParts() async {
    setState(() => isGeneratingSummary = true);

    QuerySnapshot partsSnapshot = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadID)
        .collection('Parts')
        .orderBy('createdAt', descending: false)
        .get();

    String fullContent =
        partsSnapshot.docs.map((doc) => doc['content']).join(' ');

    if (fullContent.isEmpty) {
      setState(() {
        summaryController.text = "No content available.";
        isGeneratingSummary = false;
      });
      return;
    }

    try {
      var response = await http
          .post(
            Uri.parse("http://127.0.0.1:5000/summarize"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": fullContent}),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        String summaryText = jsonDecode(response.body)['summary'];

        await FirebaseFirestore.instance
            .collection('Thread')
            .doc(widget.threadID)
            .update({"description": summaryText});

        setState(() {
          summaryController.text = summaryText;
          isGeneratingSummary = false;
        });
      }
    } catch (e) {
      print("⏳ Timeout or Error: $e");
    }

    setState(() => isGeneratingSummary = false);
  }

  /// **Uploads an image from the gallery**
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String fileName = "cover_${widget.threadID}.jpg";
    Reference storageRef =
        FirebaseStorage.instance.ref().child("covers/$fileName");

    await storageRef.putFile(imageFile);
    String newCoverUrl = await storageRef.getDownloadURL();

    setState(() {
      bookCoverUrl = newCoverUrl;
    });
  }

  /// **Generates AI Cover using DALL-E**
  Future<void> generateAICover() async {
    setState(() => isGeneratingCover = true);

    try {
      DocumentSnapshot threadDoc = await FirebaseFirestore.instance
          .collection('Thread')
          .doc(widget.threadID)
          .get();

      String threadTitle = threadDoc['title'] ?? 'Unknown Title';
      List<String> genres = [];

      List<dynamic> genreRefs = threadDoc['genreID'];
      for (var ref in genreRefs) {
        DocumentSnapshot genreDoc = await (ref as DocumentReference).get();
        if (genreDoc.exists) {
          genres.add(genreDoc['genreName']);
        }
      }

      print("📸 Generating AI Cover for: $threadTitle - Genres: $genres");

      var response = await http.post(
        Uri.parse("http://127.0.0.1:5000/generate-image"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": threadTitle, "genres": genres}),
      );

      if (response.statusCode == 200) {
        String generatedImageUrl = jsonDecode(response.body)['image_url'];

        await FirebaseFirestore.instance
            .collection('Thread')
            .doc(widget.threadID)
            .update({"bookCoverUrl": generatedImageUrl});

        setState(() {
          bookCoverUrl = generatedImageUrl;
          isGeneratingCover = false;
        });

        print("✅ AI Cover Generated: $generatedImageUrl");
      } else {
        print("❌ AI Cover Error: ${response.body}");
      }
    } catch (e) {
      print("🚨 AI Cover Generation Failed: $e");
    }

    setState(() => isGeneratingCover = false);
  }

  /// **Publishes the thread**
  Future<void> publishThread() async {
    await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadID)
        .update({
      'description': summaryController.text,
      'bookCoverUrl': bookCoverUrl,
      'status': 'Published',
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2835),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF9DB2CE)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: publishThread,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD35400),
              ),
              child: Text("Publish", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD35400)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Book description:",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                      controller: summaryController,
                      maxLines: 6,
                      style: GoogleFonts.poppins(color: Colors.white)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed:
                        isGeneratingSummary ? null : generateSummaryFromParts,
                    child: isGeneratingSummary
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Generate Summary"),
                  ),
                  const SizedBox(height: 20),
                  Text("Book cover:",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Center(
                      child: bookCoverUrl != null
                          ? Image.network(bookCoverUrl!,
                              height: 180, fit: BoxFit.cover)
                          : Icon(Icons.image, size: 100, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: pickImage, child: Text("Upload")),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: isGeneratingCover ? null : generateAICover,
                        child: isGeneratingCover
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("AI Generate"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
