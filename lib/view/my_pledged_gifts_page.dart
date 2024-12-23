import 'package:flutter/material.dart';
import 'package:the_project/controllers/home_controller.dart';
import 'package:the_project/models/auth_model.dart';
import 'package:the_project/models/gift_model.dart';
import '../controllers/gift_list_controller.dart';

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
  final GiftController _giftController = GiftController();
  List<Gift> pledgedGifts = [];

  @override
  void initState() {
    super.initState();
    _loadPledgedGifts();
  }

  void _loadPledgedGifts() async {
    try {
      List<Gift> gifts =
          await _homeController.getUserPledgedGifts(widget.userId);
      for (var gift in gifts) {
        UserModel? friendOwner =
            await _homeController.getFriendOwnsGift(widget.userId, gift.id);
        gift.friendOwner = friendOwner?.name ?? "Unknown";
      }
      setState(() {
        pledgedGifts = gifts;
      });
    } catch (e) {
      print("Failed to load pledged gifts: $e");
    }
  }

  void _modifyGiftStatusDialog(Gift gift) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Update Gift Status'),
        content: Text('Do you want to mark this gift as delivered?'),
        actions: [
          TextButton(
            onPressed: () {
              _changeGiftStatus(gift, "Delivered"); 
              Navigator.pop(context);
            },
            child: Text('Deliver Gift'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);  
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}


 void _changeGiftStatus(Gift gift, String status) async {
  gift.status = status; 
  await _giftController.updateGiftStatus(gift.id, status);  
  setState(() {
    pledgedGifts[pledgedGifts.indexWhere((g) => g.id == gift.id)] = gift;
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
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        gift.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Friend: ${gift.friendOwner}'),
                          if (gift.dueDate != null)
                            Text(
                                'Due Date: ${gift.dueDate!}'),
                          Text('Status: ${gift.status}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (gift.status == "Pending")
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _modifyGiftStatusDialog(
                                  gift), 
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
