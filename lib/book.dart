import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/library.dart';
import 'package:rawae_gp24/bookmark.dart';
import 'package:rawae_gp24/profile_page.dart';
import 'package:rawae_gp24/read_book.dart';
import 'package:rawae_gp24/custom_navigation_bar.dart'; // Import your CustomNavigationBar

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2835),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/book2.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Think outside the boox',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GenreChip(label: 'Fiction'),
                SizedBox(width: 10),
                GenreChip(label: 'Fantasy'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Authors: Konrin, Reem, Sara, ...more',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              'In a world where dreams bleed into reality, searching for a key to unlock a future that never existed. Time stumbles, shadows whisper, and the sky remembers what we’ve forgotten.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReadBookPage()),
                );
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF344C64),
                      Color(0xFFD35400),
                      Color(0xFFA2DED0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Start Reading',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MakeThreadPage()),
          );
        },
        backgroundColor: const Color(0xFFD35400),
        elevation: 6,
        child: const Icon(
          Icons.add,
          size: 36,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavigationBar(selectedIndex: 3),
    );
  }
}

class GenreChip extends StatelessWidget {
  final String label;

  const GenreChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
