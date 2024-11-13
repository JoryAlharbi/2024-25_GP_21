import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'writing.dart'; // Ensure that writing.dart is correctly set up

class StoryView extends StatelessWidget {
  final String threadId; // Thread ID to fetch specific thread data

  StoryView({super.key, required this.threadId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2835),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF9DB2CE),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // Displaying the thread title from Firestore
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Thread')
              .doc(threadId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final threadData = snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                threadData['title'] ?? 'Story', // Display the thread title
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }
            return const Text('Loading...');
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications_outlined,
                color: Color(0xFFD35400), size: 40),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1B2835),
      body: Column(
        children: [
          const Divider(
            thickness: 1,
            color: Color(0xFF344C64),
            height: 20,
          ),
          const SizedBox(height: 16),
          // Display timeline items (contributions) from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Thread')
                  .doc(threadId)
                  .collection(
                      'Parts') // Assuming parts are saved in a subcollection
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final timelineItems = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return TimelineItem(
                      name: data['name'] ?? 'Unknown',
                      username: data['username'] ?? '@unknown',
                      content: data['content'] ?? '',
                      timeAgo: data['timeAgo'] ?? 'just now',
                      avatarPath: data['avatarPath'] ?? 'assets/default.png',
                      avatarName: data['avatarName'] ?? 'User',
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: timelineItems.length,
                    itemBuilder: (context, index) => _buildTimelineItem(
                      timelineItems[index],
                      index == timelineItems.length - 1,
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          // Button or prompt to contribute
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WritingPage(
                        threadId: threadId), // Pass threadId to WritingPage
                  ),
                );
              },
              child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 42, 60, 76),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons
                                .edit_rounded, // Use Icons.push_pin for a pin icon
                            color: Color(0xFF9DB2CE),
                          ),
                          const SizedBox(
                              width: 8), // Spacing between the icon and text
                          const Text(
                            'What happens next?...',
                            style: TextStyle(color: Color(0xFF9DB2CE)),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryAvatar(TimelineItem item) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD35400), width: 2),
            ),
            child: CircleAvatar(
              radius: 37,
              backgroundImage: AssetImage(item.avatarPath),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFD35400),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              item.avatarName,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TimelineItem item, bool isLastItem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 4,
                      color: const Color(0xFFD35400),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(item.avatarPath),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD35400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.avatarName,
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
              ],
            ),
            if (!isLastItem)
              Container(
                width: 5,
                height: 40,
                color: const Color(0xFFD35400),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        item.username,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        item.timeAgo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_reaction_outlined,
                            color: Color(0xFFA2DED0)),
                        onPressed: () {
                          print('Reacted to: ${item.name}');
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                item.content,
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TimelineItem {
  final String name;
  final String username;
  final String content;
  final String timeAgo;
  final String avatarPath;
  final String avatarName;

  TimelineItem({
    required this.name,
    required this.username,
    required this.content,
    required this.timeAgo,
    required this.avatarPath,
    required this.avatarName,
  });
}
