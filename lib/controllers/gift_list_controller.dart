import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/gift_model.dart';

class GiftController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch gifts for an event from Firestore
  Future<List<Gift>> fetchGifts(String eventId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('gifts')
          .where('eventId', isEqualTo: eventId)
          .get();

      return snapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }

  // Add new gift to Firestore
  Future<void> addGift(Gift gift, File? imageFile) async {
    String? imageUrl;

    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, gift.name);
    }

    final giftData = gift.toMap();
    if (imageUrl != null) {
      giftData['imageUrl'] = imageUrl;
    }

    await _firestore.collection('gifts').add(giftData);
  }

  // Delete a gift
  Future<void> deleteGift(String giftId) async {
    try {
      await _firestore.collection('gifts').doc(giftId).delete();
    } catch (e) {
      print('Error deleting gift: $e');
    }
  }

  // Edit gift details
  Future<void> updateGift(Gift gift, File? imageFile) async {
    String? imageUrl;

    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, gift.name);
    }

    final giftData = gift.toMap();
    if (imageUrl != null) {
      giftData['imageUrl'] = imageUrl;
    }

    await _firestore.collection('gifts').doc(gift.id).update(giftData);
  }

  // Private method to upload an image to Firebase Storage
  Future<String> _uploadImage(File imageFile, String giftName) async {
    final storageRef = _storage
        .ref()
        .child('gift_images/${DateTime.now().millisecondsSinceEpoch}_$giftName.jpg');
    final uploadTask = storageRef.putFile(imageFile);
    final taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }
}
