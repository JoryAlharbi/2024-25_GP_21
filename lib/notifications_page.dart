import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'threads.dart'; // For StoryView

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Thread')
        .where('status', isEqualTo: 'in_progress')
        .snapshots()
        .first;

    final filtered = snapshot.docs.where((doc) {
      final data = doc.data();
      final List<dynamic> bellClickers = data['bellClickers'] ?? [];
      return bellClickers.contains(userId);
    }).map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();

    setState(() {
      notifications = filtered;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2835),
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF9DB2CE)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Thread')
            .where('status', isEqualTo: 'in_progress')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No active threads',
                  style: TextStyle(color: Colors.white54)),
            );
          }

          final threads = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final List<dynamic> bellClickers = data['bellClickers'] ?? [];
            return bellClickers.contains(userId);
          }).toList();

          if (threads.isEmpty) {
            return const Center(
              child: Text('No active threads you followed',
                  style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: threads.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Divider(
                color: Color.fromARGB(255, 64, 76, 88),
                thickness: 1,
              ),
            ),
            itemBuilder: (context, index) {
              final thread = threads[index].data() as Map<String, dynamic>;
              final threadId = threads[index].id;
              final bool isWritable = !(thread['isWriting'] ?? false);

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                leading: thread['bookCoverUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          thread['bookCoverUrl'],
                          width: 60,
                          height: 88,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Icon(Icons.menu_book,
                        size: 50, color: Color(0xFF9DB2CE)),
                title: Text(thread['title'],
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
                subtitle: Text(
                  isWritable ? 'You can write now' : 'Someone is writing...',
                  style: TextStyle(
                    color:
                        isWritable ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 18, color: Colors.white70),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StoryView(threadId: threadId, userId: userId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
