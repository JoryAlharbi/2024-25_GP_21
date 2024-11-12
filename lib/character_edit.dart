import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditCharacterPage extends StatefulWidget {
  final String userName;

  const EditCharacterPage({super.key, required this.userName});

  @override
  _EditCharacterPageState createState() => _EditCharacterPageState();
}

class _EditCharacterPageState extends State<EditCharacterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _additionalDetails;

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
                  decoration: InputDecoration(
                    hintText: 'Enter additional details...',
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Handle saving details and navigate back to the thread page
                      Navigator.pop(
                          context); // Navigate back to the thread page after saving.
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
                    'Done',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
