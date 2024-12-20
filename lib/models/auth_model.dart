import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Updated UserModel to support Firestore and SQLite
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

  // Convert a Map from SQLite into UserModel
  factory UserModel.fromMapSQLite(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'], // Assume `uid` is the primary key in SQLite
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      friendList: List<String>.from(map['friendList']?.split(',') ?? []), // Split the stored comma-separated string back into a list
    );
  }

  // Convert UserModel into a Map for SQLite insert/update
  Map<String, dynamic> toMapSQLite() {
    return {
      'uid': uid, // Assuming `uid` is the primary key for SQLite
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'friendList': friendList.join(','), // Join the list into a comma-separated string
    };
  }
}
