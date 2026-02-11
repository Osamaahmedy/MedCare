import 'package:flutter/material.dart';

class MedicationsPage extends StatelessWidget {
  final String token;
  const MedicationsPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE9E8),
      appBar: AppBar(title: const Text('Medications')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          action('Add Medication'),
          action('Edit Medication'),
          action('Delete Medication'),
          const SizedBox(height: 30),
          action('Consult Doctor', icon: Icons.call, highlight: true),
        ],
      ),
    );
  }

  Widget action(String title,
      {IconData icon = Icons.arrow_forward, bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF4F9F96) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: highlight ? Colors.white : Colors.black,
            ),
          ),
          Icon(icon, color: highlight ? Colors.white : Colors.grey),
        ],
      ),
    );
  }
}
