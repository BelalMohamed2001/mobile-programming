import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  late final String name;
  late final String email;
  late final String phoneNumber;
  List<String> friendList;
  int? upcomingEventCount; 

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.friendList,
    this.upcomingEventCount, 
  });

 
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      friendList: List<String>.from(data['friendList'] ?? []),
      upcomingEventCount: data['upcomingEventCount'], 
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'friendList': friendList,
      if (upcomingEventCount != null) 'upcomingEventCount': upcomingEventCount, 
    };
  }


  factory UserModel.fromMapSQLite(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      friendList: List<String>.from(map['friendList']?.split(',') ?? []),
      upcomingEventCount: map['upcomingEventCount'] != null
          ? int.tryParse(map['upcomingEventCount'])
          : null, 
    );
  }

 
  Map<String, dynamic> toMapSQLite() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'friendList': friendList.join(','),
      'upcomingEventCount': upcomingEventCount?.toString(), //
    };
  }
}
