import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:my_app4/features/auth/login_page.dart';

class MediCareApp1 extends StatefulWidget {
  final String token;
  final String? name;

  const MediCareApp1({
    super.key,
    required this.token,
    this.name,
  });

  @override
  State<MediCareApp1> createState() => _MediCareApp1State();
}

class _MediCareApp1State extends State<MediCareApp1> {
  late final Dio dio;

  bool loading = true;
  bool actionLoading = false;
  String selectedMood = '';
  int currentIndex = 0;

  List<Map<String, dynamic>> medications = [];
  
  // بيانات Profile
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  int userAge = 0;

  @override
  void initState() {
    super.initState();

    dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api/',
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      ),
    );

    userName = widget.name ?? 'Patient';
    userEmail = 'patient@medicare.com';
    userPhone = '+967 777 123 456';
    userAge = 28;

    fetchMedications();
  }

  Future<void> fetchMedications() async {
    try {
      final res = await dio.get('patient/medications');

      setState(() {
        medications = res.data != null && res.data['medications'] is List
            ? List<Map<String, dynamic>>.from(res.data['medications'])
            : [];
        loading = false;
      });
    } catch (_) {
      setState(() {
        medications = [];
        loading = false;
      });
    }
  }

  Future<void> takeMedication(int id) async {
    setState(() => actionLoading = true);

    try {
      await dio.patch(
        'patient/medications/$id/daily-dosage',
        data: {'daily_dosage_status': 'taken'},
      );

      await fetchMedications();
    } catch (_) {
    } finally {
      setState(() => actionLoading = false);
    }
  }

  Future<void> sendMood(String mood) async {
    setState(() {
      selectedMood = mood;
      actionLoading = true;
    });

    try {
      final res = await dio.post(
        'patient/ai/mood',
        data: {'mood': mood},
      );

      final text = res.data != null && res.data['response'] != null
          ? res.data['response'].toString()
          : 'لا يوجد رد';

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Medical Advice'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (_) {
    } finally {
      setState(() => actionLoading = false);
    }
  }

  // الشات بوت الكامل
  void openChatBot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChatBotSheet(dio: dio),
    );
  }

  // Popup إضافة دواء
  void showAddMedicationDialog() {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    final dosageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Medication'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., 500mg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (e.g., 08:00)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4BA49C),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => actionLoading = true);
              
              try {
                await dio.post('patient/medications', data: {
                  'medication_name': nameController.text,
                  'dosage': dosageController.text,
                  'intake_time': timeController.text,
                });
                await fetchMedications();
              } catch (_) {}
              
              setState(() => actionLoading = false);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Popup تعديل Profile
  void showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: userName);
    final emailCtrl = TextEditingController(text: userEmail);
    final phoneCtrl = TextEditingController(text: userPhone);
    final ageCtrl = TextEditingController(text: userAge.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4BA49C),
            ),
            onPressed: () {
              setState(() {
                userName = nameCtrl.text;
                userEmail = emailCtrl.text;
                userPhone = phoneCtrl.text;
                userAge = int.tryParse(ageCtrl.text) ?? userAge;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2DFDF),
      body: Stack(
        children: [
          _buildBody(),
          if (actionLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        selectedItemColor: const Color(0xFF4BA49C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4BA49C),
        onPressed: openChatBot,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (loading && currentIndex == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildMedicationsPage();
      case 2:
        return _buildHealthPage();
      case 3:
        return _buildProfilePage();
      default:
        return const Center(child: Text('Page Not Found'));
    }
  }

 Widget _buildHomePage() {
  return Container(
    color: const Color(0xFFF8FAFB), // خلفية هادئة تبرز الكروت البيضاء
    child: SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _welcome(),
            const SizedBox(height: 25),
            _moodSection(),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Schedule",
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF2D3142),
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton(
                  onPressed: () { /* انتقل لصفحة الأدوية الكاملة */ },
                  child: const Text('See All', style: TextStyle(color: Color(0xFF4BA49C))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (medications.isEmpty)
              _buildEmptyMeds()
            else
              ...medications.map(_medItem).toList(),
          ],
        ),
      ),
    ),
  );
}
Widget _medItem(Map<String, dynamic> med) {
  final name = med['medication_name']?.toString() ?? 'Unknown';
  final time = med['intake_time']?.toString() ?? '--:--';
  final type = med['dosage_type']?.toString() ?? 'pill';
  final condition = med['medical_condition']?.toString() ?? 'General Health';
  
  // التحقق من حالة أخذ الدواء بناءً على القيمة المرسلة منك
  final bool isTaken = med['daily_dosage_status'] == 'taken';

  // تحديد الأيقونة بناءً على نوع الدواء
  IconData getMedIcon() {
    switch (type.toLowerCase()) {
      case 'syrup': return Icons.vaccines_rounded;
      case 'injection': return Icons.colorize_rounded;
      case 'capsule': return Icons.medication_rounded;
      default: return Icons.medication_liquid_rounded;
    }
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: IntrinsicHeight(
      child: Row(
        children: [
          // شريط جانبي يتغير لونه حسب الحالة (أخضر إذا تم الأخذ، وتيل إذا لم يتم)
          Container(
            width: 6,
            decoration: BoxDecoration(
              color: isTaken ? Colors.green : const Color(0xFF4BA49C),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // أيقونة نوع الدواء
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isTaken ? Colors.green : const Color(0xFF4BA49C)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(getMedIcon(), color: isTaken ? Colors.green : const Color(0xFF4BA49C), size: 28),
                  ),
                  const SizedBox(width: 16),
                  // تفاصيل الدواء
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 17, 
                            fontWeight: FontWeight.bold, 
                            color: const Color(0xFF2D3142),
                            decoration: isTaken ? TextDecoration.lineThrough : null, // خط على الاسم إذا تم الأخذ
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          condition,
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time_filled_rounded, 
                                 size: 14, 
                                 color: isTaken ? Colors.green : const Color(0xFF4BA49C)),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: TextStyle(
                                fontWeight: FontWeight.w900, 
                                fontSize: 13, 
                                color: isTaken ? Colors.green : const Color(0xFF4BA49C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // زر الأكشن (صح أو زر Take)
                  isTaken
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 30),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4BA49C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => takeMedication(med['id']),
                          child: const Text('Take', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildEmptyMeds() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
    ),
    child: Row(
      children: [
        Icon(Icons.done_all_rounded, color: Colors.green[300], size: 30),
        const SizedBox(width: 15),
        const Text(
          'All caught up for today!',
          style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}
Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4BA49C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF4BA49C), size: 28),
              ),
              const SizedBox(width: 12),
              const Text(
                'MediCare',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.w900, 
                  color: Color(0xFF2D3142),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // زر الإشعارات مع نقطة تنبيه
          Stack(
            children: [
              IconButton(
                onPressed: _showNotifications, // دالة لفتح الإشعارات
                icon: Icon(Icons.notifications_none_rounded, color: Colors.grey[800], size: 30),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _welcome() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4BA49C), const Color(0xFF3D8B84)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4BA49C).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good Morning,', // يمكنك تغييرها برمجياً حسب الوقت
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Stay healthy today!',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // أيقونة توضيحية للترحيب
          const Icon(Icons.wb_sunny_rounded, color: Colors.amberAccent, size: 50),
        ],
      ),
    );
  }

  // دالة لفتح الإشعارات بشكل أنيق
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No new notifications yet', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

 Widget _moodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            "How's your mood?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _moodBox('sad', Icons.sentiment_dissatisfied_rounded, Colors.orangeAccent),
                  _moodBox('neutral', Icons.sentiment_neutral_rounded, Colors.blueAccent),
                  _moodBox('happy', Icons.sentiment_very_satisfied_rounded, const Color(0xFF4BA49C)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _moodBox(String mood, IconData icon, Color moodColor) {
    final bool isSelected = selectedMood == mood;

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // يضمن استجابة اللمس في كامل المساحة
      onTap: () => sendMood(mood),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16), // مساحة لمس واسعة
            decoration: BoxDecoration(
              color: isSelected ? moodColor : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected 
                  ? [BoxShadow(color: moodColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))]
                  : [],
            ),
            child: Icon(
              icon,
              size: 42, // تكبير الأيقونة
              color: isSelected ? Colors.white : moodColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mood.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF2D3142) : Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildMedicationsPage() {
  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFB),
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header مع زر إضافة احترافي
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Meds',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                    ),
                    Text(
                      'Don\'t miss your dose',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: showAddMedicationDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4BA49C),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4BA49C).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 4),
                        Text('Add New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // قائمة الأدوية
          Expanded(
            child: medications.isEmpty
                ? _buildEmptyMedsState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: medications.length,
                    itemBuilder: (ctx, i) {
                      final med = medications[i];
                      return _buildMedicationCard(med);
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMedicationCard(Map<String, dynamic> med) {
  final name = med['medication_name']?.toString() ?? 'Unknown';
  final time = med['intake_time']?.toString() ?? '--:--';
  final dosage = med['dosage']?.toString() ?? '';

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 15,
          offset: const Offset(0, 8),
        )
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // أيقونة الدواء بتصميم مميز
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF4BA49C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.medication_liquid_rounded, color: Color(0xFF4BA49C), size: 30),
          ),
          const SizedBox(width: 16),
          // تفاصيل الدواء
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(width: 12),
                    Icon(Icons.scale_rounded, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(dosage, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          // زر الحذف بتصميم أنيق
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300]),
            onPressed: () {
              // منطق الحذف هنا
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildEmptyMedsState() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
          ),
          child: Icon(Icons.medical_services_outlined, size: 50, color: Colors.grey[300]),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your cabinet is empty',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add your medications to stay on track',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}
 Widget _buildHealthPage() {
    final consultants = [
      {'name': 'Dr. Ahmed Ali', 'specialty': 'Cardiologist', 'rating': '4.8', 'exp': '10y'},
      {'name': 'Dr. Fatima Hassan', 'specialty': 'Neurologist', 'rating': '4.9', 'exp': '8y'},
      {'name': 'Dr. Mohammed Salem', 'specialty': 'Dermatologist', 'rating': '4.7', 'exp': '12y'},
      {'name': 'Dr. Noor Abdullah', 'specialty': 'Pediatrician', 'rating': '4.6', 'exp': '5y'},
      {'name': 'Dr. Sara Ibrahim', 'specialty': 'Orthopedic', 'rating': '4.8', 'exp': '15y'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Your Specialist',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                  ),
                  const SizedBox(height: 15),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Color(0xFF4BA49C)),
                        hintText: 'Search for doctors or symptoms...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Consultants List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: consultants.length,
                itemBuilder: (ctx, i) {
                  final consultant = consultants[i];
                  return _buildDoctorCard(consultant);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, String> doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDoctorDetails(doctor),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with online status
              Stack(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4BA49C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        doctor['name']![4], // أول حرف من الاسم بعد "Dr. "
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4BA49C)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name']!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BA49C).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        doctor['specialty']!,
                        style: const TextStyle(color: Color(0xFF4BA49C), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(doctor['rating']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 10),
                        Text('(${doctor['exp']} exp)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Button
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFF4BA49C)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDoctorDetails(Map<String, String> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(doctor['name']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(doctor['specialty']!, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4BA49C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Book Appointment Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProfilePage() {
  return Scaffold(
    backgroundColor: Colors.grey[50],
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4BA49C).withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF4BA49C),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              userName,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 35),

            _profileInfoCard(
                'Phone Number', userPhone, Icons.phone_android_rounded),
            _profileInfoCard(
                'Your Age', '$userAge Years', Icons.cake_rounded),
            _profileInfoCard(
                'Blood Type', 'O+', Icons.bloodtype_rounded),

            const SizedBox(height: 25),

            // Privacy Card
            _profileActionCard(
              'Privacy Policy',
              Icons.privacy_tip_rounded,
              () {
                // افتح صفحة البرايفسي أو اعمل dialog
              },
            ),

            // Security Card
            _profileActionCard(
              'Security Settings',
              Icons.security_rounded,
              () {
                // افتح صفحة السكيورتي
              },
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4BA49C),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: showEditProfileDialog,
                icon: const Icon(Icons.edit_note_rounded, size: 26),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _profileActionCard(
    String title, IconData icon, VoidCallback onTap) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          blurRadius: 10,
        ),
      ],
    ),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF4BA49C)),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios_rounded, size: 18),
    ),
  );
}


 
  Widget _profileInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4BA49C), size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ============ CHATBOT SHEET ============
class ChatBotSheet extends StatefulWidget {
  final Dio dio;

  const ChatBotSheet({super.key, required this.dio});

  @override
  State<ChatBotSheet> createState() => _ChatBotSheetState();
}
class _ChatBotSheetState extends State<ChatBotSheet> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _sending = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _sending = true;
    });

    _msgController.clear();
    _scrollToBottom();

    try {
      final res = await widget.dio.post('patient/ai/chat', data: {'message': text});
      if (!mounted) return;

      final reply = res.data != null && res.data['response'] != null
          ? res.data['response'].toString()
          : 'I am here to help, but I couldn\'t get a response. Try again?';

      setState(() {
        _messages.add({'role': 'bot', 'text': reply});
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add({'role': 'bot', 'text': 'Connection issues. Please check your internet.'});
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFB), // لون خلفية هادئ جداً
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _messages.isEmpty ? _buildWelcomeState() : _buildMessageList(),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4BA49C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF4BA49C), size: 24),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
              Text('Powered by AI', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[400], size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: _messages.length + (_sending ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == _messages.length) return _buildTypingIndicator();
        final msg = _messages[i];
        final isUser = msg['role'] == 'user';
        return _buildModernBubble(msg['text']!, isUser);
      },
    );
  }

  Widget _buildModernBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF4BA49C) : Colors.white,
          gradient: isUser ? const LinearGradient(
            colors: [Color(0xFF4BA49C), Color(0xFF3D8B84)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser 
                ? const Color(0xFF4BA49C).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF2D3142),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
            child: const Icon(Icons.face_retouching_natural_rounded, size: 40, color: Color(0xFF4BA49C)),
          ),
          const SizedBox(height: 20),
          const Text('Hello! I\'m your medical ally.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('How can I assist your health today?', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: const Text('...', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4BA49C))),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent, // خليته شفاف عشان يعطي شكل عائم
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                controller: _msgController,
                decoration: const InputDecoration(
                  hintText: 'Type your symptoms...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              height: 52, width: 52,
              decoration: const BoxDecoration(
                color: Color(0xFF4BA49C),
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF4BA49C), Color(0xFF2D3142)], begin: Alignment.topLeft),
              ),
              child: _sending 
                ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}