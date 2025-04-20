import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawae_gp24/PublishThread.dart';
import 'package:rawae_gp24/homepage.dart';
import 'writing.dart'; // Make sure to import your writing.dart file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; //for the norifications!!
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rawae_gp24/notification_service.dart'; // Ensure this is the correct path
import 'package:flutter/material.dart';

class StoryView extends StatefulWidget {
  final String threadId;

  StoryView({super.key, required this.threadId, required String userId});

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  late final String userId;
  bool isBellClicked = false;
  late NotificationService
      notificationService; // Declare the notificationService variable

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    notificationService =
        NotificationService(); // Initialize the notificationService
    notificationService.connectToThread(
        widget.threadId); // Connect to the thread via WebSocket

    // Increment the total view count when someone opens the thread
    _incrementViewCount();
  }

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
        sendWebSocketNotification();
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

  // Function to send WebSocket notification
  Future<void> sendWebSocketNotification() async {
    try {
      await FirebaseFirestore.instance
          .collection('Thread')
          .doc(widget.threadId)
          .get()
          .then((doc) {
        List<String> bellClickers = List.from(doc['bellClickers'] ?? []);
        // Notify each user who has clicked the bell via WebSocket
        for (String userId in bellClickers) {
          notificationService.sendNotificationToUser(userId);
        }
      });
    } catch (e) {
      print("Error sending WebSocket notification: $e");
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
  void dispose() {
    notificationService
        .disconnect(); // Disconnect WebSocket when the page is disposed
    super.dispose();
  }

  void onEndThread(BuildContext context, String writerId) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    if (writerId == currentUserId) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          // Use dialogContext to avoid issues
          return AlertDialog(
            title: Text('End Thread'),
            content:
                Text('Are you sure you want to end and publish this thread?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop(); // Close the dialog safely
                  print("🟡 Updating Firestore to add description...");

                  try {
                    await FirebaseFirestore.instance
                        .collection('Thread')
                        .doc(widget.threadId)
                        .set({
                      'description': 'No summary yet',
                    }, SetOptions(merge: true));

                    print("✅ Firestore update successful!");

                    // ✅ Delay navigation slightly to ensure the widget tree is stable
                    Future.delayed(Duration.zero, () {
                      if (mounted) {
                        print("🚀 Navigating to PublishThreadPage...");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PublishThreadPage(threadID: widget.threadId),
                          ),
                        );
                      } else {
                        print(
                            "❌ Navigation skipped because widget is unmounted.");
                      }
                    });
                  } catch (e) {
                    print("❌ Firestore update failed: $e");
                  }
                },
                child: Text('Confirm'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("You do not have permission to end this thread.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2835),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF9DB2CE)),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          },
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
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Writers ',
                style: TextStyle(
                  fontSize: 18,

                  color: Color.fromARGB(228, 255, 255, 255),
                  // Adjust the text color as needed
                ),
              ),
            ),
            const SizedBox(
                height: 10), // Space between the title and the avatar section

            // Horizontal Scroll for Avatars
            SizedBox(
              height: 100,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Thread')
                    .doc(widget.threadId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final threadData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final contributors = List<DocumentReference>.from(
                        threadData['contributors'] ?? []);

                    // Fetch contributor details based on references
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: Future.wait(
                        contributors
                            .map((ref) => ref.get().then((contributorSnapshot) {
                                  if (contributorSnapshot.exists) {
                                    final contributorData = contributorSnapshot
                                        .data() as Map<String, dynamic>;
                                    return {
                                      'name':
                                          contributorData['name'] ?? 'Unknown',
                                      'profileImageUrl':
                                          contributorData['profileImageUrl'] ??
                                              'assets/default.png',
                                    };
                                  } else {
                                    return {
                                      'name': 'Unknown',
                                      'profileImageUrl': 'assets/default.png',
                                    };
                                  }
                                }))
                            .toList(),
                      ),
                      builder: (context, contributorSnapshot) {
                        if (contributorSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (contributorSnapshot.hasData) {
                          final contributorsDetails = contributorSnapshot.data!;

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: contributorsDetails.length,
                            itemBuilder: (context, index) {
                              final contributor = contributorsDetails[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Avatar with blue circular border

                                    Container(
                                      width:
                                          70, // Slightly bigger container for the border
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Color(0xFFA2DED0),
                                            width: 4), // Blue border
                                      ),
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundImage: contributor[
                                                    'profileImageUrl']
                                                .startsWith('assets/')
                                            ? AssetImage(contributor[
                                                'profileImageUrl']) // Load from assets
                                            : NetworkImage(contributor[
                                                    'profileImageUrl'])
                                                as ImageProvider, // Load from network
                                        backgroundColor: Colors.grey.shade300,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Name text in white
                                    Text(
                                      contributor['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors
                                            .white, // Text color changed to white
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        return const Center(
                            child: Text('No contributors found.'));
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
                    final partsDocs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: partsDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            partsDocs[index].data() as Map<String, dynamic>;
                        final writerId = data['writerID'] ?? '';

                        // Useing FutureBuilder to fetch writer details

                        return FutureBuilder<Map<String, String>>(
                          future: getWriterDetails(writerId),
                          builder: (context, writerSnapshot) {
                            if (writerSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildTimelineItem(
                                TimelineItem(
                                  name: 'Loading...',
                                  username: '@loading',
                                  content: data['content'] ?? '',
                                  timeAgo: _calculateTimeAgo(data['createdAt']),
                                  avatarPath: 'assets/default.png',
                                  avatarName: 'Loading',
                                ),
                                index == partsDocs.length - 1,
                                context,
                              );
                            }

                            if (writerSnapshot.hasData) {
                              final writerDetails = writerSnapshot.data!;
                              final characterId = data['characterId'];

                              // Check for missing or empty characterId
                              if (characterId == null || characterId.isEmpty) {
                                // No characterId found, fallback to default avatar
                                return _buildTimelineItem(
                                  TimelineItem(
                                    name: writerDetails['name']!,
                                    username: '',
                                    content: data['content'] ?? '',
                                    timeAgo:
                                        _calculateTimeAgo(data['createdAt']),
                                    avatarPath: 'assets/default.png',
                                    avatarName: writerDetails['name']!,
                                  ),
                                  index == partsDocs.length - 1,
                                  context,
                                );
                              }

                              String avatarPath = data['url'] ??
                                  'assets/default.png'; // Fallback to default if avatarPath is not available

                              return FutureBuilder<String>(
                                future: getCharacterName(
                                    characterId), // The async function to get character name
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    // While waiting for the data
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    // If there is an error fetching the data
                                    return _buildTimelineItem(
                                      TimelineItem(
                                        name: 'Error',
                                        username: '@error',
                                        content: data['content'] ?? '',
                                        timeAgo: _calculateTimeAgo(
                                            data['createdAt']),
                                        avatarPath: 'assets/default.png',
                                        avatarName: 'Error',
                                      ),
                                      index == partsDocs.length - 1,
                                      context,
                                    );
                                  } else if (snapshot.hasData) {
                                    // Once the data is fetched, build the timeline item
                                    String name = snapshot.data ??
                                        'mysterious'; // Fallback name if none is returned

                                    return _buildTimelineItem(
                                      TimelineItem(
                                        name: writerDetails['name']!,
                                        username: '',
                                        content: data['content'] ?? '',
                                        timeAgo: _calculateTimeAgo(
                                            data['createdAt']),
                                        avatarPath:
                                            avatarPath, // Use the avatarPath from data
                                        avatarName:
                                            name, // Use the fetched name
                                      ),
                                      index == partsDocs.length - 1,
                                      context,
                                    );
                                  } else {
                                    // Handle case where data is null
                                    return _buildTimelineItem(
                                      TimelineItem(
                                        name: 'No Name',
                                        username: '@unknown',
                                        content: data['content'] ?? '',
                                        timeAgo: _calculateTimeAgo(
                                            data['createdAt']),
                                        avatarPath: 'assets/default.png',
                                        avatarName: 'Unknown',
                                      ),
                                      index == partsDocs.length - 1,
                                      context,
                                    );
                                  }
                                },
                              );
                            }

                            // Handle error or fallback
                            return _buildTimelineItem(
                              TimelineItem(
                                name: 'Error',
                                username: '@error',
                                content: data['content'] ?? '',
                                timeAgo: _calculateTimeAgo(data['createdAt']),
                                avatarPath: 'assets/default.png',
                                avatarName: 'Error',
                              ),
                              index == partsDocs.length - 1,
                              context,
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onWritingBoxClick(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF2A3B4D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: StreamBuilder<DocumentSnapshot>(
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
                                        ? 'Someone is writing...'
                                        : 'What happens next?',
                                    style: TextStyle(color: Color(0xFF9DB2CE)),
                                  );
                                }
                                return Text('What happens next...',
                                    style: TextStyle(color: Color(0xFF9DB2CE)));
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Thread')
                        .doc(widget.threadId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.data() != null) {
                        DocumentReference writerRef =
                            snapshot.data!['writerID'];
                        return FutureBuilder<DocumentSnapshot>(
                          future: writerRef.get(),
                          builder: (context, writerSnapshot) {
                            if (writerSnapshot.hasData) {
                              String writerId = writerSnapshot.data!.id;
                              bool isCreator = writerId ==
                                  FirebaseAuth.instance.currentUser!.uid;
                              if (isCreator) {
                                return SizedBox(
                                  width: 74,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        onEndThread(context, writerId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 235, 32, 18),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'End',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                            return SizedBox
                                .shrink(); // Ensures no extra space if not the creator
                          },
                        );
                      }
                      return SizedBox
                          .shrink(); // Ensures no extra space if data isn't available
                    },
                  ),
                ],
              ),
            )
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

  Future<String> getCharacterName(String characterId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Character')
          .where('characterId', isEqualTo: characterId) // Filter by characterId
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there's only one matching document
        final characterDoc = querySnapshot.docs.first;
        print("Document found for characterId: $characterId " +
            characterDoc['CharacterName']);
        return characterDoc['CharacterName'] ??
            ' mysterious'; // Return URL or default
      } else {
        print("No character document found for characterId: $characterId");
      }
    } catch (e) {
      print("Error fetching character avatar: $e");
    }
    return 'mysterious'; // Fallback avatar if document is not found or an error occurs
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

  Future<Map<String, String>> getWriterDetails(String writerId) async {
    try {
      print("Fetching details for writerId: $writerId");
      final writerDoc = await FirebaseFirestore.instance
          .collection('Writer')
          .doc(writerId)
          .get();

      if (writerDoc.exists) {
        final data = writerDoc.data() as Map<String, dynamic>;
        print("Writer data found: $data"); // Debugging
        return {
          'name': data['name'] ?? 'Unknown Writer',
          'username': data['username'] ?? '@unknown',
        };
      } else {
        print("No writer document found for writerId: $writerId");
      }
    } catch (e) {
      print("Error fetching writer details for $writerId: $e");
    }
    return {
      'name': 'Unknown Writer',
      'username': '@unknown',
    };
  }
}

class TimelineItem {
  final String name;
  final String username;
  final String content;
  final String timeAgo;
  final String avatarPath;
  final String avatarName;
  final String? characterId;
  String? reaction; // Nullable field for storing reaction

  TimelineItem({
    required this.name,
    required this.username,
    required this.content,
    required this.timeAgo,
    required this.avatarPath,
    required this.avatarName,
    this.characterId,
    this.reaction, // Optional at first
  });
}

Widget _buildTimelineItem(
    TimelineItem item, bool isLastItem, BuildContext context) {
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
                  backgroundImage: item.avatarPath.startsWith('http') ||
                          item.avatarPath.startsWith('https')
                      ? NetworkImage(item.avatarPath)
                      : AssetImage(item.avatarPath) as ImageProvider,
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
              height: (item.content.length * 0.87 < 90)
                  ? 100
                  : item.content.length * 0.87,
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
            if (item.reaction != null) // Show reaction if available
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Reaction: ${item.reaction}',
                  style: const TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    _showReactionDialog(context, item);
                  },
                  child: const Icon(
                    Icons.add_reaction_outlined,
                    color: Color(0xFFA2DED0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

void _showReactionDialog(BuildContext context, TimelineItem item) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(101, 118, 143, 144),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _reactionButton(context, item, '👍'),
            _reactionButton(context, item, '❤️'),
            _reactionButton(context, item, '😂'),
            _reactionButton(context, item, '😲'),
            _reactionButton(context, item, '😢'),
            _reactionButton(context, item, '🙏'),
          ],
        ),
      );
    },
  );
}

Widget _reactionButton(BuildContext context, TimelineItem item, String emoji) {
  return GestureDetector(
    onTap: () {
      Navigator.pop(context); // Close dialog
      item.reaction = emoji; // Update the item's reaction
      (context as Element).markNeedsBuild(); // Force UI update
    },
    child: Text(emoji, style: const TextStyle(fontSize: 24)),
  );
}
