import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String giftId;
  final String message;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.giftId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'],
      giftId: data['giftId'],
      message: data['message'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'giftId': giftId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}
