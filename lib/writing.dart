import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFF1B2835), // Background color from the screenshot
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.deepOrange),
            ),
            onPressed: () {
              // Add any action you want when "Done" is pressed
              print(_textController.text); // Example action
            },
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
          _buildActionButtons(), // Added action buttons below the text field
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
            backgroundImage: AssetImage('assets/profile.png'),
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
        padding: const EdgeInsets.symmetric(vertical: 12.0), // Add vertical padding
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
            border: InputBorder.none, // Remove the default border
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            icon: const Icon(Icons.auto_fix_high , color:  Color(0xFFA2DED0)),
            onPressed: () {
              // Add action for the undo button
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined , color: Color(0xFFA2DED0)),
            onPressed: () {
              // Add action for the auto-format button
            },
          )
        ],
      ),
    );
  }
}
