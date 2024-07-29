import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotification(String userId, String message) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'message': message,
      'timestamp': Timestamp.now(),
    });
  }
}
