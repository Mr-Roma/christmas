import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SecretMessageFeature extends StatefulWidget {
  const SecretMessageFeature({Key? key}) : super(key: key);

  @override
  _SecretMessageFeatureState createState() => _SecretMessageFeatureState();
}

class _SecretMessageFeatureState extends State<SecretMessageFeature>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recipientController.dispose();
    _messageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Secret Messages',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Search Messages'),
            Tab(text: 'Create Message'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildCreateTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Messages by Recipient Name:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _nameController,
            labelText: 'Enter Your Name',
            icon: Icons.search,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _searchMessages,
              child: const Text(
                'Search Messages',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create a New Secret Message:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _nameController,
            labelText: 'Sender Name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _recipientController,
            labelText: 'Recipient Name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _messageController,
            labelText: 'Enter Your Message',
            icon: Icons.message,
            maxLines: 5,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _sendMessage,
              child: const Text(
                'Send Message',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 16),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  void _searchMessages() async {
    final recipientName = _nameController.text.trim();
    if (recipientName.isEmpty) {
      _showSnackBar('Please enter a name');
      return;
    }
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('secret_messages')
          .where('recipient_name', isEqualTo: recipientName)
          .get();

      _showResultsDialog(snapshot.docs);
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _sendMessage() async {
    final sender = _nameController.text.trim();
    final recipient = _recipientController.text.trim();
    final message = _messageController.text.trim();
    if (recipient.isEmpty || message.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('secret_messages').add({
        'sender_name': sender,
        'recipient_name': recipient,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _nameController.clear();
      _recipientController.clear();
      _messageController.clear();
      _showSnackBar('Message sent successfully');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showResultsDialog(List<QueryDocumentSnapshot> messages) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Messages'),
        content: SizedBox(
          width: double.maxFinite,
          child: messages.isEmpty
              ? const Text('No messages found.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['message'] ?? ''),
                      subtitle: Text('From: ${data['sender_name'] ?? ''}'),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
