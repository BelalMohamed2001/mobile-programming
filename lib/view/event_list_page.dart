import 'package:flutter/material.dart';
import 'gift_list_page.dart'; // Import Gift List Page

class EventListPage extends StatefulWidget {
  final bool isFriendView; // Flag to differentiate between user and friend view
  final String friendName; // Friend's name (optional for friend view)

  const EventListPage({
    Key? key,
    this.isFriendView = false,
    this.friendName = '',
  }) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  // Example event data for the user and friends
  List<Map<String, dynamic>> _events = List.generate(5, (index) {
    return {
      'name': 'Event $index',
      'category': 'Category ${index % 3}',
      'status': index % 2 == 0 ? 'Upcoming' : 'Past',
      'description': 'This is a description of Event $index',
      'date': '2024-12-01', // Example date
    };
  });

  // Sort by: name, category, or status
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  // Sort the list of events
  void _sortEvents(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
      if (columnIndex == 0) {
        _events.sort((a, b) => a['name'].compareTo(b['name']) * (ascending ? 1 : -1));
      } else if (columnIndex == 1) {
        _events.sort((a, b) => a['category'].compareTo(b['category']) * (ascending ? 1 : -1));
      } else if (columnIndex == 2) {
        _events.sort((a, b) => a['status'].compareTo(b['status']) * (ascending ? 1 : -1));
      }
    });
  }

  // Function to handle adding a new event
  void _addEvent() {
    setState(() {
      _events.add({
        'name': 'New Event',
        'category': 'New Category',
        'status': 'Upcoming',
        'description': 'New event description',
        'date': '2024-12-10',
      });
    });
  }

  // Function to handle navigating to Event Details
  void _navigateToEventDetails(int index) async {
    // Navigate to the event details page
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftListPage(friendIndex: index), // Navigate to Gift List Page
      ),
    );

    if (updatedEvent != null) {
      setState(() {
        _events[index] = updatedEvent;
      });
    }
  }

  // Function to handle deleting an event
  void _deleteEvent(int index) {
    setState(() {
      _events.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFriendView
            ? "${widget.friendName}'s Event List"
            : 'My Event List'),
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.sort_by_alpha),
                  onPressed: () {
                    _sortEvents(0, !_isAscending);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.category),
                  onPressed: () {
                    _sortEvents(1, !_isAscending);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () {
                    _sortEvents(2, !_isAscending);
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(event['name']),
                      subtitle: Text('${event['category']} - ${event['status']}'),
                      tileColor: event['status'] == 'Upcoming'
                          ? Colors.green[100]
                          : Colors.red[100],
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!widget.isFriendView)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _navigateToEventDetails(index),
                            ),
                          if (!widget.isFriendView)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEvent(index),
                            ),
                        ],
                      ),
                      onTap: () => _navigateToEventDetails(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isFriendView
          ? null
          : FloatingActionButton.extended(
        onPressed: _addEvent,
        label: const Text('Add Event'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}
