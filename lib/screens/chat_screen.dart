import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final Map<String, String> masjidData;

  const ChatScreen({super.key, required this.masjidData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${masjidData['name']} Community'),
      ),
      body: Center(
        child: Text('Live chat room for ID: ${masjidData['id']} will load here.'),
      ),
    );
  }
}