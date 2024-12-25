import 'dart:async';
import 'dart:ui';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCardGenerator extends StatefulWidget {
  @override
  _CustomCardGeneratorState createState() => _CustomCardGeneratorState();
}

class _CustomCardGeneratorState extends State<CustomCardGenerator> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  Uint8List? _cardImageBytes;
  GlobalKey widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Add listeners for live updates
    _titleController.addListener(_updatePreview);
    _descriptionController.addListener(_updatePreview);
    _receiverController.addListener(_updatePreview);
    _senderController.addListener(_updatePreview);
  }

  void _updatePreview() {
    setState(() {});
  }

  Future<void> _generateImage() async {
    try {
      final boundary = widgetKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      final image = await boundary?.toImage(pixelRatio: 3.0);
      final byteData = await image!.toByteData(format: ImageByteFormat.png);
      _cardImageBytes = byteData!.buffer.asUint8List();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Card generated successfully!'),
          action: SnackBarAction(
            label: 'Download',
            onPressed: _downloadImage,
          ),
          duration: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate image: $e')),
      );
    }
  }

  void _downloadImage() {
    if (_cardImageBytes != null) {
      final blob = html.Blob([_cardImageBytes!]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'christmas_card.png')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _receiverController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // Adjust for mobile screens

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
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img2.jpeg'),
            fit: BoxFit.cover, // Make background image cover entire screen
            alignment: Alignment.center,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildFormSection(),
          const SizedBox(height: 16),
          Container(
            height: 300,
            child: _buildCardPreviewMobile(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Form Section
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: _buildFormSection(),
          ),
        ),
        // Preview Section
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCardPreview(),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Titulu Karta',
            labelStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.title, color: Colors.white),
            border: OutlineInputBorder(),
          ),
          style: GoogleFonts.lobster(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Mensagem',
            labelStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.description, color: Colors.white),
            border: OutlineInputBorder(),
          ),
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18),
          maxLines: 5,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _receiverController,
          decoration: InputDecoration(
            labelText: 'Receiver Name',
            labelStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.person, color: Colors.white),
            border: OutlineInputBorder(),
          ),
          style: GoogleFonts.roboto(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _senderController,
          decoration: InputDecoration(
            labelText: 'Sender Name',
            labelStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.person_outline, color: Colors.white),
            border: OutlineInputBorder(),
          ),
          style: GoogleFonts.robotoCondensed(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _generateImage,
          child: Text(
            'Kria Karta',
            style: GoogleFonts.aladin(color: Colors.white, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildCardPreview() {
    return RepaintBoundary(
      key: widgetKey,
      child: Card(
        elevation: 4,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/img3.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 250,
                left: 16,
                right: 16,
              ),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      _titleController.text.isNotEmpty
                          ? _titleController.text
                          : 'Titulu Karta',
                      style: GoogleFonts.lobster(
                        color: Colors.red,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _descriptionController.text.isNotEmpty
                          ? _descriptionController.text
                          : 'Mensagem',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _receiverController.text.isNotEmpty
                          ? _receiverController.text
                          : 'Receiver Name',
                      style:
                          GoogleFonts.aladin(color: Colors.black, fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _senderController.text.isNotEmpty
                          ? _senderController.text
                          : 'Sender Name',
                      style:
                          GoogleFonts.aladin(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreviewMobile() {
    return RepaintBoundary(
      key: widgetKey,
      child: Card(
        elevation: 4,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/img3.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 50,
                left: 16,
                right: 16,
              ),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      _titleController.text.isNotEmpty
                          ? _titleController.text
                          : 'Titulu Karta',
                      style: GoogleFonts.lobster(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _descriptionController.text.isNotEmpty
                          ? _descriptionController.text
                          : 'Mensagem',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _receiverController.text.isNotEmpty
                          ? _receiverController.text
                          : 'Receiver Name',
                      style:
                          GoogleFonts.aladin(color: Colors.black, fontSize: 10),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _senderController.text.isNotEmpty
                          ? _senderController.text
                          : 'Sender Name',
                      style:
                          GoogleFonts.aladin(color: Colors.black, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
