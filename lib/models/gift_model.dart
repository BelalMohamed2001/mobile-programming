import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String id;
  final String name;
  final String category;
  final double price;
  final bool pledged; 
  final String? pledgedBy; 
  final String eventId;
  final String description;
  final String? imageUrl; 
  final DateTime? dueDate; 
  String friendOwner;
 


  Gift({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.pledged,
    this.pledgedBy,
    required this.eventId,
    required this.description,
    this.imageUrl,
    this.dueDate,  
     this.friendOwner = "",
  });

  factory Gift.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Gift(
      id: doc.id,
      name: data['name'],
      category: data['category'],
      price: data['price'],
      pledged: data['pledged'],
      pledgedBy: data['pledgedBy'], 
      eventId: data['eventId'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'pledged': pledged,
      'pledgedBy': pledgedBy, 
      'eventId': eventId,
      'description': description,
      'imageUrl': imageUrl,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null, 
    };
  }

  factory Gift.fromMapSQLite(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      pledged: map['pledged'] == 1,
      pledgedBy: map['pledgedBy'],
      eventId: map['eventId'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }

  Map<String, dynamic> toMapSQLite() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'pledged': pledged ? 1 : 0, 
      'pledgedBy': pledgedBy,
      'eventId': eventId,
      'description': description,
      'imageUrl': imageUrl,
      'dueDate': dueDate?.toIso8601String(), 
    };
  }
}
