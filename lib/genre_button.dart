import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GenreButton extends StatelessWidget {
  final String genre;
  final VoidCallback onPressed;
  final bool isSelected; // <-- Add this

  const GenreButton(
    this.genre, {
    required this.onPressed,
    this.isSelected = false, // <-- Default to false
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? const Color(0xFFD35400) : const Color(0xFF313E4F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          genre,
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
