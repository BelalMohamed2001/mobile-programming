import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_project/controllers/notification_controller.dart';
import '../models/auth_model.dart';
import '../models/event_model.dart';
import '../models/gift_model.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationController _notificationController = NotificationController();
  // Fetch user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
    } catch (e) {
      print('Error fetching user by ID: $e');
    }
    return null;
  }

  // Search for a user by phone number
  Future<UserModel?> searchUserByPhone(String phone) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phone)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
    } catch (e) {
      print('Error searching user by phone: $e');
    }
    return null;
  }

  // Add friend
  Future<void> addFriend(String currentUserId, String friendId) async {
    print("Current user: $currentUserId");
    print("Friend user: $friendId");

    try {
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      final friendUserRef = _firestore.collection('users').doc(friendId);

      final currentUserSnapshot = await currentUserRef.get();
      final friendUserSnapshot = await friendUserRef.get();

      if (currentUserSnapshot.exists && friendUserSnapshot.exists) {
        UserModel currentUser = UserModel.fromFirestore(currentUserSnapshot);
        UserModel friendUser = UserModel.fromFirestore(friendUserSnapshot);

        List<String> currentUserFriends = List<String>.from(currentUser.friendList);
        List<String> friendUserFriends = List<String>.from(friendUser.friendList);

        if (!currentUserFriends.contains(friendId)) {
          currentUserFriends.add(friendId);
        }

        if (!friendUserFriends.contains(currentUserId)) {
          friendUserFriends.add(currentUserId);
        }

        await currentUserRef.update({'friendList': currentUserFriends});
        await friendUserRef.update({'friendList': friendUserFriends});

        print('Friend added successfully!');
      } else {
        print('One or both users do not exist.');
      }
    } catch (e) {
      print('Error adding friend: $e');
      throw Exception("Failed to add friend: $e");
    }
  }

  // Get current user's friend list
  Future<List<UserModel>> getFriendList(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        List<String> friendIds = List<String>.from(userDoc.data()?['friendList'] ?? []);
        List<UserModel> friends = [];

        for (String friendId in friendIds) {
          final friendDoc = await _firestore.collection('users').doc(friendId).get();

          if (friendDoc.exists) {
            friends.add(UserModel.fromFirestore(friendDoc));
          }
        }
        return friends;
      }
    } catch (e) {
      print('Error fetching friend list: $e');
    }
    return [];
  }

  // Fetch all events associated with a friend's userId
  Future<List<EventModel>> getFriendEvents(String friendId) async {
    try {
      QuerySnapshot eventsSnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: friendId)
          .get();

      return eventsSnapshot.docs
          .map((doc) => EventModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching friend events: $e');
      throw Exception('Error fetching friend events: $e');
    }
  }

  // Fetch all gifts associated with a specific eventId
  Future<List<Gift>> getGiftsForEvent(String eventId) async {
    try {
      QuerySnapshot giftsSnapshot = await _firestore
          .collection('gifts')
          .where('eventId', isEqualTo: eventId)
          .get();

      return giftsSnapshot.docs
          .map((doc) => Gift.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching gifts: $e');
      throw Exception('Error fetching gifts: $e');
    }
  }


Future<void> pledgeGift(String giftId, String creatorId) async {
  try {
    await _firestore.collection('gifts').doc(giftId).update({
      'pledged': true,
    });

    // Send a notification to the gift creator
    final message = 'Someone has pledged to buy your gift!';
    await _notificationController.sendNotification(creatorId, giftId, message);
  } catch (e) {
    throw Exception('Error pledging gift: $e');
  }
}



}
