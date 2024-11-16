import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    // Set `isWriting` back to false in Firestore
    FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadId)
        .update({
      'isWriting': false,
    }).then((_) {
      Navigator.pop(context); // Navigate back to the thread page
    });
  }

  void _processStoryPart() {
    final storyText = _textController.text;

    if (storyText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot submit an empty part!")),
      );
      return;
    }

    // Submit the part and update the `contributors` array with the reference to the user document
    FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadId)
        .collection('Parts')
        .add({
      'content': storyText,
      'createdAt': Timestamp.now(),
      'writerID': FirebaseAuth.instance.currentUser!.uid, // Use actual user ID
    }).then((_) {
      // Add the reference to the `contributors` array in the thread document
      FirebaseFirestore.instance
          .collection('Thread')
          .doc(widget.threadId)
          .update({
        'contributors': FieldValue.arrayUnion([
          FirebaseFirestore.instance
              .collection('Writer')
              .doc(FirebaseAuth.instance.currentUser!.uid)
        ]), // Add reference to contributors
      });

      FirebaseFirestore.instance
          .collection('Thread')
          .doc(widget.threadId)
          .update({
        'isWriting': false,
      });
      Navigator.pop(context);
    });
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
          onPressed: _cancelWriting, // Cancel writing and reset the flag
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
              child: const Text('Done', style: TextStyle(color: Colors.white)),
              onPressed: _processStoryPart, // Submit the writing part
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildCharacterAvatar('Evelyn', 'assets/h.png'),
                _buildCharacterAvatar('Lucy', 'assets/cat.png'),
                _buildCharacterAvatar('Oliver', 'assets/catm.png'),
                _buildCharacterAvatar('Lucas', 'assets/hunter.png'),
              ],
            ),
            const SizedBox(height: 20),
            _buildProfileSection(),
            const SizedBox(height: 20),
            _buildTextField(),
            const SizedBox(height: 10),
            _buildActionButtons(), // Include action buttons
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
      future: FirebaseFirestore.instance
          .collection('Writer') // Collection name based on screenshot
          .doc(userId) // Use current user ID
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text(
              "User not found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final name = userData['name'] ?? 'Unknown User';
        final username = userData['username'] ?? '@unknown';
        final profileImageUrl = userData['profileImageUrl'] ??
            'assets/default.png'; // Fallback to default image if not available

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: profileImageUrl.startsWith('http')
                    ? NetworkImage(profileImageUrl) // Load image from URL
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
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
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
            IconButton(
              icon: const Icon(Icons.person_add, color: Color(0xFF9DB2CE)),
              onPressed: _insertCharacterTag, // Insert the character tag
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
          IconButton(
            icon: const Icon(Icons.auto_fix_high, color: Color(0xFFA2DED0)),
            onPressed: () {
              // Functionality for undoing changes
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined,
                color: Color(0xFFA2DED0)),
            onPressed: () {
              // Functionality for enhancing or formatting text
            },
          ),
        ],
      ),
    );
  }

  void _insertCharacterTag() {
    final cursorPos = _textController.selection.base.offset;
    final text = _textController.text;

    // Insert the tag where the cursor is
    final newText = text.substring(0, cursorPos) +
        '##Character##' +
        text.substring(cursorPos);

    // Update the text in the field and position the cursor after the tag
    _textController.text = newText;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(
          offset: cursorPos + 12), // Move cursor after the inserted tag
    );
  }
}
