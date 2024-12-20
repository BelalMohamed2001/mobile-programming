import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_project/controllers/auth_controller.dart';
import '../models/auth_model.dart';
import 'profile_page.dart';
import 'event_list_page.dart';
import 'giftlist_friends.dart';
import '../controllers/home_controller.dart';
import 'package:the_project/controllers/notification_controller.dart';
import 'package:the_project/models/notification_model.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final HomeController _homeController = HomeController();
  final AuthController _auth = AuthController();
  final NotificationController _notificationController = NotificationController();
  late StreamSubscription<List<NotificationModel>> _notificationSubscription;

  UserModel? _searchedUser;
  List<UserModel> _friendList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFriendList();
    
    // Initialize notifications for push notifications (without dialog)
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    String? currentUserId = await _auth.getCurrentUser(); 
    if (currentUserId != null) {
      _notificationSubscription = _notificationController.listenForUserNotifications(currentUserId).listen((notifications) {
        for (var notification in notifications) {
          if (!notification.isRead) {
            // Handle the notification and show system notifications if needed
            _showPushNotification(notification);
          }
        }
      });
    }
  }

  void _showPushNotification(NotificationModel notification) {
    // Here you can utilize a package like flutter_local_notifications to display the push notifications
    // This would show a system notification on the phone instead of a dialog
    // Ensure `flutter_local_notifications` is added in your pubspec.yaml and set up for real device usage
    
    print('Received notification: ${notification.message}');
    // Show Notification code goes here.
  }

  @override
  void dispose() {
    super.dispose();
    _notificationSubscription.cancel(); // Cancel notification stream when not needed
  }

  Future<void> _fetchFriendList() async {
    setState(() => _isLoading = true);
    try {
      String? currentUserId = await _auth.getCurrentUser();
      if (currentUserId != null) {
        List<UserModel> friends = await _homeController.getFriendList(currentUserId);
        setState(() {
          _friendList = friends;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friend list: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUserByPhone() async {
    final phone = _searchController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _homeController.searchUserByPhone(phone);
      setState(() {
        _searchedUser = user;
      });
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found with this phone number')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching user: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addFriend() async {
    if (_searchedUser == null) return;

    setState(() => _isLoading = true);
    try {
      String? currentUserId = await _auth.getCurrentUser();
      if (currentUserId != null) {
        await _homeController.addFriend(currentUserId, _searchedUser!.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend added successfully!')),
        );
        setState(() {
          _searchedUser = null;
        });
        _fetchFriendList();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding friend: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedieaty - Home'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                    child: Material(
                      elevation: 5.0,
                      shadowColor: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for friends by phone number...',
                          prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: (_) => _searchUserByPhone(),
                      ),
                    ),
                  ),
                  if (_searchedUser != null)
                    ListTile(
                      title: Text(_searchedUser!.name),
                      subtitle: Text(_searchedUser!.phoneNumber),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: _addFriend,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Friends:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_friendList.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _friendList.length,
                        itemBuilder: (context, index) {
                          final friend = _friendList[index];
                          return ListTile(
                            title: Text(friend.name),
                            subtitle: Text(friend.phoneNumber),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GiftListScreen(
                                    friendId: friend.uid,
                                    friendName: friend.name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  else
                    const Center(
                      child: Text('You have no friends yet.'),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventListPage()),
          );
        },
        label: const Text('Create Your Own Event/List'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}
