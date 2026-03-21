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

  // ✅ ثابت لعدد الصفحات بدل الرقم الصلب 2 و 3
  static const int _totalPages = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void nextAction() {
    if (currentIndex == _totalPages - 1) {
      _goToLogin();
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          // ✅ تدرج داخل الكارد بدل اللون الصلب
          gradient: const LinearGradient(
            colors: [Color(0xFFE8FAF8), Color(0xFFCDF3EF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          // ✅ ظل خفيف يعطي عمق للكارد
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A3644).withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: 200, // ✅ أكبر قليلاً لملء المساحة
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 36),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3644),
                letterSpacing: 0.5, // ✅ تباعد أحرف خفيف
              ),
            ),
            const SizedBox(height: 14),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF5A8E9E),
                fontWeight: FontWeight.w500,
                height: 1.6, // ✅ تباعد أسطر أفضل للقراءة
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),
    );
  }

  Widget buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? const Color(0xFF1A3644)
                : const Color(0xFF5A8E9E).withOpacity(0.35),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ✅ تدرج في الخلفية بدل اللون الصلب
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7FD8CC), Color(0xFFB2EDE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ زر Skip في الأعلى
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Color(0xFF1A3644),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

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

              const SizedBox(height: 24),
              buildDots(),
              const SizedBox(height: 28),

              // ✅ الأزرار بـ height ثابت حتى لا يتغير الـ layout عند ظهور Previous
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // ✅ AnimatedOpacity بدل if لتجنب القفز في الـ layout
                    AnimatedOpacity(
                      opacity: currentIndex > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: SizedBox(
                        width: 110,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: currentIndex > 0 ? prevPage : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCDF3EF),
                            foregroundColor: const Color(0xFF1A3644),
                            elevation: 0,
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
                    ),
                    if (currentIndex > 0) const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 52, // ✅ ارتفاع موحد للزر
                        child: ElevatedButton(
                          onPressed: nextAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3644),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor:
                                const Color(0xFF1A3644).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            currentIndex == _totalPages - 1
                                ? 'Get Started'  // ✅ أوضح من Finish
                                : 'Next',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
