import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import 'package:firebase_core/firebase_core.dart'; // Add Firebase core import
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'main.dart';
import 'package:rawae_gp24/bookmark.dart';
import 'package:rawae_gp24/edit_profile_page.dart';
import 'package:rawae_gp24/homepage.dart';
import 'package:rawae_gp24/library.dart';
import 'package:rawae_gp24/makethread.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rawae_gp24/custom_navigation_bar.dart'; // Import CustomNavigationBar

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 3;
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

        // Check for the 'bookCoverUrl' and set a fallback if null
        String? bookCoverUrl = threadData['bookCoverUrl'] ??
            'assets/default_cover.png'; // Fallback to a default cover image

        if (threadData['status'] == 'in_progress') {
          inProgressThreads.add({
            ...threadData, // Copy all the existing data
            'bookCoverUrl': bookCoverUrl, // Add the bookCoverUrl field
          });
        } else if (threadData['status'] == 'Published') {
          publishedThreads.add({
            ...threadData, // Copy all the existing data
            'bookCoverUrl': bookCoverUrl, // Add the bookCoverUrl field
          });
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
          profileImageUrl = snapshot.data()?['profileImageUrl'];
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
        try {
          // Upload the image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_pictures/${user.uid}.jpg');
          final uploadTask = storageRef.putFile(file);

          // Check the upload task status
          await uploadTask.whenComplete(() async {
            if (uploadTask.snapshot.state == TaskState.success) {
              // Get the download URL for the uploaded image
              final downloadUrl = await storageRef.getDownloadURL();

              // Update the Firestore document with the new image URL
              await FirebaseFirestore.instance
                  .collection('Writer')
                  .doc(user.uid)
                  .update({'profileImageUrl': downloadUrl});

              setState(() {
                profileImageUrl = downloadUrl; // Update UI with new image URL
              });
            } else {
              // Handle failure (optional)
              print("Image upload failed.");
            }
          });
        } catch (e) {
          print("Error uploading profile image: $e");
          // Handle any errors (e.g., network issues, file permissions, etc.)
        }
      } else {
        print("User not logged in.");
      }
    } else {
      print("No image selected.");
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
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF1B2835),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Transparent to blend with the curve
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1B2835)),
            iconSize: 30,
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Log out the user
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MyApp()), // Navigate to MainPage
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD35400),
                    Color(0xFF344C64),
                    Color(0xFFA2DED0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 88),
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
                const SizedBox(height: 55),
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
                        horizontal: 30, vertical: 17),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w500, // Move this inside the style method
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: const EdgeInsets.only(top: 20, bottom: 0),
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
                                        margin: const EdgeInsets.only(top: 6),
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
                                      'In Progress',
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
                                        margin: const EdgeInsets.only(top: 6),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          isPublishedSelected
                              ? Expanded(
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, // Two books per row
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio:
                                          0.8, // Adjusted ratio for smaller cards
                                    ),
                                    itemCount: publishedThreads.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .transparent, // Match the app background
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                publishedThreads[index]
                                                        ['bookCoverUrl'] ??
                                                    '',
                                                height: 160,
                                                width: 110,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              publishedThreads[index]
                                                      ['title'] ??
                                                  'Untitled',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Colors
                                                    .white, // Match text color to the theme
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Expanded(
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, // Two books per row
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio:
                                          0.8, // Adjusted ratio for smaller cards
                                    ),
                                    itemCount: inProgressThreads.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .transparent, // Match the app background
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                inProgressThreads[index]
                                                        ['bookCoverUrl'] ??
                                                    'No books Avalible',
                                                height: 160,
                                                width: 110,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              inProgressThreads[index]
                                                      ['title'] ??
                                                  'Untitled',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w300,
                                                color: Colors
                                                    .white, // Match text color to the theme
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MakeThreadPage()),
          );
        },
        backgroundColor: const Color(0xFFD35400),
        elevation: 6,
        child: const Icon(
          Icons.add,
          size: 36,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavigationBar(selectedIndex: 3),
    );
  }
}

// Custom Clipper for the curved background shape
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    // First dip (goes down)
    path.quadraticBezierTo(
      size.width * 0.16,
      size.height,
      size.width * 0.33,
      size.height - 40,
    );

    // Middle bump (goes up)
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height - 80,
      size.width * 0.66,
      size.height - 40,
    );

    // Last dip (goes down)
    path.quadraticBezierTo(
      size.width * 0.83,
      size.height,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0); // Top-right corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
