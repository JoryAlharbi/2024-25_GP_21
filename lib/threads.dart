import 'package:flutter/material.dart';
import 'writing.dart'; // Make sure to import your writing.dart file



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: StoryView(),
    );
  }
}

class StoryView extends StatelessWidget {
  final List<TimelineItem> timelineItems = [
    TimelineItem(
      name: 'Rudy Fernandez',
      username: '@RubyFerna',
      content: 'Lorem ipsum dolor sit ame...',
      timeAgo: '4m ago',
      avatarPath: 'assets/h.png',
      avatarName: 'Evelyn',
    ),
    TimelineItem(
      name: 'Lucy Smith',
      username: '@LucySmith',
      content: 'Another example of a timeline item.',
      timeAgo: '10m ago',
      avatarPath: 'assets/cat.png',
      avatarName: 'Lucy',
    ),
    TimelineItem(
      name: 'Oliver Twist',
      username: '@OliverTwist',
      content: 'This is yet another timeline entry.',
      timeAgo: '30m ago',
      avatarPath: 'assets/catm.png',
      avatarName: 'Oliver',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1B2835),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text(
          'StoryName',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications_outlined, color: Color(0xFFD35400), size: 40),
          ),
        ],
      ),
      backgroundColor: Color(0xFF1B2835),
      body: Column(
        children: [
          // Story avatars row
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: timelineItems.length,
              itemBuilder: (context, index) {
                return _buildStoryAvatar(timelineItems[index]);
              },
            ),
          ),
          Divider(
            thickness: 1,
            color: Color(0xFF344C64),
            height: 20,
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: timelineItems.length,
              itemBuilder: (context, index) => _buildTimelineItem(
                timelineItems[index], index == timelineItems.length - 1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WritingPage()), // Ensure WritingPage is correctly defined
                );
              },
             child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 64, 94, 123),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft, // Align to the left
                    child: Padding( // Add padding for spacing
                      padding: EdgeInsets.only(left: 16.0), // Adjust the left padding as needed
                      child: Text(
                        'What happens next?...',
                        style: TextStyle(color: Colors.white),
                        
                      ),
                    ),
                  ),
                  
                ),
            ),
          ),
        ],
      ),
    );
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
                      color: Color(0xFFD35400),
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
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFFD35400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.avatarName,
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
              ],
            ),
            if (!isLastItem)
              Container(
                width: 5,
                height: 40,
                color: Color(0xFFD35400),
              ),
          ],
        ),
        SizedBox(width: 12),
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
                      Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(item.username),
                    ],
                  ),
                  Column(
                    children: [
                      Text(item.timeAgo, style: TextStyle(color: Colors.white, fontSize: 12)),
                      // Reaction button directly below the time
                      IconButton(
                        icon: Stack(
                          alignment: Alignment.center
                          ,
                          children: [
                            Icon(Icons.add_reaction_outlined , color: Color(0xFFA2DED0)),
                            // Positioned(
                            //   right: -1,
                            //   bottom: 1,
                            //   top: 8,
                            //   child: Icon(Icons.add, color: Colors.white, size: 16),
                            // ),
                          ],
                        ),
                        onPressed: () {
                          // Handle reaction logic here
                          print('Reacted to: ${item.name}');
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Text(item.content),
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
