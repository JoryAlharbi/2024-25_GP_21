import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WritingPage extends StatefulWidget {
  final String threadId;

  const WritingPage({Key? key, required this.threadId}) : super(key: key);

  @override
  _WritingPageState createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  late final TextEditingController _textController;
  final String userId =
      FirebaseAuth.instance.currentUser!.uid; // Current User ID
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _cancelWriting() {
    FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadId)
        .update({'isWriting': false}).then((_) {
      Navigator.pop(context); // Navigate back to the thread page
    });
  }

 Future<void> _processStoryPart() async {
  final storyText = _textController.text;

  if (storyText.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cannot submit an empty part!")),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final partData = {
      'content': storyText,
      'createdAt': Timestamp.now(),
      'writerID': userId,
    };

    // Add the part to Firestore
    final partRef = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadId)
        .collection('Parts')
        .add(partData);

    // Update thread contributors and writing status
    await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadId)
        .update({
      'contributors': FieldValue.arrayUnion([
        FirebaseFirestore.instance.collection('Writer').doc(userId)
      ]),
      'isWriting': false,
    });

    // Send the story part to the API, including partId and threadId
    final response = await _sendCharactersToAPI(storyText, widget.threadId, partRef.id);
    print(response.statusCode);

    if (response.statusCode == 200) {
      // Handle the response from the server and navigate to the character page
      Navigator.pushReplacementNamed(
        context,
        '/character_page', // Make sure this route is properly set
        arguments: {
          'charName': jsonDecode(response.body)['characters'][0]['name'],
          'description': jsonDecode(response.body)['characters'][0]['description'],
          'threadId': widget.threadId,
          'partId': partRef.id,
          'storyText': storyText,
          'userId': userId,
          'publicUrl': jsonDecode(response.body)['public_url'], 
        },
      );
    } else if (response.statusCode == 404) {
      // Handle 404 response
        Navigator.pop(context);

    } else {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to process characters!")),
      );
    }
  } catch (e) {
    print('Error occurred: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to submit part")),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<http.Response> _sendCharactersToAPI(
      String storyText, String threadId, String partId) {
    const apiUrl = 'http://10.0.2.2:5000/generate-image'; // Local API URL
    return http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'story_text': storyText, // Send the full story text
        'thread_id': threadId,
        'part_id': partId,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: _cancelWriting,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD35400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Done', style: TextStyle(color: Colors.white)),
              onPressed: _isLoading ? null : _processStoryPart,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
          
            const SizedBox(height: 20),
            _buildProfileSection(),
            const SizedBox(height: 20),
            _buildTextField(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterAvatar(String name, String imagePath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.deepOrange,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Writer').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text("User not found", style: TextStyle(color: Colors.white)),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final name = userData['username'] ?? 'Unknown User';
        final username = userData['username'] ?? '@unknown';
        final profileImageUrl = userData['profileImageUrl'] ?? 'assets/default.png';

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: profileImageUrl.startsWith('http')
                    ? NetworkImage(profileImageUrl)
                    : AssetImage(profileImageUrl) as ImageProvider,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF313E4F),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'What’s happening?',
                  hintStyle: TextStyle(color: Color(0xFF9DB2CE)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Add any action buttons here if needed
        ],
      ),
    );
  }
}
