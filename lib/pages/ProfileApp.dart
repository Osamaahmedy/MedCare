import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key, required String token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Color(0xFFD2DFDF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // العنوان العلوي
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                 color: Color.fromARGB(255, 43, 70, 100),
                ),
              ),
              const SizedBox(height: 20),

              // كرت معلومات المستخدم الأساسية
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الصورة الشخصية (دائرة بها أحرف الاسم)
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: const Color(0xFFF0F2F5),
                          child: const Text(
                            "JD",
                            style: TextStyle(fontSize: 24, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // نصوص الاسم والتاريخ
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Samah',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                                     color: Color.fromARGB(255, 43, 70, 100),

                                    ),
                                  ),
                                  // زر التعديل Edit
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF1E634A)),
                                    label: const Text("Edit", style: TextStyle(color: Color(0xFF1E634A))),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF1E634A)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'Member since December 2025',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 15),
                              // أيقونات التواصل والمعلومات
                              infoDetail(Icons.email_outlined, "john.doe@example.com"),
                              infoDetail(Icons.phone_outlined, "+1 (555) 123-4567"),
                              infoDetail(Icons.calendar_today_outlined, "Born: January 15, 1985"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              // قائمة الخيارات (Notifications, Privacy, etc.
              optionTile(Icons.shield_outlined, "Privacy & Security", "Account protection"),
              optionTile(Icons.logout, "Sing Out","",),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت لعرض تفاصيل الإيميل والهاتف داخل الكرت
  Widget infoDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        ],
      ),
    );
  }

  // ويدجت لعرض الخيارات السفلية (Notifications, etc.)
  Widget optionTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color.fromARGB(255, 40, 60, 120)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color.fromARGB(255, 43, 70, 100)),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}