import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'threads.dart';
import 'writing.dart';

class CoverTypeToggle extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const CoverTypeToggle({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: !value ? const Color(0xFFD35400) : const Color(0xFF2A3B4D),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            ),
            child: Text(
              'Upload',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: !value ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: value ? const Color(0xFFD35400) : const Color(0xFF2A3B4D),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
            ),
            child: Text(
              'AI Generate',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: value ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
  bool _isGenerating = false;
  List<QueryDocumentSnapshot> availableGenres = [];
  String? _generatedImageUrl;
  bool _useGeneration = false; // Toggle between upload and generate

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

  Future<String?> _generateCoverWithDalle() async {
    setState(() => _isGenerating = true);
    try {
      // Get genre names instead of references for the API
      List<String> genreNames = [];
      for (var genreRef in _selectedGenres) {
        final doc = await genreRef.get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          genreNames.add(data['genreName'] ?? '');
        }
      }

       print("Triggering image generation...");
        const apiUrl = 'http://10.0.2.2:5000/generate-image';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': _threadTitle,
          'genres': genreNames,
        }),
      );
      print("Request sent, response status: ${response.statusCode}");

      print(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['image_url'];
      }
      return null;
    } catch (e) {
      print("Error generating image: $e");
      return null;
    } finally {
      setState(() => _isGenerating = false);
    }
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

      if (_useGeneration) {
        print("1111hjqjhhjahahjhjshjsjhs");
        // Generate cover with DALL-E
        bookCoverUrl = await _generateCoverWithDalle();
        if (bookCoverUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate cover image.')),
          );
          return;
        }
      } else if (_bookCover != null) {
        // Upload user's image
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
        final genreName = genreDoc.get('genreName') ?? 'Unknown Genre';

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

  bool _isLoading = false;
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
                      color: Colors.white,
                    ),
                  )
                : ElevatedButton(
                    onPressed: _isUploading || _isGenerating
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await _createThread();
                            } finally {
                              setState(() {
                                _isLoading = false;
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
                onChanged: (value) => _threadTitle = value,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Book cover',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CoverTypeToggle(
                    value: _useGeneration,
                    onChanged: (value) {
                      setState(() {
                        _useGeneration = value;
                        if (value) {
                          _bookCover = null;
                        } else {
                          _generatedImageUrl = null;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (!_useGeneration)
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _bookCover = image;
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3B4D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _bookCover != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_bookCover!.path),
                              fit: BoxFit.contain,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_file,
                                  color: Color(0xFF9DB2CE), size: 40),
                              const SizedBox(height: 10),
                              Text(
                                '                     Upload Cover                     ',
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF9DB2CE)),
                              ),
                            ],
                          ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () async {
                    // Trigger DALL-E API call when the user taps on the generated image section
                    if (_useGeneration && !_isGenerating) {
                      String? generatedImageUrl = await _generateCoverWithDalle();
                      if (generatedImageUrl != null) {
                        setState(() {
                          _generatedImageUrl = generatedImageUrl;
                        });
                      }
                    }
                  },
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3B4D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _generatedImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _generatedImageUrl!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isGenerating)
                                const CircularProgressIndicator(
                                  color: Color(0xFF9DB2CE),
                                )
                              else ...[
                                const Icon(Icons.auto_awesome,
                                    color: Color(0xFF9DB2CE), size: 40),
                                const SizedBox(height: 10),
                                Text(
                                  '                   Generate Cover                   ',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF9DB2CE),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              const SizedBox(height: 20),
              
            ],
          ),
        ),
      ),
    );
  }
}