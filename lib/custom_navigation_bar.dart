// custom_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:rawae_gp24/bookmark.dart';
import 'package:rawae_gp24/library.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:rawae_gp24/profile_page.dart';
import 'package:rawae_gp24/homepage.dart'; // Import other pages as needed

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  CustomNavigationBar({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFF2A3A4A), // Dark background for the BottomAppBar
      shape: CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Color(0xFF1E2834), // Explicitly set a dark color
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                size: 28,
                Icons.home_rounded,
                color:
                    selectedIndex == 0 ? Color(0xFFA2DED0) : Color(0xFF9DB2CE),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                size: 27,
                Icons.library_books_rounded,
                color:
                    selectedIndex == 1 ? Color(0xFFA2DED0) : Color(0xFF9DB2CE),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LibraryPage()),
                );
              },
            ),
            SizedBox(width: 40), // Space for FloatingActionButton
            IconButton(
              icon: Icon(
                size: 27,
                Icons.bookmark_rounded,
                color:
                    selectedIndex == 2 ? Color(0xFFA2DED0) : Color(0xFF9DB2CE),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BookmarkPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                size: 30,
                Icons.person_rounded,
                color:
                    selectedIndex == 3 ? Color(0xFFA2DED0) : Color(0xFF9DB2CE),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
