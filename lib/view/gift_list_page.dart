import 'package:flutter/material.dart';
import '../controllers/gift_list_controller.dart';
import '../models/gift_model.dart';
import 'gift_details_page.dart';

class GiftListPage extends StatefulWidget {
  final String eventId;

  const GiftListPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftController _giftController = GiftController();
  List<Gift> _gifts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  // Load gifts from Firestore
  Future<void> _loadGifts() async {
    setState(() => _isLoading = true);
    _gifts = await _giftController.fetchGifts(widget.eventId);
    setState(() => _isLoading = false);
  }

  // Delete a gift
  void _deleteGift(String id) async {
    await _giftController.deleteGift(id);
    _loadGifts();
  }

  // Show dialog to add or edit gift
  Future<void> _editGiftDialog(Gift? gift) async {
    TextEditingController nameController =
        TextEditingController(text: gift?.name ?? '');
    TextEditingController descriptionController =
        TextEditingController(text: gift?.description ?? '');
    TextEditingController categoryController =
        TextEditingController(text: gift?.category ?? '');
    TextEditingController priceController =
        TextEditingController(text: gift?.price?.toString() ?? '0.0');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(gift == null ? 'Add Gift' : 'Edit Gift'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Gift Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Gift Description'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedGift = Gift(
                  id: gift?.id ?? '',
                  eventId: widget.eventId,
                  name: nameController.text,
                  description: descriptionController.text,
                  category: categoryController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  pledged: gift?.pledged ?? false, // Maintain current pledged status
                );

                if (gift == null) {
                  await _giftController.addGift(updatedGift, null);
                } else {
                  await _giftController.updateGift(updatedGift, null);
                }

                Navigator.pop(context);
                _loadGifts();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift List'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gifts.isEmpty
              ? const Center(child: Text('No gifts available.'))
              : ListView.builder(
                  itemCount: _gifts.length,
                  itemBuilder: (context, index) {
                    final gift = _gifts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: gift.pledged ? Colors.green.shade100 : null, // Color the card if pledged
                      child: ListTile(
                        title: Text(gift.name),
                        subtitle: Text('Price: \$${gift.price.toString()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: gift.pledged
                                  ? null // Disable edit if pledged
                                  : () => _editGiftDialog(gift),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: gift.pledged
                                  ? null // Disable delete if pledged
                                  : () => _deleteGift(gift.id),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftDetailsPage(
                                gift: gift,
                                onGiftUpdated: (updatedGift) {
                                  setState(() {
                                    // Update the gift locally in the list
                                    final index = _gifts.indexWhere((g) => g.id == updatedGift.id);
                                    if (index != -1) _gifts[index] = updatedGift;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editGiftDialog(null), // Adding a new gift
        tooltip: 'Add Gift',
        child: const Icon(Icons.add),
      ),
    );
  }
}