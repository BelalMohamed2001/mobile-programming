import 'package:flutter/material.dart';
import 'package:the_project/controllers/home_controller.dart';
import 'package:the_project/models/auth_model.dart';
import 'gift_details_page.dart'; 
import 'package:the_project/models/gift_model.dart'; 

class MyPledgedGiftsPage extends StatefulWidget {
  final String userId;

  const MyPledgedGiftsPage({
    super.key,
    required this.userId,
  });

  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  final HomeController _homeController = HomeController();
  List<Gift> pledgedGifts = [];

  @override
  void initState() {
    super.initState();
    _loadPledgedGifts();
  }

  void _loadPledgedGifts() async {
    try {
      List<Gift> gifts = await _homeController.getUserPledgedGifts(widget.userId);
      for (var gift in gifts) {
        UserModel? friendOwner = await _homeController.getFriendOwnsGift(widget.userId, gift.id);
        gift.friendOwner = friendOwner?.name ?? "Unknown";
      }
      setState(() {
        pledgedGifts = gifts;
      });
    } catch (e) {
      print("Failed to load pledged gifts: $e");
    }
  }

  void _modifyGift(Gift gift) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(
          gift: gift,
          onGiftUpdated: (updatedGift) {
            setState(() {
              pledgedGifts[pledgedGifts.indexWhere((g) => g.id == updatedGift.id)] = updatedGift;
            });
          },
        ),
      ),
    );
  }

  void _deleteGift(Gift gift) async {
    // Implement deletion logic
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
        child: pledgedGifts.isEmpty
            ? const Center(
                child: Text(
                  "You have no pledged gifts.",
                  style: TextStyle(color: Colors.black54, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: pledgedGifts.length,
                itemBuilder: (context, index) {
                  final gift = pledgedGifts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        gift.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Friend: ${gift.friendOwner}'),
                         
                          Text('Status: ${gift.pledged ? 'Pending' : 'Delivered'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (gift.pledged)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _modifyGift(gift),
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
