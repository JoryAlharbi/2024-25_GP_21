import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory =
      []; // Dynamic search history (resets on restart)
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  /// Performs search when user clicks the search icon
  void _performSearch() {
    String searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
    });

    FirebaseFirestore.instance
        .collection('Thread')
        .where('title', isEqualTo: searchTerm)
        .where('status', isEqualTo: 'in_progress')
        .get()
        .then((querySnapshot) {
      setState(() {
        _searchResults = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _isSearching = false;
      });

      // Add search term to history only if results were found
      if (_searchResults.isNotEmpty && !_searchHistory.contains(searchTerm)) {
        _searchHistory.insert(
            0, searchTerm); // Insert at the top for latest search first
      }
    }).catchError((error) {
      print("Error fetching data: $error");
    });
  }

  /// Clears search history
  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          decoration: InputDecoration(
            hintText: "Search All Books",
            hintStyle: TextStyle(color: Colors.white60, fontFamily: 'Poppins'),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.search, color: Colors.white60),
              onPressed: _performSearch, // Search when clicked
            ),
          ),
          cursorColor: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF9DB2CE)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete,
                color: Colors.redAccent), // Clear history button
            onPressed: _clearSearchHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(color: Colors.grey[800]),

          /// **RECENT SEARCHES SECTION**
          if (!_isSearching && _searchHistory.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent",
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      fontFamily: 'Poppins'),
                ),
              ),
            ),

          /// **SEARCH RESULTS OR HISTORY LIST**
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildSearchHistory(),
          ),
        ],
      ),
    );
  }

  /// Displays search results
  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? Center(
            child: Text("No results found",
                style: TextStyle(color: Colors.white60, fontFamily: 'Poppins')),
          )
        : ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  _searchResults[index]['title'],
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                ),
                onTap: () {
                  _searchController.text = _searchResults[index]['title'];
                  _performSearch(); // Search again when tapping on result
                },
              );
            },
          );
  }

  /// Displays search history
  Widget _buildSearchHistory() {
    return ListView.builder(
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            _searchHistory[index],
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
          onTap: () {
            _searchController.text = _searchHistory[index];
            _performSearch();
          },
        );
      },
    );
  }
}
