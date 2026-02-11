import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/medications_page.dart';
import '../widgets/animated_chat_footer.dart';
import '../pages/chat_page.dart';

class MainLayout extends StatefulWidget {
  final String token;
  const MainLayout({super.key, required this.token});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int index = 0;

  late final pages = [
    HomePage(token: widget.token),
    ProfilePage(token: widget.token),
    MedicationsPage(token: widget.token),
  ];

  void openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => setState(() => index = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.medication), label: 'Medications'),
            ],
          ),
          AnimatedChatFooter(onTap: () => openChat(context)),
        ],
      ),
    );
  }
}
