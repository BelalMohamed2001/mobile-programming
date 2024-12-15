class EventModel {
  String id;
  String name;
  String category;
  String status; 
  String description;
  String date;
  String userId; 

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
}