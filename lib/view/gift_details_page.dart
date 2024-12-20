import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../controllers/gift_list_controller.dart';
import '../models/gift_model.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift gift;
  final Function(Gift) onGiftUpdated; // Callback to notify changes in the gift

  const GiftDetailsPage({Key? key, required this.gift, required this.onGiftUpdated}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late bool _isPledged;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();
  final GiftController _giftController = GiftController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift.name);
    _categoryController = TextEditingController(text: widget.gift.category);
    _descriptionController = TextEditingController(text: widget.gift.description);
    _priceController = TextEditingController(text: widget.gift.price.toString());
    _isPledged = widget.gift.pledged;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _togglePledged() async {
    setState(() {
      _isPledged = !_isPledged;
    });

    final updatedGift = Gift(
      id: widget.gift.id,
      name: _nameController.text,
      category: _categoryController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      pledged: _isPledged,
      eventId: widget.gift.eventId,
      imageUrl: widget.gift.imageUrl,
    );

    await _giftController.updateGift(updatedGift, _imageFile);
    widget.onGiftUpdated(updatedGift); // Notify the GiftListPage of the change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Gift Name'),
              enabled: !_isPledged,
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              enabled: !_isPledged,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              enabled: !_isPledged,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              enabled: !_isPledged,
            ),
            GestureDetector(
              onTap: _isPledged ? null : _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.pinkAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imageFile == null
                    ? (widget.gift.imageUrl == null
                        ? const Center(child: Icon(Icons.camera_alt))
                        : Image.network(widget.gift.imageUrl!, fit: BoxFit.cover))
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Pledged'),
                Switch(
                  value: _isPledged,
                  onChanged: (value) {
                    _togglePledged();
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}