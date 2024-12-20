import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_project/main.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool hasShownNotification = false; 
  
  Future<void> initNotifications() async {
    // Android-specific initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('giftbox');

    // iOS-specific initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the notifications plugin
    await _notificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        hasShownNotification = false;  
        _listenForNotifications(user.uid);
      } else {
        hasShownNotification = false;  
      }
    });
  }

  
  void _listenForNotifications(String userId) {
    _firestore.collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false) 
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        var data = doc.data();
        String title = data['title'] ?? 'New gift pledged';
        String body = data['message'] ?? '';

        
        if (!hasShownNotification) {
          _showNotification(title, body, doc.id);
          hasShownNotification = true;  
          _markAsRead(doc.id); 
        }
      }
    });
  }

  Future<void> _showNotification(String title, String body, String payload) async {
    
    const androidDetails = AndroidNotificationDetails(
      'gift_channel',
      'Gift Notifications',
      channelDescription: 'Notifications for gift pledges',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'giftbox',
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    
    await _notificationsPlugin.show(
      0,
      title,
      body,
      details,
      payload: payload,
    );
  }

  
  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      Navigator.pushNamed(
        navigationKey.currentContext!,
        '/gift_details',
        arguments: payload,
      );
    }
  }

  // Mark the notification as read (update in Firestore)
  Future<void> _markAsRead(String notificationId) async {
    await _firestore.collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  
  Future<void> sendNotification(String userId, String giftId, String message) async {
   
    var existingNotification = await _firestore.collection('notifications')
        .where('giftId', isEqualTo: giftId)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false) 
        .get();

    
    if (existingNotification.docs.isEmpty) {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'giftId': giftId,
        'message': message,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
