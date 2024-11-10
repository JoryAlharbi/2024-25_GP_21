import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/library.dart';
import 'package:rawae_gp24/bookmark.dart';
import 'package:rawae_gp24/profile_page.dart';
import 'package:rawae_gp24/book.dart'; // Ensure this path is correct for your existing book.dart file

import 'package:google_fonts/google_fonts.dart';
import 'package:rawae_gp24/custom_navigation_bar.dart';

class GenreLibraryPage extends StatelessWidget {
  final String genre;

  GenreLibraryPage({super.key, required this.genre});

  final List<Map<String, String>> books = [
    {'title': 'Memories of the Sea', 'image': 'assets/book.png'},
    {'title': 'Meet Mr. Mulliner', 'image': 'assets/book2.png'},
    {'title': 'P.G Wodehouse', 'image': 'assets/book.png'},
    {'title': 'P.G Wodehouse', 'image': 'assets/book2.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 112, 28, 28),
        elevation: 0,
        title: Text(
          genre,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: books.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 19.0,
            crossAxisSpacing: 22.0,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final book = books[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsPage(),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      image: DecorationImage(
                        image: AssetImage(book['image']!),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    book['title']!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
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
      bottomNavigationBar: CustomNavigationBar(selectedIndex: 1),
    );
  }
}
