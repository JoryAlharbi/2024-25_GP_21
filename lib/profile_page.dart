import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import 'package:firebase_core/firebase_core.dart'; // Add Firebase core import
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:rawae_gp24/bookmark.dart';
import 'package:rawae_gp24/edit_profile_page.dart';
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/library.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rawae_gp24/custom_navigation_bar.dart'; // Import your CustomNavigationBar

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isPublishedSelected = true;
  String? profileImageUrl;
  String? username;
  File? _profileImage;

  List<Map<String, dynamic>> inProgressThreads = [];
  List<Map<String, dynamic>> publishedThreads = [];

  // Fetch user's threads
  Future<void> fetchUserThreads() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return; // Return if no user is logged in.

    try {
      final userRef =
          FirebaseFirestore.instance.collection('Writer').doc(user.uid);
      // Fetch threads where contributors array contains the user's reference
      final threadsSnapshot = await FirebaseFirestore.instance
          .collection('Thread')
          .where('contributors',
              arrayContains: userRef) // Match with user's document reference
          .get();

      print('Fetched Threads Count: ${threadsSnapshot.size}');
      threadsSnapshot.docs.forEach((doc) {
        print(doc.data());
      });

      List<Map<String, dynamic>> inProgressThreads = [];
      List<Map<String, dynamic>> publishedThreads = [];

      for (var doc in threadsSnapshot.docs) {
        var threadData = doc.data() as Map<String, dynamic>;
        if (threadData['status'] == 'in_progress') {
          inProgressThreads.add(threadData);
        } else if (threadData['status'] == 'Published') {
          publishedThreads.add(threadData);
        }
      }

      setState(() {
        this.inProgressThreads = inProgressThreads;
        this.publishedThreads = publishedThreads;
      });
    } catch (e) {
      print("Error fetching threads: $e");
    }
  }

  // Fetch writer's data
  Future<void> fetchWriterData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Writer')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          profileImageUrl = snapshot.data()?['profileImageUrl'] ??
              'assets/default.png'; // Fallback to default image
          username = snapshot.data()?['username'];
        });
      }
    }
  }

  // Function to pick an image
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Select and upload a new profile picture
  Future<void> selectProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}.jpg');
        await storageRef.putFile(file);

        final downloadUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('Writer')
            .doc(user.uid)
            .update({'profileImageUrl': downloadUrl});

        setState(() {
          profileImageUrl = downloadUrl;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWriterData();
    fetchUserThreads(); // Call to fetch the threads
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFF1B2835),
      body: Stack(
        children: [
          SizedBox(
            height: 110,
            child: CustomPaint(
              painter: CurvePainter(),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFD35400).withOpacity(0.8),
                      const Color(0xFF344C64).withOpacity(0.8),
                      const Color(0xFFA2DED0).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 120),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(
                                _profileImage!) // Display the picked image
                            : (profileImageUrl != null &&
                                    profileImageUrl!.isNotEmpty
                                ? NetworkImage(
                                    profileImageUrl!) // Display the image from network (if available)
                                : null) as ImageProvider?, // Handle null properly
                        child: _profileImage == null &&
                                (profileImageUrl == null ||
                                    profileImageUrl!.isEmpty)
                            ? const Icon(Icons.add_a_photo,
                                color: Colors.white,
                                size: 50) // Default icon when no image
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: selectProfilePicture,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  username ?? 'Loading...',
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.email ?? 'No email available',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: const Color(0xFFA4A4A4)),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD35400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                  ),
                  child: Text(
                    'Edit Profile',
                    style:
                        GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(23, 32, 45, 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isPublishedSelected = true;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'Published',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isPublishedSelected
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                    if (isPublishedSelected)
                                      Container(
                                        height: 3,
                                        width: 60,
                                        color: Colors.white,
                                        margin: const EdgeInsets.only(top: 4),
                                      ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isPublishedSelected = false;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'InProgress',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: !isPublishedSelected
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                    if (!isPublishedSelected)
                                      Container(
                                        height: 3,
                                        width: 60,
                                        color: Colors.white,
                                        margin: const EdgeInsets.only(top: 4),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          isPublishedSelected
                              ? Expanded(
                                  child: ListView.builder(
                                    itemCount: publishedThreads.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(
                                          publishedThreads[index]['title'],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          publishedThreads[index]
                                              ['description'],
                                          style:
                                              TextStyle(color: Colors.white70),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Expanded(
                                  child: ListView.builder(
                                    itemCount: inProgressThreads.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(
                                          inProgressThreads[index]['title'],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          inProgressThreads[index]
                                              ['description'],
                                          style:
                                              TextStyle(color: Colors.white70),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex:
            0, // Pass the required argument/ Your custom navigation bar
      ),
    );
  }
}

// Custom Clipper for the curved background shape
class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    var path = Path();
    path.lineTo(0, size.height * 0.6);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 1.2, size.width, size.height * 0.6);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
