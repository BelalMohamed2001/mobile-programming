import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_project/controllers/notification_controller.dart';
import '../models/auth_model.dart';
import '../models/event_model.dart';
import '../models/gift_model.dart';
import '../controllers/auth_controller.dart';
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

  // Pledge a gift
  Future<void> pledgeGift(String giftId, String creatorId) async {
  try {
    // Check if this gift has already been pledged
    final giftDoc = await _firestore.collection('gifts').doc(giftId).get();
    if (giftDoc.exists && giftDoc['pledged']) {
      throw Exception('Gift already pledged!');
    }

    // Get current user UID
    String? currentUserId = await AuthController().getCurrentUser();
    if (currentUserId == null) {
      throw Exception('No current user found');
    }

    // Update the gift status as pledged
    await _firestore.collection('gifts').doc(giftId).update({
      'pledged': true,
      'pledgedBy': currentUserId, // Set the resolved UID here
    });

    // Create a new notification entry, if not already sent
    await _firestore.collection('notifications').add({
      'userId': creatorId,
      'giftId': giftId,
      'message': 'Someone has pledged to buy your gift!',
      'title': 'Gift Pledged!',
      'isSent': false,  // Ensure it's sent only once
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,  // Mark as unread initially
    });

    // Send notification to the creator
    await _notificationController.sendNotification(creatorId, giftId, 'Someone has pledged to buy your gift!');
  } catch (e) {
    print('Error pledging gift: $e');
    throw Exception('Error pledging gift: $e');
  }
}
  // Get the friend who owns the gift that the user pledged
  Future<UserModel?> getFriendOwnsGift(String userId, String giftId) async {
    try {
      // Fetch the gift information based on the pledged giftId
      final giftDoc = await _firestore.collection('gifts').doc(giftId).get();

      if (!giftDoc.exists) {
        print("Gift does not exist.");
        return null;
      }

      // Get gift details and check if it has a pledged user
      Gift gift = Gift.fromFirestore(giftDoc);
      if (!gift.pledged || gift.pledgedBy != userId) {
        print("No matching pledged gift found for the user.");
        return null;
      }

      // Fetch the event associated with this gift
      final eventDoc = await _firestore.collection('events').doc(gift.eventId).get();
      if (!eventDoc.exists) {
        print("Event related to gift does not exist.");
        return null;
      }

      EventModel event = EventModel.fromFirestore(eventDoc.data() as Map<String, dynamic>, eventDoc.id);

      // Get the creator (userId) of this event (event owner)
      String ownerId = event.userId;

      // Fetch user information for the creator/owner of the event
      final ownerDoc = await _firestore.collection('users').doc(ownerId).get();
      if (!ownerDoc.exists) {
        print("Owner user does not exist.");
        return null;
      }

      UserModel owner = UserModel.fromFirestore(ownerDoc);

      // Check if the gift's owner is a friend of the user
      List<UserModel> userFriends = await getFriendList(userId);
      bool isFriend = userFriends.any((friend) => friend.uid == owner.uid);

      if (isFriend) {
        return owner; // Return the owner if they are a friend
      } else {
        print("Owner is not a friend.");
        return null; // Return null if the owner is not a friend
      }
    } catch (e) {
      print('Error fetching friend owner of pledged gift: $e');
      throw Exception('Error fetching friend owner of pledged gift: $e');
    }
  }



  // Fetch all gifts pledged by the user
  // Ensure this query is correct
Future<List<Gift>> getUserPledgedGifts(String userId) async {
  try {
    final QuerySnapshot giftsSnapshot = await _firestore
        .collection('gifts')
        .where('pledgedBy',isEqualTo: userId)
        .where('pledged', isEqualTo: true) // Fetch only pledged gifts
        .get();
    
    if (giftsSnapshot.docs.isEmpty) {
      print("No pledged gifts found.");
    }

    return giftsSnapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
  } catch (e) {
    print('Error fetching pledged gifts: $e');
    throw Exception('Error fetching pledged gifts: $e');
  }
}

}
