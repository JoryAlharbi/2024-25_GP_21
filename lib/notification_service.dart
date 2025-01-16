import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class NotificationService {
  IO.Socket socket;

  // Constructor to initialize the socket connection
  NotificationService()
      : socket = IO.io('http://your_flask_server_url:5000', <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
        });

  // Method to connect to a specific thread and listen for notifications
  void connectToThread(String threadId) {
    socket.connect();
    socket.emit('subscribe', {'thread_id': threadId});

    socket.on('notification', (data) {
      // Handle the notification (you can display a local notification or update the UI)
      print('Notification received: ${data['message']}');
    });
  }

  // Method to disconnect from the socket
  void disconnect() {
    socket.disconnect();
  }

  // Method to send a notification to a specific user by their userId
  Future<void> sendNotificationToUser(String userId) async {
    try {
      // Fetch the user's device token from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      String? deviceToken = userSnapshot['deviceToken'];

      if (deviceToken != null) {
        // Send a notification to the user's device using Firebase Messaging
        await FirebaseMessaging.instance.sendMessage(
          to: deviceToken,
          data: {
            'title': 'No one is writing!',
            'body': 'Click here to join the story writing session.',
          },
        ).catchError((e) {
          print("Failed to send notification: $e");
        });
        print("Notification sent to $userId");
      } else {
        print("Device token is null for user $userId");
      }
    } catch (e) {
      print("Failed to fetch user data or send notification: $e");
    }
  }
}

Future<void> sendNotificationToUser(String userId) async {
  try {
    // Fetch the user's device token from Firestore
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    String? deviceToken = userSnapshot['deviceToken'];

    if (deviceToken != null) {
      // Send a notification to the user's device using Firebase Messaging
      await FirebaseMessaging.instance.sendMessage(
        to: deviceToken,
        data: {
          'title': 'No one is writing!',
          'body': 'Click here to join the story writing session.',
        },
      );
      print("Notification sent to $userId");
    } else {
      print("Device token is null for user $userId");
    }
  } catch (e) {
    print("Failed to fetch user data or send notification: $e");
  }
}
