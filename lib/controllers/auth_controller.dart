import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_model.dart'; // Ensure UserModel is the correct one used

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up a new user
  Future<UserModel?> signUp(
      String email, String password, String phoneNumber, String name) async {
    try {
      // Create the user with email and password using Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        // Create user model object to hold user data
        UserModel userModel = UserModel(
          email: user.email!,
          uid: user.uid,
          name: name,
          phoneNumber: phoneNumber,
          friendList: [], // Initialize with an empty friend list
        );

        // Add the user data to Firestore in 'users' collection
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        // Return the UserModel object
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
        return UserModel.fromFirestore(userDoc); // Parse Firestore document
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
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user != null) {
        // Fetch user data from Firestore when the user state changes
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc); // Parse Firestore document
        }
      }
      return null;
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
