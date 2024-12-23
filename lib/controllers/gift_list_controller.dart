import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/gift_model.dart';

class GiftController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _giftsCollection =
      FirebaseFirestore.instance.collection('gifts');

  
  Future<List<Gift>> getGiftsByUser(String userId) async {
    final querySnapshot = await _giftsCollection.where('eventId', isEqualTo: userId).get();
    return querySnapshot.docs
        .map((doc) => Gift.fromFirestore(doc))
        .toList();
  }

  
  Future<void> pledgeGift(String giftId) async {
    await _giftsCollection.doc(giftId).update({'pledged': true});
  }

  
  Future<List<Gift>> fetchGifts(String eventId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('gifts')
          .where('eventId', isEqualTo: eventId)
          .get();

      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching gifts: $e');
    }
  }

 
  Future<List<Gift>> fetchGiftsForUser(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('gifts')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching gifts for user: $e');
    }
  }

  
  Future<void> addGift(Gift gift, String? imageUrl) async {
    try {
      final giftData = gift.toMap();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        giftData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('gifts').add(giftData);
    } catch (e) {
      throw Exception('Error adding gift: $e');
    }
  }

 
  Future<void> deleteGift(String giftId) async {
    try {
      await _firestore.collection('gifts').doc(giftId).delete();
    } catch (e) {
      throw Exception('Error deleting gift: $e');
    }
  }

  
  Future<void> updateGift(Gift gift, File? imageFile) async {
    try {
      String? imageUrl;

      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, gift.name);
      }

      final giftData = gift.toMap();
      if (imageUrl != null) {
        giftData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('gifts').doc(gift.id).update(giftData);
    } catch (e) {
      throw Exception('Error updating gift: $e');
    }
  }

  
  Future<void> changeGiftStatus(String giftId, String status) async {
    try {
      
      if (status == 'Pending' || status == 'Delivered') {
        await _giftsCollection.doc(giftId).update({'status': status});
      } else {
        throw Exception("Invalid status value. Only 'Pending' or 'Delivered' are allowed.");
      }
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }

  
  Future<String> _uploadImage(File imageFile, String giftName) async {
    try {
      final storageRef = _storage.ref().child(
          'gift_images/${DateTime.now().millisecondsSinceEpoch}_$giftName.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      final taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }


 Future<void> updateGiftStatus(String giftId, String status) async {
  try {
    if (status == 'Pending' || status == 'Delivered') {
      final docRef = _giftsCollection.doc(giftId);
      await docRef.update({'status': status});
      print("Gift status updated to: $status for gift ID $giftId");
    } else {
      throw Exception("Invalid status value. Only 'Pending' or 'Delivered' are allowed.");
    }
  } catch (e) {
    print("Error updating gift status: $e");
  }
}

}
