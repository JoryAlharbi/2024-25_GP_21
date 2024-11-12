import 'package:flutter/material.dart';
import 'character_page.dart'; // Adjust the path to your character_page.dart file

class WritingPage extends StatefulWidget {
  const WritingPage({super.key});

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

  // Method to insert tags into the text field
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

  // Method to process the story part
  void _processStoryPart() {
    final text = _textController.text;

    // Example logic for processing the text
    if (text.contains('##Character##')) {
      print("Character tag detected in the story part.");
    }

    // Further processing can go here, e.g., saving or navigating back
    Navigator.pop(context, text); // Sends the text back to the previous screen
  }
  //////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.grey,
          ),
          onPressed: () => Navigator.pop(context),
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
              onPressed: () {
                // When "Done" is pressed, extract character descriptions
                _processStoryPart();
              },
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/profile2.png'),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
