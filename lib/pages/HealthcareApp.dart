import 'package:flutter/material.dart';

void main() {
  runApp(const HealthcareApp());
}

class HealthcareApp extends StatelessWidget {
  const HealthcareApp({super.key, required String token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HealthcareScreen(),
    );
  }
}

class HealthcareScreen extends StatelessWidget {
  // قائمة بيانات تجريبية لمحاكاة التصميم
  final List<Map<String, dynamic>> consultants = [
    {
      "name": "Dr. Sarah Johnson",
      "specialty": "General Physician",
      "rating": "4.9",
      "reviews": "156",
      "location": "Medical Center, Downtown",
      "phone": "+1 (555) 123-4567",
      "email": "dr.johnson@medicare.com",
    },
    {
      "name": "Dr. Michael Chen",
      "specialty": "Cardiologist",
      "rating": "4.8",
      "reviews": "203",
      "location": "Heart Care Clinic",
      "phone": "+1 (555) 234-5678",
      "email": "dr.chen@medicare.com",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2DFDF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // العنوان الرئيسي
              const Text(
                'Healthcare Consultants',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const Text(
                'Connect with healthcare professionals',
                style: TextStyle(
                    color: Color.fromARGB(255, 51, 51, 89), fontSize: 16),
              ),
              const SizedBox(height: 20),
              // مربع البحث
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    // hintText: "Search tag here",

                    hintText: 'Search by name or specialty...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // قائمة الأطباء
              Expanded(
                child: ListView.builder(
                  itemCount: consultants.length,
                  itemBuilder: (context, index) {
                    return ConsultantCard(data: consultants[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ويدجت البطاقة (الكرت) الخاص بالطبيب
class ConsultantCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ConsultantCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الطبيب (Avatar)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F0ED),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.brown),
              ),
              const SizedBox(width: 15),
              // تفاصيل الطبيب
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        // شارة متاح (Available)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Available',
                            style: TextStyle(
                                color: Color.fromARGB(255, 52, 148, 55),
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Text(data['specialty'],
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    // التقييم
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          data['rating'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(" (${data['reviews']} reviews)",
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // معلومات التواصل
          infoRow(Icons.location_on_outlined, data['location']),
          infoRow(Icons.phone_outlined, data['phone']),
          infoRow(Icons.email_outlined, data['email']),
          const SizedBox(height: 15),
          // الأزرار
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, size: 18, color: Colors.white),
                  label:
                      const Text("Call", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 47, 144, 139),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.videocam_outlined,
                    size: 18,
                    color: Color(0xFF2C3E50),
                  ),
                  label: const Text("Video Call",
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                      )),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF2C3E50),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ويدجت مساعد لصفوف المعلومات (الموقع، الهاتف، الإيميل)
  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
