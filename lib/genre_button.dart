import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GenreButton extends StatelessWidget {
  final String genre;
  const GenreButton(this.genre, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color.fromARGB(255, 49, 62, 79), // Genre box color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Corner radius set to 8
          ),
        ),
        onPressed: () {
          // Handle genre filter
        },
        child: Text(
          genre,
          style: GoogleFonts.poppins(color: Colors.white), // Poppins text style
        ),
      ),
    );
  }
}
