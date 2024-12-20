import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/gift_list_controller.dart';
import '../models/event_model.dart';
import '../models/gift_model.dart';
import '../models/auth_model.dart';
import 'my_pledged_gifts_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _authController = AuthController();
  final EventController _eventController = EventController();
  final GiftController _giftController = GiftController();

  UserModel? _currentUser;
  List<Map<String, dynamic>> _eventsWithGifts = [];
  bool _isLoading = true;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  /// Fetches and updates user profile information
  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authController.getCurrentUser();
      if (userId != null) {
        final user = await _authController.getUserProfile(userId);
        final eventsWithGifts = await _eventController.fetchEventsWithGifts(userId);

        setState(() {
          _currentUser = user;
          _eventsWithGifts = eventsWithGifts;
        });
      } else {
        print('User ID is null');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile. Please try again later.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Edits user profile information
  Future<void> _editProfileField(String field, String value) async {
    if (_currentUser != null) {
      UserModel updatedUser = UserModel(
        uid: _currentUser!.uid,
        name: field == 'name' ? value : _currentUser!.name,
        phoneNumber: field == 'phone' ? value : _currentUser!.phoneNumber,
        email: _currentUser!.email,
        friendList: _currentUser!.friendList,
      );

      await _authController.updateUser(updatedUser);
      setState(() {
        _currentUser = updatedUser;
      });
    }
  }

  /// Toggles notifications
  void _toggleNotifications(bool value) {
    setState(() => notificationsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.pinkAccent,
        ),
        body: const Center(
          child: Text(
            'Failed to load profile. Please try again later.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Header
          const Text(
            'Profile Information',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildEditableField('Name', _currentUser!.name ?? 'Not set'),
          _buildEditableField('Phone Number', _currentUser!.phoneNumber ?? 'Not set'),

          const SizedBox(height: 20),
          // Notification Settings
          const Text(
            'Notification Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Enable Notifications'),
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
              activeColor: Colors.green,
            ),
          ),

          const SizedBox(height: 20),
          // Created Events and Associated Gifts
          const Text(
            'Your Created Events and Gifts',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildEventList(),

          const SizedBox(height: 20),
          // My Pledged Gifts Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyPledgedGiftsPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            child: const Text('View My Pledged Gifts'),
          ),
        ],
      ),
    );
  }

  /// Builds a single editable field
  Widget _buildEditableField(String field, String? value) {
    return ListTile(
      title: Text(field),
      subtitle: Text(value ?? 'Not available'),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          String? updatedValue = await _showEditDialog(field, value ?? '');
          if (updatedValue != null) {
            await _editProfileField(field.toLowerCase(), updatedValue);
          }
        },
      ),
    );
  }

  /// Displays a list of user events and associated gifts
  Widget _buildEventList() {
    if (_eventsWithGifts.isEmpty) {
      return const Text('You have no events created.');
    }
    return Column(
      children: _eventsWithGifts.map((eventWithGifts) {
        final event = eventWithGifts['event'] as EventModel;
        final gifts = eventWithGifts['gifts'] as List<Gift>;

        return Card(
          child: ExpansionTile(
            title: Text(event.name),
            subtitle: Text('Date: ${event.date}'),
            children: [
              if (gifts.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Associated Gifts:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...gifts.map((gift) => ListTile(
                  title: Text(gift.name),
                  subtitle: Text('Category: ${gift.category}'),
                )),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No gifts associated with this event.'),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Shows the dialog for editing user info fields
  Future<String?> _showEditDialog(String field, String currentValue) async {
    String updatedValue = currentValue;
    return showDialog<String>(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          decoration: InputDecoration(hintText: 'Enter new $field'),
          onChanged: (value) => updatedValue = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, updatedValue),
            child: const Text('Save'),
          ),
        ],
      );
    });
  }
}