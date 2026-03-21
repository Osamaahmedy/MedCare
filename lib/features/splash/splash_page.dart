import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // ✅ نفس الحزمة المستخدمة
import '../onboarding/dev_wedg.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer; // ✅ nullable لتجنب memory leak

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _navigateToOnboarding);
  }

  void _navigateToOnboarding() {
    if (!mounted) return; // ✅ تأكد أن الـ widget لا يزال موجوداً
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const DevWedg(),
        // ✅ Fade transition بدل الانتقال المفاجئ
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ إلغاء الـ Timer عند الخروج
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // ✅ تدرج يتناسق مع باقي صفحات التطبيق
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7FD8CC), Color(0xFFB2EDE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // ✅ Logo مع animation ظهور + scale
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A3644).withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.jpeg',
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  duration: 600.ms,
                  curve: Curves.elasticOut, // ✅ تأثير ارتداد جميل
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            // ✅ اسم التطبيق مع animation تأخير
            const Text(
              'Med Care',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3644),
                letterSpacing: 1.2,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, delay: 300.ms),

            const SizedBox(height: 8),

            // ✅ tagline تحت الاسم
            const Text(
              'Your Health, Our Priority',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF3A7A8A),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms),

            const Spacer(),

            // ✅ Loading indicator في الأسفل
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Column(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: const Color(0xFF1A3644).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF3A7A8A),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}
