import 'package:flutter/material.dart';
import 'my_pledged_gifts_page.dart'; // Import My Pledged Gifts Page

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock user data
  String userName = 'John Doe';
  String userEmail = 'johndoe@example.com';
  bool notificationsEnabled = true;

  // Mock created events and gifts data
  List<Map<String, String>> userEvents = [
    {
      'eventName': 'Birthday Bash',
      'eventDate': '2024-12-15',
    },
    {
      'eventName': 'Christmas Party',
      'eventDate': '2024-12-24',
    },
  ];

  List<Map<String, String>> userGifts = [
    {
      'giftName': 'Teddy Bear',
      'category': 'Toys',
    },
    {
      'giftName': 'Laptop',
      'category': 'Electronics',
    },
  ];

  // Function to toggle notification settings
  void _toggleNotifications(bool value) {
    setState(() {
      notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Information
            const Text(
              'Profile Information',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Name'),
              subtitle: Text(userName),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Handle editing name
                  setState(() {
                    userName = 'Jane Doe'; // Update name as an example
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Email'),
              subtitle: Text(userEmail),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Handle editing email
                  setState(() {
                    userEmail = 'janedoe@example.com'; // Update email as an example
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Notification Settings
            const Text(
              'Notification Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Enable Notifications'),
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: Colors.green,
              ),
            ),
            const SizedBox(height: 20),

            // User's Created Events
            const Text(
              'Your Created Events',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            for (var event in userEvents)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(event['eventName']!),
                  subtitle: Text('Date: ${event['eventDate']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      // Handle event details navigation
                    },
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // User's Gifts
            const Text(
              'Your Gifts',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            for (var gift in userGifts)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(gift['giftName']!),
                  subtitle: Text('Category: ${gift['category']}'),
                ),
              ),
            const SizedBox(height: 20),

            // Link to My Pledged Gifts Page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyPledgedGiftsPage(),
                  ),
                );
              },
              child: const Text('View My Pledged Gifts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
