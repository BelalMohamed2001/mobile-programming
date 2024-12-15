import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Updated UserModel with added utility methods
class UserModel {
  final String uid;
  late final String name;
  late final String email;
  late final String phoneNumber;
   List<String> friendList;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.friendList,
  });

  // Convert Firestore document into UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      friendList: List<String>.from(data['friendList'] ?? []),
    );
  }

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'friendList': friendList,
    };
  }
}