import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class GiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic> giftDetails; // To pass the gift details

  const GiftDetailsPage({Key? key, required this.giftDetails}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  bool _isPledged = false;
  File? _imageFile; // Variable to store selected image file

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.giftDetails['giftName']);
    _categoryController = TextEditingController(text: widget.giftDetails['category']);
    _descriptionController = TextEditingController(text: widget.giftDetails['description']);
    _priceController = TextEditingController(text: widget.giftDetails['price'].toString());
    _isPledged = widget.giftDetails['status'] == 'Pledged';
  }

  // Function to pick image from the gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Gallery or Camera option

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Save the image as File
      });
    } else {
      print('No image selected');
    }
  }

  // Function to save the changes (this could be extended to save in a database)
  void _saveChanges() {
    Map<String, dynamic> updatedGift = {
      'giftName': _nameController.text,
      'category': _categoryController.text,
      'description': _descriptionController.text,
      'price': _priceController.text,
      'status': _isPledged ? 'Pledged' : 'Available',  // Ensure the correct status is saved
      'image': _imageFile, // Save image file if changed
    };

    // Return the updated gift to the previous screen (Gift List Page)
    Navigator.pop(context, updatedGift);  // Pass updated gift data back
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
            // Gift Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Gift Name'),
              enabled: !_isPledged, // Disable if the gift is pledged
            ),
            const SizedBox(height: 10),

            // Category
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              enabled: !_isPledged, // Disable if the gift is pledged
            ),
            const SizedBox(height: 10),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              enabled: !_isPledged, // Disable if the gift is pledged
            ),
            const SizedBox(height: 10),

            // Price
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              enabled: !_isPledged, // Disable if the gift is pledged
            ),
            const SizedBox(height: 10),

            // Image Upload
            GestureDetector(
              onTap: _isPledged ? null : _pickImage, // Disable image upload for pledged gifts
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.pinkAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imageFile == null
                    ? const Center(child: Icon(Icons.camera_alt))
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            // Pledge Status (Available / Pledged)
            Row(
              children: [
                const Text('Pledged'),
                Switch(
                  value: _isPledged,
                  onChanged: (value) {
                    // Allow toggle between Available and Pledged
                    setState(() {
                      _isPledged = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
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
