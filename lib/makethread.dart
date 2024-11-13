import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'threads.dart';

class MakeThreadPage extends StatefulWidget {
  const MakeThreadPage({super.key});

  @override
  _MakeThreadPageState createState() => _MakeThreadPageState();
}

class _MakeThreadPageState extends State<MakeThreadPage> {
  final _formKey = GlobalKey<FormState>();
  String? _threadTitle;
  List<DocumentReference> _selectedGenres =
      []; // For storing selected genres as DocumentReferences
  XFile? _bookCover;
  bool _isUploading = false;
  List<QueryDocumentSnapshot> availableGenres =
      []; // For storing genres from Firestore

  @override
  void initState() {
    super.initState();
    _fetchGenres(); // Fetch available genres from Firestore
  }

  // Fetch genres from Firestore
  Future<void> _fetchGenres() async {
    final snapshot = await FirebaseFirestore.instance.collection('Genre').get();
    setState(() {
      availableGenres = snapshot.docs; // Populate available genres
    });
  }

  // Function to upload the image to Firebase Storage
  // Function to upload the image to Firebase Storage
  Future<String?> uploadImage(XFile image) async {
    setState(() => _isUploading = true);
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('covers/${image.name}');
      await storageRef.putFile(File(image.path));

      // Retrieve the download URL
      final downloadURL = await storageRef.getDownloadURL();
      print(
          'Download URL: $downloadURL'); // Debug statement to confirm URL retrieval
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _createThread() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? bookCoverUrl;
      if (_bookCover != null) {
        bookCoverUrl = await uploadImage(_bookCover!);

        // Confirm the URL is not null before proceeding
        if (bookCoverUrl == null) {
          print("Image upload failed, bookCoverUrl is null");
          return; // Stop if image upload failed
        }
      }

      try {
        // Create a new thread document in Firestore
        final threadRef =
            await FirebaseFirestore.instance.collection('Thread').add({
          'title': _threadTitle,
          'bookCoverUrl': bookCoverUrl,
          'writerID': FirebaseAuth.instance.currentUser != null
              ? FirebaseFirestore.instance
                  .collection('Writer')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
              : null,
          'characterNum': 10,
          'totalView': 0,
          'createdAt': Timestamp.now(),
          'genreID':
              _selectedGenres, // Store selected genres as DocumentReferences
          'status': 'in_progress',
          'threadID': DateTime.now().millisecondsSinceEpoch,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StoryView(threadId: threadRef.id),
          ),
        );
      } catch (e) {
        print('Error creating thread: $e');
      }
    }
  }

  Widget buildGenreChips() {
    return Wrap(
      spacing: 8.0,
      children: availableGenres.map((genreDoc) {
        final genreRef = genreDoc.reference;
        final genreName = genreDoc['genreName'] ?? 'Unknown Genre';

        return ChoiceChip(
          label: Text(
            genreName,
            style: GoogleFonts.poppins(
              color: _selectedGenres.contains(genreRef)
                  ? Colors.white
                  : const Color(0xFF9DB2CE),
            ),
          ),
          selected: _selectedGenres.contains(genreRef),
          selectedColor: const Color(0xFFD35400),
          backgroundColor: const Color.fromRGBO(61, 71, 83, 1),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedGenres.add(genreRef);
              } else {
                _selectedGenres.remove(genreRef);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 112, 28, 28),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _isUploading ? null : _createThread,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD35400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Create',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Radial gradient background layer
          Positioned(
            top: 40,
            left: -2,
            child: Container(
              width: 447,
              height: 803,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA2DED0).withOpacity(0.1),
                    const Color(0xFF1B2835).withOpacity(0.15),
                    const Color(0xFFD35400).withOpacity(0.2),
                    const Color(0xFF1B2835).withOpacity(0.1),
                  ],
                  radius: 1.5,
                  center: Alignment.centerRight,
                  stops: const [0.0, 0.2, 0.85, 1],
                ),
                borderRadius: BorderRadius.circular(59),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 90),
                  Text(
                    'Book Title',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(color: Color(0xFF9DB2CE)),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF9DB2CE)),
                      ),
                    ),
                    onSaved: (value) => _threadTitle = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Genre',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  buildGenreChips(), // Display genre chips
                  const SizedBox(height: 20),
                  Text(
                    'Book cover',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      setState(() {
                        _bookCover = image;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A3B4D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _bookCover != null
                          ? Image.file(
                              File(_bookCover!.path),
                              fit: BoxFit.cover,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.image,
                                    color: Color(0xFF9DB2CE), size: 40),
                                const SizedBox(height: 10),
                                Text(
                                  'Upload',
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF9DB2CE)),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
