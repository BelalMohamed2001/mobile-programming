import 'package:flutter/material.dart';
import 'gift_details_page.dart'; // Import Gift Details Page

class GiftListPage extends StatefulWidget {
  final int friendIndex; // To identify which friend's list is being viewed

  const GiftListPage({Key? key, required this.friendIndex}) : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Map<String, dynamic>> _gifts = List.generate(5, (index) {
    return {
      'name': 'Gift $index',
      'category': 'Category ${index % 3}',
      'status': index % 2 == 0 ? 'Available' : 'Pledged',
      'description': 'This is a description of Gift $index',
      'price': (index + 1) * 10.0,
    };
  });

  int _sortColumnIndex = 0;
  bool _isAscending = true;

  void _sortGifts(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
      if (columnIndex == 0) {
        _gifts.sort((a, b) => a['name'].compareTo(b['name']) * (ascending ? 1 : -1));
      } else if (columnIndex == 1) {
        _gifts.sort((a, b) => a['category'].compareTo(b['category']) * (ascending ? 1 : -1));
      } else if (columnIndex == 2) {
        _gifts.sort((a, b) => a['status'].compareTo(b['status']) * (ascending ? 1 : -1));
      }
    });
  }

  void _addGift() {
    setState(() {
      _gifts.add({
        'name': 'New Gift',
        'category': 'New Category',
        'status': 'Available',
        'description': 'New gift description',
        'price': 20.0,
      });
    });
  }

  void _navigateToGiftDetails(int index) async {
    final updatedGift = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(giftDetails: _gifts[index]),
      ),
    );

    if (updatedGift != null) {
      setState(() {
        _gifts[index] = updatedGift;
      });
    }
  }

  void _deleteGift(int index) {
    setState(() {
      _gifts.removeAt(index);
    });
  }

  void _togglePledgeStatus(int index) {
    setState(() {
      _gifts[index]['status'] = _gifts[index]['status'] == 'Available' ? 'Pledged' : 'Available';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift List'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addGift,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.pinkAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.sort_by_alpha),
                    onPressed: () {
                      _sortGifts(0, !_isAscending);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.category),
                    onPressed: () {
                      _sortGifts(1, !_isAscending);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () {
                      _sortGifts(2, !_isAscending);
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _gifts.length,
                  itemBuilder: (context, index) {
                    final gift = _gifts[index];
                    return GestureDetector(
                      onTap: () => _navigateToGiftDetails(index), // Navigate to Gift Details Page
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(gift['name']),
                          subtitle: Text('${gift['category']} - ${gift['status']}'),
                          tileColor: gift['status'] == 'Pledged' ? Colors.green[100] : null, // Color-coded based on pledge status
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _navigateToGiftDetails(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteGift(index), // Call delete function
                              ),
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.orange),
                                onPressed: () => _togglePledgeStatus(index), // Call toggle status function
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
