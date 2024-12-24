import 'dart:io';
import 'dart:ui';
import 'package:christmas/glassMorphism.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.black,
        title: Center(
            child: Text(
          'Kria Karta Natal & Tinan Foun',
          style: GoogleFonts.aladin(color: Colors.white, fontSize: 24),
        )),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/img2.jpeg'), fit: BoxFit.cover),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: GlassMorphismContainer(
                          child: ListView(
                            children: [
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Titulu Karta',
                                  labelStyle: TextStyle(color: Colors.white),
                                  prefixIcon: Icon(
                                    Icons.title,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(
                                  // Use the same font for the input text
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                onChanged: (value) => setState(() {}),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Mensagem',
                                  labelStyle: TextStyle(color: Colors.white),
                                  prefixIcon: Icon(Icons.description),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: Colors.white),
                                maxLines: 5,
                                onChanged: (value) => setState(() {}),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _receiverController,
                                decoration: InputDecoration(
                                  labelText: 'Receiver Name',
                                  labelStyle: TextStyle(color: Colors.white),
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: Colors.white),
                                onChanged: (value) => setState(() {}),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _senderController,
                                decoration: InputDecoration(
                                  labelText: 'Sender Name',
                                  labelStyle: TextStyle(color: Colors.white),
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: Colors.white),
                                onChanged: (value) => setState(() {}),
                              ),
                              SizedBox(height: 16),
                              InkWell(
                                onTap: _pickImage,
                                child: GlassMorphismContainer(
                                  child: Column(
                                    children: [
                                      Icon(Icons.camera_alt,
                                          color: Colors.white, size: 40),
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
                                      SnackBar(
                                          content: Text(
                                              'Please fill in all fields')),
                                    );
                                    return;
                                  }

                                  final longLink =
                                      'https://yourapp.com/card/${_titleController.text}';

                                  try {
                                    final shortLink =
                                        await _generateShortLink(longLink);

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
                                              onPressed: () =>
                                                  _copyToClipboard(shortLink),
                                              child: Text('Copy Link'),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to generate link: $e')),
                                    );
                                  }
                                },
                                child: Text('Kria Karta',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      child: Stack(
                        children: [
                          // Christmas background
                          Positioned.fill(
                            child: Image.asset(
                              'assets/img3.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Column(
                            children: [
                              if (_image != null)
                                isWeb
                                    ? Image.network(_image!.path,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover)
                                    : Image.file(File(_image!.path),
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover)
                              else
                                Container(
                                  height: 200,
                                  color: Colors.black.withOpacity(0.5),
                                  child: Center(
                                    child: Text('No Image Selected',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 100, left: 16, right: 16),
                                child: Column(
                                  children: [
                                    Text(
                                      _titleController.text.isEmpty
                                          ? 'Titulu Karta'
                                          : _titleController.text,
                                      style: GoogleFonts.lobster(
                                        // Use a festive font from Google Fonts
                                        color: Colors.red,
                                        fontSize: 30,
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      _descriptionController.text.isEmpty
                                          ? 'Mensagem'
                                          : _descriptionController.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      'To: ${_receiverController.text.isEmpty ? 'Receiver' : _receiverController.text}',
                                      style: GoogleFonts.lobster(
                                        // Use a festive font from Google Fonts
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'From: ${_senderController.text.isEmpty ? 'Sender' : _senderController.text}',
                                      style: GoogleFonts.lobster(
                                        // Use a festive font from Google Fonts
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
