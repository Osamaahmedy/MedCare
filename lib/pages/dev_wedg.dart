import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DevWedg extends StatefulWidget {
  const DevWedg({super.key});

  @override
  State<DevWedg> createState() => _DevWedgState();
}

class _DevWedgState extends State<DevWedg> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildCard({
    required String image,
    required String title,
    required String desc,
  }) {
    return Center(
      child: Container(
        height: 450,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 214, 246, 244),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                image,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3644),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF5A8E9E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 160, 227, 217),
      body: PageView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        children: [
          buildCard(
            image: "images/undraw_medical-care_7m9g.png",
            title: "Welcome",
            desc:
                "You are in safe hands here, where we will organize all your medications and remind you of your medication schedule.",
          ),
          buildCard(
            image: "images/undraw_medicine_hqqg.png",
            title: "Professional Doctors",
            desc:
                "There are many doctors who will help you and you can easily communicate with them.",
          ),
          buildCard(
            image: "images/undraw_meditation_vje0.png",
            title: "Maintain Your Health",
            desc:
                "Your health is always a priority. Take the right step and we will help you along the way.",
          ),
        ],
      ),
    );
  }
}