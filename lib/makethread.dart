import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'threads.dart'; // Ensure this is the correct import path for threads.dart

class MakeThreadPage extends StatefulWidget {
  const MakeThreadPage({super.key});

  @override
  _MakeThreadPageState createState() => _MakeThreadPageState();
}

class _MakeThreadPageState extends State<MakeThreadPage> {
  final _formKey = GlobalKey<FormState>();
  String? _threadTitle;
  String? _selectedGenre;
  XFile? _bookCover;

  final List<String> genres = [
    'Thriller',
    'Fantasy',
    'Fiction',
    'Romance',
    'Mystery',
    'Science Fiction',
    'Horror',
    'Historical',
    'Adventure',
    'Drama',
    'Non-Fiction'
  ];

  Future<void> _createThread() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Upload the book cover image if one is provided (optional, add logic for uploading)
        String? bookCoverUrl;
        if (_bookCover != null) {
          // Add code here to upload the image to Firebase Storage and get the URL
        }

        // Save the thread data to Firestore with the structure you have
        await FirebaseFirestore.instance.collection('Thread').add({
          'threadID': DateTime.now()
              .millisecondsSinceEpoch, // or your logic for threadID
          'genreID': _selectedGenre != null
              ? '/Genre/${_selectedGenre!.toLowerCase()}'
              : null, // genre path
          'writerID': FirebaseAuth.instance.currentUser?.uid,

          'characterNum': 10, // Replace with actual data if available
          'totalView': 0, // Initial view count
          'createdAt':
              Timestamp.now(), // Timestamp for when the thread was created
          'title': _threadTitle,
          'bookCoverUrl': bookCoverUrl, // Replace with actual upload logic
        });

        // Navigate to the threads page after creating the thread
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StoryView(), // Replace with your threads page class
          ),
        );
      } catch (e) {
        print('Error creating thread: $e');
        // Show a dialog or Snackbar to notify the user of the error
      }
    }
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _createThread,
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
          // Main content
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
                  Wrap(
                    spacing: 8.0,
                    children: genres.map((genre) {
                      return ChoiceChip(
                        label: Text(
                          genre,
                          style: GoogleFonts.poppins(
                            color: _selectedGenre == genre
                                ? Colors.white
                                : const Color(0xFF9DB2CE),
                          ),
                        ),
                        selected: _selectedGenre == genre,
                        selectedColor: const Color(0xFFD35400),
                        backgroundColor: const Color.fromRGBO(61, 71, 83, 1),
                        onSelected: (selected) {
                          setState(() {
                            _selectedGenre = selected ? genre : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
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
