import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String token;
  const ProfilePage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE9E8),
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          item(Icons.person, 'Account Info'),
          item(Icons.lock, 'Privacy & Security'),
          item(Icons.logout, 'Logout', danger: true),
        ],
      ),
    );
  }

  Widget item(IconData icon, String title, {bool danger = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: danger ? Colors.red : Colors.teal),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: danger ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
