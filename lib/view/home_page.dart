import 'package:flutter/material.dart';
import 'event_list_page.dart'; // Import Event List Page
import 'gift_list_page.dart'; // Import Gift List Page
import 'profile_page.dart'; // Import Profile Page
import 'package:contacts_service/contacts_service.dart'; // For contacts access

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _friends = List.generate(10, (index) {
    return {
      'name': 'Friend $index',
      'profilePicture': 'https://via.placeholder.com/150', // Replace with friend's profile picture URL
      'upcomingEvents': index % 2 == 0 ? 1 : 0, // Mock data: 1 for upcoming events, 0 for no events
    };
  });

  List<Contact> _contacts = []; // To store contacts

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  // Fetch contacts from the device
  void _getContacts() async {
    final contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.toList();
    });
  }

  // Manually add friend dialog
  void _addFriendManually() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Friend Manually'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Friend Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Add logic for adding the friend manually (store data, etc.)
                Navigator.pop(context);
              },
              child: const Text('Add Friend'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Add friend from contacts dialog
  void _addFriendFromContacts() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Contact'),
          content: Container(
            height: 250,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ListTile(
                  title: Text(contact.displayName ?? 'No Name'),
                  subtitle: Text(contact.phones?.isNotEmpty == true
                      ? contact.phones!.first.value ?? 'No Phone'
                      : 'No Phone'),
                  onTap: () {
                    // Handle friend selection from contacts (add to the friend list)
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Search functionality
  void _searchFriends(String query) {
    // Here you can filter the list of friends based on the query (e.g., by name)
    setState(() {
      _friends = _friends
          .where((friend) =>
          friend['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hedieaty - Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
        actions: [
          // Profile Icon for navigating to Profile Page
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()), // Navigate to Profile Page
              );
            },
          ),
          TextButton.icon(
            onPressed: () {
              // Navigate to the Event List Page where user can add events
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EventListPage()), // Navigate to Event List Page
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Create Event/List',
              style: TextStyle(color: Colors.white),
            ),
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
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
                child: Material(
                  elevation: 5.0,
                  shadowColor: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for friends...',
                      prefixIcon:
                      const Icon(Icons.search, color: Colors.pinkAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _searchFriends,
                  ),
                ),
              ),

              // Add Friend Buttons (Above Friend List)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _addFriendManually,
                    child: const Text('Add Friend Manually'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _addFriendFromContacts,
                    child: const Text('Add from Contacts'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // List of Friends
              Expanded(
                child: ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: Duration(milliseconds: 500 + (index * 100)),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5.0,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              _friends[index]['profilePicture'],
                            ),
                            radius: 25,
                          ),
                          title: Text(
                            _friends[index]['name'],
                            style:
                            const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            _friends[index]['upcomingEvents'] > 0
                                ? 'Upcoming Events: ${_friends[index]['upcomingEvents']}'
                                : 'No Upcoming Events',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.pinkAccent,
                            size: 20,
                          ),
                          onTap: () {
                            // Navigate to Gift List Page for the selected friend
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GiftListPage(friendIndex: index),
                              ),
                            );
                          },
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
