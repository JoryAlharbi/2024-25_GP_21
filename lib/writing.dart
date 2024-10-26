import 'package:flutter/material.dart';
import 'character_page.dart'; // Adjust the path to your character_page.dart file

class WritingPage extends StatefulWidget {
  const WritingPage({Key? key}) : super(key: key);

  @override
  _WritingPageState createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  late final TextEditingController _textController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close, // X icon
            color: Colors.grey, // Grey color for the icon
          ),
          onPressed: () => Navigator.pop(context), // Close the page
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
              child: const Text(
                'Done',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                // Navigate to character_page.dart when "Done" is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacterPreviewPage(
                      userName: 'hailey',
                    ),
                  ), // Adjust if needed
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
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
          _buildActionButtons(),
        ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assetimport 'dart:developer' as developer;

// ...

class _WritingPageState extends State<WritingPage> {
  // ...

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    developer.log('Text controller initialized');
  }

  @override
  void dispose() {
    _textController.dispose();
    developer.log('Text controller disposed');
    super.dispose();
  }

  // ...

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high, color: Color(0xFFA2DED0)),
            onPressed: () {
              developer.log('Undo button pressed');
              // Add action for the undo button
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined,
                color: Color(0xFFA2DED0)),
            onPressed: () {
              developer.log('Auto-format button pressed');
              // Add action for the auto-format button
            },
          ),
        ],
      ),
    );
  }

  // ...

  ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFD35400),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    child: const Text(
      'Done',
      style: TextStyle(color: Colors.white),
    ),
    onPressed: () {
      developer.log('Done button pressed');
      // Navigate to character_page.dart when "Done" is pressed
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CharacterPreviewPage(
            userName: 'hailey',
          ),
        ), // Adjust if needed
      );
    },
  ),
}s/profile2.png'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Rudy Fernandez',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '@andresfrans',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _textController,
          maxLines: null, // Allows the text field to expand vertically
          decoration: InputDecoration(
            hintText: 'What’s happening?',
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
          style: const TextStyle(color: Colors.white),
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
              // Add action for the undo button
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined,
                color: Color(0xFFA2DED0)),
            onPressed: () {
              // Add action for the auto-format button
            },
          ),
        ],
      ),
    );
  }
}
