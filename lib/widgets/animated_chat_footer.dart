import 'package:flutter/material.dart';

class AnimatedChatFooter extends StatefulWidget {
  final VoidCallback onTap;
  const AnimatedChatFooter({super.key, required this.onTap});

  @override
  State<AnimatedChatFooter> createState() => _AnimatedChatFooterState();
}

class _AnimatedChatFooterState extends State<AnimatedChatFooter>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    scale = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      child: ScaleTransition(
        scale: scale,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF6EBFB3), Color(0xFF4F9F96)],
              ),
            ),
            child: const Icon(Icons.chat, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
