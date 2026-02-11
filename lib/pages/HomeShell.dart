import 'package:flutter/material.dart';
import 'home_page.dart';
import 'medications_page.dart';
import 'healthcare_page.dart';
import 'profile_page.dart';

class HomeShell extends StatefulWidget {
  final String token;
  final String? name;

  const HomeShell({super.key, required this.token, this.name});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  late final pages = [
    HomePage(token: widget.token, name: widget.name),
    MedicationsPage(token: widget.token),
    HealthcarePage(),
    ProfilePage(token: widget.token),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE9E8),
      body: SafeArea(
        child: IndexedStack(
          index: index,
          children: pages,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F908B),
        onPressed: () {},
        child: const Icon(Icons.chat_bubble_outline),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        selectedItemColor: const Color(0xFF2F908B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Drugs'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Doctors'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
