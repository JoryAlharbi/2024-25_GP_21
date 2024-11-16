// Import the required Firebase modules
const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Function to notify all users in bellClickers when the thread becomes available for writing
exports.notifyBellClickers = functions.firestore
    .document('Thread/{threadId}')
    .onUpdate(async (change, context) => {
      const after = change.after.data(); // Data after the update
      const threadId = context.params.threadId;

      // Only proceed if `isWriting` has changed to false and there are users in `bellClickers`
      if (!after.isWriting && after.bellClickers && after.bellClickers.length > 0) {
        const bellClickers = after.bellClickers;

        // Retrieve FCM tokens for users in `bellClickers`
        const tokens = [];
        for (const userRef of bellClickers) {
          const userSnapshot = await userRef.get();
          const userToken = userSnapshot.data().fcmToken; // Assuming each user document has an `fcmToken` field
          if (userToken) tokens.push(userToken);
        }

        // Construct the notification message
        const message = {
          notification: {
            title: 'Thread is Open!',
            body: 'You can start writing now!',
          },
          tokens: tokens
        };

        // Send the notification to all FCM tokens
        if (tokens.length > 0) {
          try {
            const response = await admin.messaging().sendMulticast(message);
            console.log('Notifications sent successfully:', response);
          } catch (error) {
            console.error('Error sending notifications:', error);
          }
        }
      }
      return null;
    });
