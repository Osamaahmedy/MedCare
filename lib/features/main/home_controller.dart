import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:my_app4/features/auth/login_page.dart';
import 'package:my_app4/features/main/pages/home_page.dart';
import 'package:my_app4/features/main/pages/medications_page.dart';
import 'package:my_app4/features/main/pages/health_page.dart';
import 'package:my_app4/features/main/pages/profile_page.dart';
import 'package:my_app4/features/main/widgets/chatbot_sheet.dart';

class MediCareApp1 extends StatefulWidget {
  final String token;
  final String? name;

  const MediCareApp1({super.key, required this.token, this.name});

  @override
  State<MediCareApp1> createState() => _MediCareApp1State();
}

class _MediCareApp1State extends State<MediCareApp1> {
  late final Dio dio;
  int currentIndex = 0;
  bool actionLoading = false;

  List<Map<String, dynamic>> medications = [];
  Map<String, dynamic> patientData = {};
  bool medicationsLoading = true;
  bool profileLoading = true;

  @override
  void initState() {
    super.initState();
    dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/',
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      },
    ));
    fetchMedications();
    fetchProfile();
  }

  // ✅ جلب الأدوية من API
  Future<void> fetchMedications() async {
    setState(() => medicationsLoading = true);
    try {
      final res = await dio.get('patient/medications');
      setState(() {
        medications = res.data['medications'] is List
            ? List<Map<String, dynamic>>.from(res.data['medications'])
            : [];
      });
    } catch (_) {
      setState(() => medications = []);
    } finally {
      setState(() => medicationsLoading = false);
    }
  }

  // ✅ جلب بيانات البروفايل من API بدل الـ hardcoded
  Future<void> fetchProfile() async {
    setState(() => profileLoading = true);
    try {
      final res = await dio.get('patient/profile');
      setState(() => patientData = Map<String, dynamic>.from(res.data['patient'] ?? {}));
    } catch (_) {
      setState(() => patientData = {'name': widget.name ?? 'Patient'});
    } finally {
      setState(() => profileLoading = false);
    }
  }

  // ✅ أخذ الدواء
  Future<void> takeMedication(int id) async {
    setState(() => actionLoading = true);
    try {
      await dio.patch(
        'patient/medications/$id/daily-dosage',
        data: {'daily_dosage_status': 'taken'},
      );
      await fetchMedications();
    } on DioException catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  // ✅ حذف الدواء من API
  Future<void> deleteMedication(int id) async {
    setState(() => actionLoading = true);
    try {
      await dio.delete('patient/medications/$id');
      await fetchMedications();
    } on DioException catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  // ✅ إضافة دواء بالحقول الصحيحة حسب API
  Future<void> addMedication(Map<String, dynamic> data) async {
    setState(() => actionLoading = true);
    try {
      await dio.post('patient/medications', data: data);
      await fetchMedications();
    } on DioException catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  // ✅ تحديث البروفايل عبر API
  Future<void> updateProfile(Map<String, dynamic> data) async {
    setState(() => actionLoading = true);
    try {
      await dio.put('patient/update', data: data);
      await fetchProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF4BA49C),
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  // ✅ Logout عبر API
  Future<void> logout() async {
    setState(() => actionLoading = true);
    try {
      await dio.post('patient/logout');
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showError(DioException e) {
    String msg = 'Something went wrong.';
    if (e.response?.statusCode == 422) {
      final errors = e.response?.data['errors'];
      if (errors != null && errors is Map) {
        msg = (errors.values.first as List).first.toString();
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.unknown) {
      msg = 'No internet connection.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void openChatBot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChatBotSheet(dio: dio),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        patientData: patientData,
        medications: medications,
        loading: medicationsLoading,
        actionLoading: actionLoading,
        onTakeMedication: takeMedication,
        onSeeAll: () => setState(() => currentIndex = 1),
        dio: dio,
      ),
      MedicationsPage(
        medications: medications,
        loading: medicationsLoading,
        actionLoading: actionLoading,
        onDelete: deleteMedication,
        onAdd: addMedication,
        onRefresh: fetchMedications,
      ),
      HealthPage(dio: dio),
      ProfilePage(
        patientData: patientData,
        loading: profileLoading,
        actionLoading: actionLoading,
        onUpdate: updateProfile,
        onLogout: logout,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          pages[currentIndex],
          if (actionLoading)
            Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(
                child: CupertinoActivityIndicator(radius: 16),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, CupertinoIcons.house_fill, CupertinoIcons.house, 'Home'),
              _navItem(1, CupertinoIcons.calendar_today, CupertinoIcons.calendar, 'Meds'),
              _navItem(2, CupertinoIcons.heart_fill, CupertinoIcons.heart, 'Health'),
              _navItem(3, CupertinoIcons.person_fill, CupertinoIcons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4BA49C).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? const Color(0xFF4BA49C) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? const Color(0xFF4BA49C) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF4BA49C), Color(0xFF2D6B65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4BA49C).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: openChatBot,
        child: const Icon(CupertinoIcons.chat_bubble_text_fill, color: Colors.white),
      ),
    );
  }
}
