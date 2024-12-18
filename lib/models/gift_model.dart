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
  
}
