import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'threads.dart'; // Ensure this is the correct import path for threads.dart

class MakeThreadPage extends StatefulWidget {
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
    'Mystery'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 112, 28, 28),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Navigate to the threads page after creating the thread
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StoryView(), // Replace with the actual class for threads.dart
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD35400),
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
                    Color(0xFFA2DED0).withOpacity(0.1),
                    Color(0xFF1B2835).withOpacity(0.15),
                    Color(0xFFD35400).withOpacity(0.2),
                    Color(0xFF1B2835).withOpacity(0.1),
                  ],
                  radius: 1.5,
                  center: Alignment.centerRight,
                  stops: [0.0, 0.2, 0.85, 1],
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
                  SizedBox(height: 90),
                  Text(
                    'Book Title',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
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
                  SizedBox(height: 20),
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
                                : Color(0xFF9DB2CE),
                          ),
                        ),
                        selected: _selectedGenre == genre,
                        selectedColor: Color(0xFFD35400),
                        backgroundColor: Color.fromRGBO(61, 71, 83, 1),
                        onSelected: (selected) {
                          setState(() {
                            _selectedGenre = selected ? genre : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Book cover',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker _picker = ImagePicker();
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      setState(() {
                        _bookCover = image;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color(0xFF2A3B4D),
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
                                Icon(Icons.image,
                                    color: Color(0xFF9DB2CE), size: 40),
                                SizedBox(height: 10),
                                Text(
                                  'Upload',
                                  style: GoogleFonts.poppins(
                                      color: Color(0xFF9DB2CE)),
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
