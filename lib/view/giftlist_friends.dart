import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../models/event_model.dart';
import '../models/gift_model.dart';
import '../controllers/notification_controller.dart';

class GiftListScreen extends StatefulWidget {
  final String friendId;
  final String friendName;

  const GiftListScreen({
    Key? key,
    required this.friendId,
    required this.friendName,
  }) : super(key: key);

  @override
  _GiftListScreenState createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> {
  final HomeController _homeController = HomeController();
  final NotificationController _notificationController =
      NotificationController();
  late Future<List<EventModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _homeController.getFriendEvents(widget.friendId);
  }

  Future<List<Gift>> _fetchGiftsForEvent(String eventId) async {
    return await _homeController.getGiftsForEvent(eventId);
  }

  Future<void> _pledgeGift(Gift gift) async {
    if (gift.pledged) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Already Pledged"),
          content: const Text("This gift has already been pledged."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      try {
        
        final eventSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .doc(gift.eventId)
            .get();

        if (!eventSnapshot.exists) {
          throw Exception('Event not found.');
        }

        EventModel event =
            EventModel.fromFirestore(eventSnapshot.data()!, eventSnapshot.id);

        String creatorId = event.userId; 
        
        await _homeController.pledgeGift(gift.id, creatorId);

        
        final message = 'Someone has pledged to buy your gift: ${gift.name}!';
        await _notificationController.sendNotification(
            creatorId, gift.id, message);

        setState(() {}); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gift successfully pledged!'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to pledge gift. Error: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.friendName}'s Events & Gifts"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _eventsFuture,
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (eventSnapshot.hasError) {
            return Center(
              child: Text('Error: ${eventSnapshot.error}'),
            );
          } else if (eventSnapshot.data == null ||
              eventSnapshot.data!.isEmpty) {
            return const Center(
              child: Text('No events found for this friend.'),
            );
          }

          final events = eventSnapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, eventIndex) {
              final event = events[eventIndex];

              return ExpansionTile(
                title: Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle:
                    Text('Category: ${event.category}\nDate: ${event.date}'),
                children: [
                  FutureBuilder<List<Gift>>(
                    future: _fetchGiftsForEvent(event.id),
                    builder: (context, giftSnapshot) {
                      if (giftSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        );
                      } else if (giftSnapshot.hasError) {
                        return Center(
                          child: Text(
                              'Error loading gifts: ${giftSnapshot.error}'),
                        );
                      } else if (giftSnapshot.data == null ||
                          giftSnapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'No gifts found for this event.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        );
                      }

                      final gifts = giftSnapshot.data!;

                      return Column(
                        children: gifts.map((gift) {
                          return ListTile(
                            leading: gift.imageUrl != null
                                ? Image.network(
                                    gift.imageUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.card_giftcard,
                                    size: 40, color: Colors.pinkAccent),
                            title: Text(
                              gift.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                "Category: ${gift.category}\nPrice: \$${gift.price.toStringAsFixed(2)}"),
                            trailing: GestureDetector(
                              onTap: () => _pledgeGift(gift),
                              child: Icon(
                                gift.pledged
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color:
                                    gift.pledged ? Colors.green : Colors.grey,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
