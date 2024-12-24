import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // Clipboard functionality
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomCardGenerator extends StatefulWidget {
  @override
  _CustomCardGeneratorState createState() => _CustomCardGeneratorState();
}

class _CustomCardGeneratorState extends State<CustomCardGenerator> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  XFile? _image;

  final String bitlyAccessToken =
      "233ab21f6c326352de92fb756b2a9e6cb456bbb2"; // Replace with your token

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  // Generate a short link using Bitly
  Future<String> _generateShortLink(String longUrl) async {
    final url = Uri.parse('https://api-ssl.bitly.com/v4/shorten');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $bitlyAccessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'long_url': longUrl}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['link'];
    } else {
      throw Exception('Failed to generate short link');
    }
  }

  // Copy the link to clipboard
  void _copyToClipboard(String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Create Custom Christmas Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Card Title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _receiverController,
              decoration: InputDecoration(
                labelText: 'Receiver Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _senderController,
              decoration: InputDecoration(
                labelText: 'Sender Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 40),
                    SizedBox(height: 8),
                    Text(
                      _image == null
                          ? 'Tap to pick an image'
                          : 'Image Selected',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty ||
                    _receiverController.text.isEmpty ||
                    _senderController.text.isEmpty ||
                    _descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                // Generate a long link
                final longLink =
                    'https://yourapp.com/card/${_titleController.text}';

                try {
                  // Generate a short link using Bitly
                  final shortLink = await _generateShortLink(longLink);

                  // Show the dialog with the generated link
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Card Link'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Share this link: $shortLink'),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _copyToClipboard(shortLink),
                            child: Text('Copy Link'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to generate link: $e')),
                  );
                }
              },
              child: Text('Generate Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            _image != null
                ? isWeb
                    ? Image.network(_image!.path,
                        height: 200, width: double.infinity, fit: BoxFit.cover)
                    : Image.file(File(_image!.path),
                        height: 200, width: double.infinity, fit: BoxFit.cover)
                : Container(),
          ],
        ),
      ),
    );
  }
}
