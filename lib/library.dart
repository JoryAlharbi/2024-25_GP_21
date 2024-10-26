import 'package:flutter/material.dart';

class LibraryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: LibraryPage(),
    );
  }
}

class LibraryPage extends StatelessWidget {
  final List<Map<String, dynamic>> genres = [
    {'name': 'Fantasy', 'image': 'assets/images/fantasy.png'},
    {'name': 'Drama', 'image': 'assets/images/drama.png'},
    {'name': 'Romance', 'image': 'assets/images/romance.png'},
    {'name': 'Comedy', 'image': 'assets/images/comedy.png'},
    {'name': 'Crime Fiction', 'image': 'assets/images/crime_fiction.png'},
    {'name': 'Adventure', 'image': 'assets/images/adventure.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        ],
        backgroundColor: Color(0xFF1E2834),
      ),
      body: Stack(
        children: [
          // Background color
          Container(
            color: Color(0xFF1B2835),
          ),

          // Ellipses for decoration
          Positioned(
            top: -130,
            left: -174,
            child: Container(
              width: 397,
              height: 397,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFD35400).withOpacity(0.26),
                    Color(0xFFA2DED0).withOpacity(0.0),
                  ],
                  stops: [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),

          Positioned(
            top: 61,
            right: -160,
            child: Container(
              width: 397,
              height: 397,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF344C64).withOpacity(0.58),
                    Color(0xFFD35400).withOpacity(0.0),
                  ],
                  stops: [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -160,
            left: 100,
            child: Container(
              width: 397,
              height: 397,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFA2DED0).withOpacity(0.2),
                    Color(0xFFD35400).withOpacity(0.0),
                  ],
                  stops: [0.0, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return Container(
                  decoration: BoxDecoration(
                    color: genre['color'],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Use Image.asset to display your image
                        Image.asset(
                          genre['image'],
                          width: 40, // Set the width to your desired size
                          height: 40, // Set the height to your desired size
                          fit: BoxFit.cover, // Maintain the aspect ratio
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          genre['name'],
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MakeThreadPage()),
            );
          },
          backgroundColor: Color(0xFFD35400),
          child: Icon(
            Icons.add,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Color(0xFF1E2834),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home_rounded),
                color: Color(0xFFA2DED0),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.library_books_rounded),
                color: Color(0xFF9DB2CE),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LibraryPage()),
                  );
                },
              ),
              SizedBox(width: 40), // Space for the FAB
              IconButton(
                icon: Icon(Icons.bookmark),
                color: Color(0xFF9DB2CE),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BookmarkPage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.person),
                color: Color(0xFF9DB2CE),
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
      ),
    );
  }
}

// Placeholder pages for navigation
class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Center(child: Text('Search Page')),
    );
  }
}

class MakeThreadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Make a Thread')),
      body: Center(child: Text('Make Thread Page')),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(child: Text('Home Page')),
    );
  }
}

class BookmarkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookmarks')),
      body: Center(child: Text('Bookmark Page')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(child: Text('Profile Page')),
    );
  }
}
