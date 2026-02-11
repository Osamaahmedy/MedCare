import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../auth/login_page.dart';

class DevWedg extends StatefulWidget {
  const DevWedg({super.key});

  @override
  State<DevWedg> createState() => _DevWedgState();
}

class _DevWedgState extends State<DevWedg> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextAction() {
    if (currentIndex == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void prevPage() {
    if (currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget buildCard({
    required String image,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 214, 246, 244),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: 180,
              fit: BoxFit.contain,
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

  Widget buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: currentIndex == index ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? const Color(0xFF1A3644)
                : const Color(0xFF5A8E9E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 160, 227, 217),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                children: [
                  buildCard(
                    image: "assets/images/undraw_medical-care_7m9g.png",
                    title: "Welcome",
                    desc:
                        "You are in safe hands here, where we organize all your medications.",
                  ),
                  buildCard(
                    image: "assets/images/undraw_medicine_hqqg.png",
                    title: "Professional Doctors",
                    desc:
                        "Many professional doctors are ready to support and guide you.",
                  ),
                  buildCard(
                    image: "assets/images/undraw_meditation_vje0.png",
                    title: "Maintain Your Health",
                    desc:
                        "Your health is always a priority. We help you every step.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            buildDots(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  if (currentIndex > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: prevPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 214, 246, 244),
                          foregroundColor: const Color(0xFF1A3644),
                          shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(16),
             ),
                        ),
                        child: const Text(
                          'Previous',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (currentIndex > 0) const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: nextAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3644),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        currentIndex == 2 ? 'Finish' : 'Next',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
