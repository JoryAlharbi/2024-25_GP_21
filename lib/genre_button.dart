import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GenreButton extends StatelessWidget {
  final String genre;
  final VoidCallback onPressed; // Add a callback

  const GenreButton(this.genre, {required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF313E4F), // Genre box color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Corner radius set to 8
          ),
        ),
        onPressed: onPressed,
        child: Text(
          genre,
          style: GoogleFonts.poppins(color: Colors.white), // Poppins text style
        ),
      ),
    );
  }
}
