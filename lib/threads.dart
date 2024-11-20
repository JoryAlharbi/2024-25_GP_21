import 'package:flutter/material.dart';
import 'writing.dart'; // Make sure to import your writing.dart file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; //for the norifications!!
import 'package:firebase_auth/firebase_auth.dart';

class StoryView extends StatefulWidget {
  final String threadId;

  StoryView({super.key, required this.threadId, required String userId});

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  late final String userId;
  bool isBellClicked = false;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;

    // Increment the total view count when someone opens the thread
    _incrementViewCount();
  }

// these methods to handel the user when someone is writing
// there was also another method but it was a simplier one with no notification handeling
//this has everything so its comperhensive

  void onBellClick() async {
    // First, update the bellClickers array in Firestore
    if (!isBellClicked) {
      await FirebaseFirestore.instance
          .collection('Thread')
          .doc(widget.threadId)
          .update({
        'bellClickers': FieldValue.arrayUnion([userId]),
      });

      // Check if no one is currently writing
      DocumentSnapshot threadSnapshot = await FirebaseFirestore.instance
          .collection('Thread')
          .doc(widget.threadId)
          .get();
      bool isWriting = threadSnapshot['isWriting'] ?? false;

      // If no one is writing, send a push notification
      if (!isWriting) {
        sendPushNotification();
      }
    } else {
      // Remove the user from bellClickers array
      await FirebaseFirestore.instance
          .collection('Thread')
          .doc(widget.threadId)
          .update({
        'bellClickers': FieldValue.arrayRemove([userId]),
      });
    }

    // Update the UI by toggling the bell click state
    setState(() {
      isBellClicked = !isBellClicked;
    });
  }

// Function to send push notification
//there are two functions that sends the notifications , they work together.
  Future<void> sendPushNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Here you can send a notification to a topic or specific user.
    // For simplicity, let's assume you send it to all users following this thread.

    try {
      await FirebaseFirestore.instance
          .collection('Thread')
          .doc(widget.threadId)
          .get()
          .then((doc) {
        List<String> bellClickers = List.from(doc['bellClickers'] ?? []);
        // Notify each user who has clicked the bell
        for (String userId in bellClickers) {
          sendNotificationToUser(userId);
        }
      });
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

// Function to send notification to a specific user using their Firebase token
// the token should be added when the user signup or signin
//the token is added in the main page!!!
//each user has a unique token so this method sends the notification to their token.

  Future<void> sendNotificationToUser(String userId) async {
    // Fetch the user's device token from Firestore
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    String? deviceToken = userSnapshot['deviceToken'];

    if (deviceToken != null) {
      try {
        // Send a notification using FirebaseMessaging
        await FirebaseMessaging.instance.sendMessage(
          to: deviceToken,
          data: {
            'title': 'No one is writing!',
            'body': 'Click here to join the story writing session.',
          },
        );
        print("Notification sent to $userId");
      } catch (e) {
        print("Failed to send notification: $e");
      }
    }
  }

  //////////////////////////////

  void _incrementViewCount() {
    FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadId)
        .update({
      'totalView': FieldValue.increment(1), // Increment the view count by 1
    }).catchError((e) {
      print("Error incrementing view count: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2835),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF9DB2CE),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Thread')
              .doc(widget.threadId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final threadData = snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                threadData['title'] ?? 'Story',
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
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Thread')
                .doc(widget.threadId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final threadData =
                    snapshot.data!.data() as Map<String, dynamic>;
                isBellClicked =
                    (threadData['bellClickers'] as List).contains(userId);
              }

              return IconButton(
                icon: Icon(
                  isBellClicked
                      ? Icons.notifications // Filled bell when clicked
                      : Icons
                          .notifications_outlined, // Outline when not clicked
                  color: isBellClicked
                      ? const Color(0xFFD35400)
                      : const Color(0xFFD35400), // Color change
                  size: 40,
                ),
                onPressed: () => onBellClick(),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1B2835),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Horizontal Scroll for Avatars
            SizedBox(
              height: 100,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Thread')
                    .doc(widget.threadId)
                    .collection('Parts')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final timelineItems = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return TimelineItem(
                        name: data['name'] ?? 'Unknown',
                        username: data['username'] ?? '@unknown',
                        content: data['content'] ?? '',
                        timeAgo: _calculateTimeAgo(data['createdAt']),
                        avatarPath: data['avatarPath'] ?? 'assets/default.png',
                        avatarName: data['avatarName'] ?? 'User',
                      );
                    }).toList();

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: timelineItems.length,
                      itemBuilder: (context, index) {
                        return _buildStoryAvatar(timelineItems[index]);
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const Divider(
              thickness: 1,
              color: Color(0xFF344C64),
              height: 20,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Thread')
                    .doc(widget.threadId)
                    .collection('Parts')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final timelineItems = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return TimelineItem(
                        name: data['name'] ?? 'Unknown',
                        username: data['username'] ?? '@unknown',
                        content: data['content'] ?? '',
                        timeAgo: _calculateTimeAgo(data['createdAt']),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => onWritingBoxClick(context),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 42, 60, 76),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: Color(0xFF9DB2CE),
                          ),
                          SizedBox(width: 8),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Thread')
                                .doc(widget.threadId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                bool isWriting =
                                    snapshot.data!['isWriting'] ?? false;
                                return Text(
                                  isWriting
                                      ? 'Someone is writing... !!'
                                      : 'What happens next?',
                                  style: TextStyle(color: Color(0xFF9DB2CE)),
                                );
                              }
                              return const Text(
                                'What happens next...',
                                style: TextStyle(color: Color(0xFF9DB2CE)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onWritingBoxClick(BuildContext context) async {
    DocumentSnapshot threadSnapshot = await FirebaseFirestore.instance
        .collection('Thread')
        .doc(widget.threadId)
        .get();

    if (!(threadSnapshot['isWriting'] ?? false)) {
      FirebaseFirestore.instance
          .collection('Thread')
          .doc(widget.threadId)
          .update({
        'isWriting': true,
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WritingPage(threadId: widget.threadId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Someone is currently writing. Please wait.")),
      );
    }
  }

  String _calculateTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildStoryAvatar(TimelineItem item) {
    return Container(
      width: 90,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFD35400), width: 2),
            ),
            child: CircleAvatar(
              radius: 37,
              backgroundImage: AssetImage(item.avatarPath),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 60),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: Color(0xFFD35400),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              item.avatarName,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
              width: 4,
              height: 90,
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
                Text(
                  item.timeAgo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                item.content,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight, // Align to the right
                child: IconButton(
                  icon: const Icon(Icons.add_reaction_outlined,
                      color: Color(0xFFA2DED0)),
                  onPressed: () {
                    print('Reacted to: ${item.name}');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
