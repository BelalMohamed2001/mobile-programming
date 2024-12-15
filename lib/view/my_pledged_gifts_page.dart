import 'package:flutter/material.dart';
import 'gift_details_page.dart'; // Import Gift Details Page

class MyPledgedGiftsPage extends StatefulWidget {
  const MyPledgedGiftsPage({super.key});

  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  // Mock data for pledged gifts
  List<Map<String, dynamic>> pledgedGifts = [
    {
      'giftName': 'Teddy Bear',
      'friendName': 'Alice',
      'dueDate': '2024-12-20',
      'status': 'Pending',
    },
    {
      'giftName': 'Laptop',
      'friendName': 'Bob',
      'dueDate': '2024-12-25',
      'status': 'Delivered',
    },
    {
      'giftName': 'Book',
      'friendName': 'Charlie',
      'dueDate': '2024-12-18',
      'status': 'Pending',
    },
  ];

  // Function to modify a pending gift
  void _modifyGift(int index) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => GiftDetailsPage(giftDetails: pledgedGifts[index]),
    //   ),
    // ).then((updatedGift) {
    //   // Update the gift in the list if it was modified
    //   if (updatedGift != null) {
    //     setState(() {
    //       pledgedGifts[index] = updatedGift;
    //     });
    //   }
    // });
  }

  // Function to delete a pledged gift
  void _deleteGift(int index) {
    setState(() {
      pledgedGifts.removeAt(index); // Remove the gift from the list
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
                title: Text(
                  gift['giftName'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
                    if (gift['status'] == 'Pending') // Only show modify/delete for pending gifts
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _modifyGift(index), // Modify gift
                      ),
                    if (gift['status'] == 'Pending')
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteGift(index), // Delete gift
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
