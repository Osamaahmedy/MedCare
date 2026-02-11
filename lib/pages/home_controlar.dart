import 'package:flutter/material.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'ChatPot.dart';

class HomeControlar extends StatefulWidget {
  final String token;
  final Widget body;

  const HomeControlar({
    super.key,
    required this.token,
    required this.body,
  });

  @override
  State<HomeControlar> createState() => _HomeControlarState();
}

class _HomeControlarState extends State<HomeControlar> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.body,

      bottomNavigationBar: CrystalNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items:  [
          CrystalNavigationBarItem(icon: Icons.home_outlined),
          CrystalNavigationBarItem(icon: Icons.medication),
          CrystalNavigationBarItem(icon: Icons.person_outline),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4BA49C),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Chatpot(token: widget.token),
            ),
          );
        },
      ),
    );
  }
}
