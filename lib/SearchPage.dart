import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/threads.dart';
import 'package:rawae_gp24/book.dart'; // For published books
import 'package:rawae_gp24/threads.dart'; // For in-progress threads

class SearchPage extends StatefulWidget {
  final String status; // "in_progress" or "published"

  const SearchPage({super.key, required this.status});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  void _performSearch() async {
    String searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Thread')
          .where('status', isEqualTo: widget.status)
          .where('title', isEqualTo: searchTerm)
          .get();

      final results = querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print("Error during search: $e");
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<String> _getGenreNames(List<dynamic> genreRefs) async {
    List<String> genreNames = [];
    for (var ref in genreRefs) {
      if (ref is DocumentReference) {
        final doc = await ref.get();
        if (doc.exists) {
          genreNames.add(doc['genreName'] ?? 'Unknown');
        }
      }
    }
    return genreNames.join(', ');
  }

  Future<List<String>> _getContributors(String threadId) async {
    final doc = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(threadId)
        .get();
    final refs = doc['contributors'] ?? [];

    List<String> urls = [];
    for (var ref in refs) {
      if (ref is DocumentReference) {
        final userDoc = await ref.get();
        if (userDoc.exists) {
          urls.add(userDoc['profileImageUrl'] ?? '');
        }
      }
    }
    return urls;
  }

  void _goToThread(String threadId, String userId) {
    print("Navigating to ${widget.status}");

    final normalizedStatus = widget.status.toLowerCase();

    if (normalizedStatus == "in_progress") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryView(threadId: threadId, userId: userId),
        ),
      );
    } else if (normalizedStatus == "published") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailsPage(threadID: threadId),
        ),
      );
    } else {
      print("❌ Unknown status: ${widget.status}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          decoration: InputDecoration(
            hintText: widget.status == "Published"
                ? "Search Books"
                : "Search Threads",
            hintStyle:
                const TextStyle(color: Colors.white60, fontFamily: 'Poppins'),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white60),
              onPressed: _performSearch,
            ),
          ),
          cursorColor: Colors.white,
          onSubmitted: (_) => _performSearch(),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF9DB2CE)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Divider(color: Colors.grey[800]),
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD35400)),
                  )
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) return const SizedBox(); // Show nothing before search

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          "No thread found",
          style: TextStyle(
            color: Colors.white60,
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final threadId = result['id'];
        final title = result['title'] ?? 'Untitled';
        final bookCoverUrl = result['bookCoverUrl'];
        final genreRefs = result['genreID'] ?? [];
        final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

        return FutureBuilder<String>(
          future: _getGenreNames(genreRefs),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return GestureDetector(
              onTap: () => _goToThread(threadId, userId),
              child: BookListItem(
                title: title,
                genre: snapshot.data!,
                isPopular: false,
                bookCoverUrl: bookCoverUrl,
                threadId: threadId,
                userId: userId,
                getContributors: _getContributors,
              ),
            );
          },
        );
      },
    );
  }
}
