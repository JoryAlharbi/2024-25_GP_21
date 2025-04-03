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
  bool isSummaryClicked = false;
  bool isUploadClicked = false;
  bool isAIGenerateClicked = false;

  @override
  void initState() {
    super.initState();
    fetchThreadData();
  }

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
            Uri.parse("http://10.0.2.2:5000/summarize"),
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
        });
      }
    } catch (e) {
      print("Summary error: $e");
    }

    setState(() => isGeneratingSummary = false);
  }

  Future<void> pickImage() async {
    setState(() => isUploadClicked = true);
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      setState(() => isUploadClicked = false);
      return;
    }

    File imageFile = File(pickedFile.path);
    String fileName = "cover_${widget.threadID}.jpg";
    Reference storageRef =
        FirebaseStorage.instance.ref().child("covers/$fileName");

    await storageRef.putFile(imageFile);
    String newCoverUrl = await storageRef.getDownloadURL();

    setState(() {
      bookCoverUrl = newCoverUrl;
      isUploadClicked = false;
    });
  }

  Future<void> generateAICover() async {
    setState(() {
      isGeneratingCover = true;
      isAIGenerateClicked = true;
    });

    try {
      DocumentSnapshot threadDoc = await FirebaseFirestore.instance
          .collection('Thread')
          .doc(widget.threadID)
          .get();

      String threadTitle = threadDoc['title'];
      List<dynamic> genreRefs = threadDoc['genreID'];
      List<String> genres = [];

      for (var ref in genreRefs) {
        DocumentSnapshot genreDoc = await (ref as DocumentReference).get();
        if (genreDoc.exists) {
          genres.add(genreDoc['genreName']);
        }
      }

      var response = await http.post(
        Uri.parse("http://10.0.2.2:5000/generate-image"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": threadTitle, "genres": genres}),
      );

      if (response.statusCode == 200) {
        String generatedImageUrl = jsonDecode(response.body)['image_url'];
        await FirebaseFirestore.instance
            .collection('Thread')
            .doc(widget.threadID)
            .update({"bookCoverUrl": generatedImageUrl});
        setState(() => bookCoverUrl = generatedImageUrl);
      }
    } catch (e) {
      print("AI Cover Error: $e");
    }

    setState(() {
      isGeneratingCover = false;
      isAIGenerateClicked = false;
    });
  }

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
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => isLoading = true);
                      await publishThread();
                      setState(() => isLoading = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD35400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Publish',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
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
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      setState(() => isSummaryClicked = true);
                      await generateSummaryFromParts();
                      await Future.delayed(Duration(milliseconds: 500));
                      setState(() => isSummaryClicked = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A3B4D),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.summarize,
                              color: isSummaryClicked
                                  ? Color(0xFFA2DED0)
                                  : Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "Generate Description",
                            style: GoogleFonts.poppins(
                              color: isSummaryClicked
                                  ? Color(0xFFA2DED0)
                                  : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Book cover:",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Center(
                    child: bookCoverUrl != null
                        ? Image.network(bookCoverUrl!,
                            height: 180, fit: BoxFit.cover)
                        : const Icon(Icons.image,
                            size: 100, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A3B4D),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upload_file,
                                  color: isUploadClicked
                                      ? Color(0xFFA2DED0)
                                      : Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "Upload",
                                style: GoogleFonts.poppins(
                                  color: isUploadClicked
                                      ? Color(0xFFA2DED0)
                                      : Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: isGeneratingCover ? null : generateAICover,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A3B4D),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: isGeneratingCover
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome,
                                        color: isAIGenerateClicked
                                            ? Color(0xFFA2DED0)
                                            : Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      "AI Generate",
                                      style: GoogleFonts.poppins(
                                        color: isAIGenerateClicked
                                            ? Color(0xFFA2DED0)
                                            : Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
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
