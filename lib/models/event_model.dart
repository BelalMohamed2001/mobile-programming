class EventModel {
  final String id;
  final String name;
  final String category;
  final String status;
  final String description;
  final String date;
  final String userId;

  
  EventModel({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.description,
    required this.date,
    required this.userId,
  });

  
  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  
  factory EventModel.fromMapSQLite(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      status: map['status'],
      description: map['description'],
      date: map['date'],
      userId: map['userId'],
    );
  }

  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'status': status,
      'description': description,
      'date': date,
      'userId': userId,
    };
  }

  
  Map<String, dynamic> toMapSQLite() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'status': status,
      'description': description,
      'date': date,
      'userId': userId,
    };
  }

  
  EventModel copyWith({String? status}) {
    return EventModel(
      id: this.id,
      name: this.name,
      category: this.category,
      status: status ?? this.status, 
      description: this.description,
      date: this.date,
      userId: this.userId,
    );
  }
}
