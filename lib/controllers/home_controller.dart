import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_model.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Add friend logic
  // Add friend function in HomeController:
Future<void> addFriend(String currentUserId, String friendId) async {
  print("this is the current user: $currentUserId");
  print("this is the friend: $friendId");

  try {
    // Reference the users collection
    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final friendUserRef = _firestore.collection('users').doc(friendId);

    // Fetch the documents and convert them to UserModel
    DocumentSnapshot currentUserSnapshot = await currentUserRef.get();
    DocumentSnapshot friendUserSnapshot = await friendUserRef.get();

    // Check if the documents exist
    if (currentUserSnapshot.exists && friendUserSnapshot.exists) {
      // Convert DocumentSnapshots to UserModels
      UserModel currentUser = UserModel.fromFirestore(currentUserSnapshot);
      UserModel friendUser = UserModel.fromFirestore(friendUserSnapshot);

      // Get the current friend lists, or initialize as empty
      List<String> currentUserFriends = List<String>.from(currentUser.friendList);
      List<String> friendUserFriends = List<String>.from(friendUser.friendList);

      // Add friend if not already added
      if (!currentUserFriends.contains(friendId)) {
        currentUserFriends.add(friendId);
      }

      if (!friendUserFriends.contains(currentUserId)) {
        friendUserFriends.add(currentUserId);
      }

      // Update the user documents in Firestore without using transactions
      await currentUserRef.update({'friendList': currentUserFriends});
      await friendUserRef.update({'friendList': friendUserFriends});

      print('Friend added successfully!');
    } else {
      print('One or both users do not exist in the database.');
    }
  } catch (e) {
    print('Error adding friend: $e');
    throw Exception("Failed to add friend: $e"); // Handle the error properly
  }
}

  // Get current user's friend list
Future<List<UserModel>> getFriendList(String userId) async {
  try {
    // Fetch the user document to get the friend list
    final userDoc = await _firestore.collection('users').doc(userId).get();

    // Check if the document exists
    if (userDoc.exists) {
      // Get the friend list (array of friend user IDs)
      List<String> friendIds = List<String>.from(userDoc.data()?['friendList'] ?? []);

      // Create a list to store the friend models
      List<UserModel> friends = [];

      // Loop through friend IDs and fetch their corresponding user data
      for (String friendId in friendIds) {
        final friendDoc = await _firestore.collection('users').doc(friendId).get();
        
        if (friendDoc.exists) {
          // Create a UserModel from the friend document and add to the list
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


}
