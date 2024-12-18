import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import 'gift_list_controller.dart';
import '../models/gift_model.dart';

class EventController {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');
  final GiftController _giftController = GiftController();

  // Fetch events for the current user
  Future<List<EventModel>> fetchEvents(String userId) async {
    QuerySnapshot snapshot = await eventsCollection
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      return EventModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Add a new event
  Future<void> addEvent(EventModel event) async {
    await eventsCollection.add(event.toFirestore());
  }

  // Update an existing event
  Future<void> updateEvent(EventModel event) async {
    await eventsCollection.doc(event.id).update(event.toFirestore());
  }

  // Delete an event
  Future<void> deleteEvent(String id) async {
    await eventsCollection.doc(id).delete();
  }


   // Fetch events along with associated gifts for the current user
  Future<List<Map<String, dynamic>>> fetchEventsWithGifts(String userId) async {
    QuerySnapshot snapshot = await eventsCollection
        .where('userId', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> eventsWithGifts = [];

    for (var doc in snapshot.docs) {
      var event = EventModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      // Fetch the gifts for each event
      List<Gift> gifts = await _giftController.fetchGifts(event.id);

      eventsWithGifts.add({
        'event': event,
        'gifts': gifts,
      });
    }

    return eventsWithGifts;
  }
}