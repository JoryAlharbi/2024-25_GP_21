import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'threads.dart';
import 'writing.dart';

class MakeThreadPage extends StatefulWidget {
  const MakeThreadPage({Key? key}) : super(key: key);

  @override
  _MakeThreadPageState createState() => _MakeThreadPageState();
}

class _MakeThreadPageState extends State<MakeThreadPage> {
  final _formKey = GlobalKey<FormState>();
  String? _threadTitle;
  List<DocumentReference> _selectedGenres = [];
  XFile? _bookCover;
  bool _isUploading = false;
  List<QueryDocumentSnapshot> availableGenres = [];

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    final snapshot = await FirebaseFirestore.instance.collection('Genre').get();
    setState(() {
      availableGenres = snapshot.docs;
    });
  }

  Future<String?> uploadImage(XFile image) async {
    setState(() => _isUploading = true);
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('covers/${image.name}');
      await storageRef.putFile(File(image.path));
      final downloadURL = await storageRef.getDownloadURL();
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
      if (_selectedGenres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one genre.')),
        );
        return;
      }

      _formKey.currentState!.save();
      String? bookCoverUrl;

      if (_bookCover != null) {
        bookCoverUrl = await uploadImage(_bookCover!);
        if (bookCoverUrl == null) return;
      }

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in.')),
          );
          return;
        }

        final threadRef =
            await FirebaseFirestore.instance.collection('Thread').add({
          'title': _threadTitle,
          'bookCoverUrl': bookCoverUrl,
          'writerID':
              FirebaseFirestore.instance.collection('Writer').doc(user.uid),
          'totalView': 0,
          'createdAt': Timestamp.now(),
          'genreID': _selectedGenres,
          'bellClickers': [],
          'contributors': [],
          'status': 'in_progress',
          'threadID': DateTime.now().millisecondsSinceEpoch,
          'isWriting': false,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WritingPage(
              threadId: threadRef.id,
              //  userId: user.uid,
            ),
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

  bool _isLoading = false; // Add a loading state variable

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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white, // Match your app's theme
                    ),
                  )
                : ElevatedButton(
                    onPressed: _isUploading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true; // Show loading indicator
                            });

                            try {
                              await _createThread(); // Perform thread creation
                            } finally {
                              setState(() {
                                _isLoading = false; // Hide loading indicator
                              });
                            }
                          },
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Book Title*',
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
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Genre*',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              buildGenreChips(),
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
    );
  }
}
