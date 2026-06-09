import 'package:flutter/material.dart';

class DonationScreen extends StatelessWidget {
  final Map<String, String> masjidData;

  const DonationScreen({super.key, required this.masjidData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabung Masjid'),
      ),
      body: Center(
        child: Text('Donation gateway for ${masjidData['name']} will load here.'),
      ),
    );
  }
}