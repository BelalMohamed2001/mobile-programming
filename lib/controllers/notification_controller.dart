import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';


class NotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen for notifications in real-time for the current user
  Stream<List<NotificationModel>> listenForUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  // Send a notification when another user pledges a gift
  Future<void> sendNotification(
      String creatorId, String giftId, String message) async {
    try {
      final notification = NotificationModel(
        id: '', // Firestore will auto-generate the ID
        userId: creatorId,
        giftId: giftId,
        message: message,
        timestamp: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toMap());
    } catch (e) {
      throw Exception('Error sending notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }
}
