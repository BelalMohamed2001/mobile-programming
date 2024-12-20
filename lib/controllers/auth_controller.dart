import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_model.dart'; 
import '../services/notification_service.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Sign Up a new user
  Future<UserModel?> signUp(
      String email, String password, String phoneNumber, String name) async {
    try {
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        
        UserModel userModel = UserModel(
          email: user.email!,
          uid: user.uid,
          name: name,
          phoneNumber: phoneNumber,
          friendList: [], 
        );

       
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Sign Up Failed: $e');
    }
  }

  // Sign In an existing user
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        // Fetch user data from Firestore after user is authenticated
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc); // Parse Firestore document
        }
      }
      return null;
    } catch (e) {
      throw Exception('Login Failed: $e');
    }
  }

  // Fetch user profile by UID
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc); 
      }
      throw Exception('User profile not found');
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Sign Out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update the user's information
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Stream to listen to the authentication state
  // Listen for authentication state changes
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user != null) {
        
        await _notificationService.initNotifications();
      } else {
        
        _notificationService.hasShownNotification = false;
      }
      return user;
    });
  }
  // Fetch the current user's UID
  Future<String?> getCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return user.uid;
      }
      throw Exception('No user is currently signed in');
    } catch (e) {
      throw Exception('Failed to fetch current user: $e');
    }
  }
}