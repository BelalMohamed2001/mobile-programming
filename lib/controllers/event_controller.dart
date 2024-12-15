import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

class EventController {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

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
}