import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditCharacterPage extends StatefulWidget {
  final String userName;

 final String description;
 final String threadId;
 final String partId;

  const EditCharacterPage({super.key, required this.userName,
  required this.description,
   required this.threadId,
  required this.partId,});

  @override
  _EditCharacterPageState createState() => _EditCharacterPageState();
}

class _EditCharacterPageState extends State<EditCharacterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _additionalDetails;
  Future<http.Response> _sendCharactersToAPI(
      String additionalDetails, String threadId, String partId) {
    const apiUrl = 'http://10.0.2.2:5000/generate-image'; // Local API URL
    return http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'story_text': additionalDetails,
        'thread_id': threadId,
        'part_id': partId,
        "additional" :true 
      }),
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular character image placeholder
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(
                        0xFF2A3B4D), // Background color for the placeholder
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_circle_rounded,
                      size: 140,
                      color:
                          Color(0xFF9DB2CE), // Profile icon placeholder color
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // "Add more details" label
                Text(
                  'Add more details:',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Text field for adding more details
                TextFormField(
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white),
                  initialValue: widget.description,
                  decoration: InputDecoration(
                    hintText: 'use creative and specific details to give a clear picture',
                    hintStyle: const TextStyle(color: Color(0xFF9DB2CE)),
                    filled: true,
                    fillColor: const Color(0xFF2A3B4D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSaved: (value) => _additionalDetails = value,
                ),
                const SizedBox(height: 20),
                // Done button
ElevatedButton(
  onPressed: () async {
    // Ensure the form is saved before making the request
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save(); // Save the form to capture the entered text

      // Send the entered text (stored in _additionalDetails) to the API
      final response = await _sendCharactersToAPI(
        _additionalDetails ?? '', // Send the text from the text field as tags
        widget.threadId,
        widget.partId,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
       Map<String, dynamic> arguments = {
          'userName': 'Character Name', // You can modify this to use a dynamic value if needed
          'threadId': widget.threadId,
          'partId': widget.partId,
          'storyText': 'Your story text here',  // Replace with actual story text if applicable
          'userId': 'UserId here',  // Replace with actual userId if applicable
          'publicUrl': jsonDecode(response.body)['public_url'], // Assuming your API returns 'public_url'
          'description': _additionalDetails, 
           // Use the existing characterTags
        };

        // Navigate back with arguments
        Navigator.pop(context, arguments);// Navigate back to the thread page after saving.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to process characters!")),
        );
      }
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFD35400),
    padding: const EdgeInsets.symmetric(
        vertical: 12.0, horizontal: 24.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: Text(
    'Repaint',
    style: GoogleFonts.poppins(
      fontSize: 16,
      color: Colors.white,
    ),
  ),
)

              ],
            ),
          ),
        ),
      ),
    );
  }
  

}
