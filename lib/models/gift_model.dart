import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String id;
  final String name;
  final String category;
  final double price;
  final bool pledged; // true if gift is pledged, false otherwise
  final String eventId;
  final String description;
  final String? imageUrl; // Optional field to store image URL

  // Constructor
  Gift({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.pledged,
    required this.eventId,
    required this.description,
    this.imageUrl,
  });

  // Factory constructor to create Gift instance from Firestore document snapshot
  factory Gift.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Gift(
      id: doc.id,
      name: data['name'],
      category: data['category'],
      price: data['price'],
      pledged: data['pledged'],
      eventId: data['eventId'],
      description: data['description'],
      imageUrl: data['imageUrl'],
    );
  }

  // Method to convert Gift object back to map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'pledged': pledged,
      'eventId': eventId,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
