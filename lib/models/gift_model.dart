import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String id;
  final String name;
  final String category;
  final double price;
  final bool pledged; // true if gift is pledged, false otherwise
  final String? pledgedBy; // User ID of the person who pledged it, or null if unpledged
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
    this.pledgedBy, // Make it optional to handle cases where the gift isn't pledged
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
      pledgedBy: data['pledgedBy'], // Extract the pledgedBy field
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
      'pledgedBy': pledgedBy, // Include pledgedBy field in Firestore map
      'eventId': eventId,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  // Convert a Map from SQLite into Gift instance
  factory Gift.fromMapSQLite(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      pledged: map['pledged'] == 1, // If pledged, store as 1 (true), otherwise 0 (false)
      pledgedBy: map['pledgedBy'],
      eventId: map['eventId'],
      description: map['description'],
      imageUrl: map['imageUrl'],
    );
  }

  // Convert Gift instance to a Map for SQLite insert/update
  Map<String, dynamic> toMapSQLite() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'pledged': pledged ? 1 : 0, // Store pledged as 1 (true) or 0 (false)
      'pledgedBy': pledgedBy,
      'eventId': eventId,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
