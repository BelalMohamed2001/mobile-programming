import 'package:flutter/material.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  const MyPledgedGiftsPage({Key? key}) : super(key: key);

  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  List<Map<String, dynamic>> pledgedGifts = [
    {'giftName': 'Teddy Bear', 'friendName': 'Alice', 'dueDate': '2024-12-20', 'status': 'Pending'},
    {'giftName': 'Laptop', 'friendName': 'Bob', 'dueDate': '2024-12-25', 'status': 'Delivered'},
    {'giftName': 'Book', 'friendName': 'Charlie', 'dueDate': '2024-12-18', 'status': 'Pending'},
  ];

  void _modifyGift(int index) {
    setState(() {
      pledgedGifts[index]['status'] = 'Modified';
    });
  }

  void _deleteGift(int index) {
    setState(() {
      pledgedGifts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.pinkAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: pledgedGifts.length,
          itemBuilder: (context, index) {
            final gift = pledgedGifts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(gift['giftName']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Friend: ${gift['friendName']}'),
                    Text('Due Date: ${gift['dueDate']}'),
                    Text('Status: ${gift['status']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (gift['status'] == 'Pending')
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _modifyGift(index),
                      ),
                    if (gift['status'] == 'Pending')
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteGift(index),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
