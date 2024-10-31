import 'package:firebase_database/firebase_database.dart';

final databaseRef =
    FirebaseDatabase.instance.ref(); // Reference to your Firebase Database

// Write data to check if connected
void writeTestData() {
  databaseRef.child("test").set({"connected": true}).then((_) {
    print("Write test successful!");
  }).catchError((error) {
    print("Error writing to database: $error");
  });
}

// Read data to check if connected
void readTestData() {
  databaseRef.child("test").get().then((snapshot) {
    if (snapshot.exists) {
      print("Read test successful: ${snapshot.value}");
    } else {
      print("No data found.");
    }
  }).catchError((error) {
    print("Error reading from database: $error");
  });
}
