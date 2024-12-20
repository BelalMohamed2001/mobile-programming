import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  // Listen for notifications in real-time for the current user
  Stream<List<NotificationModel>> listenForUserNotifications(String userId) {
  return _firestore
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false) // Only listen for unread notifications
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
      
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: creatorId)
          .where('giftId', isEqualTo: giftId)
          .where('isRead',
              isEqualTo: false) 
          .get();

      if (snapshot.docs.isEmpty) {
        // Send notification if not already sent
        final notification = NotificationModel(
          id: '', 
          userId: creatorId,
          giftId: giftId,
          message: message,
          timestamp: DateTime.now(),
          isRead: false, 
        );

        // Add the notification to Firestore
        await _firestore.collection('notifications').add(notification.toMap());
        
        
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }
}
