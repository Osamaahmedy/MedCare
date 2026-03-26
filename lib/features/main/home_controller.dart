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

class _MediCareApp1State extends State<MediCareApp1>
    with TickerProviderStateMixin {
  late final Dio dio;
  int currentIndex = 0;
  int _prevIndex = 0;
  bool actionLoading = false;

  List<Map<String, dynamic>> medications = [];
  Map<String, dynamic> patientData = {};
  bool medicationsLoading = true;
  bool profileLoading = true;

  // ── Nav animation controllers ────────────────────────────
  late List<AnimationController> _navCtrls;
  late List<Animation<double>> _navScales;

  @override
  void initState() {
    super.initState();

    _navCtrls = List.generate(
      4,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );
    _navScales = _navCtrls
        .map((c) => Tween<double>(begin: 1.0, end: 1.18).animate(
              CurvedAnimation(parent: c, curve: Curves.elasticOut),
            ))
        .toList();

    // Activate first tab
    _navCtrls[0].forward();

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

  @override
  void dispose() {
    for (final c in _navCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _switchTab(int index) {
    if (index == currentIndex) return;
    _navCtrls[currentIndex].reverse();
    setState(() {
      _prevIndex = currentIndex;
      currentIndex = index;
    });
    _navCtrls[index].forward(from: 0);
  }

  // ── API calls ────────────────────────────────────────────
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

  Future<void> fetchProfile() async {
    setState(() => profileLoading = true);
    try {
      final res = await dio.get('patient/profile');
      setState(() => patientData =
          Map<String, dynamic>.from(res.data['patient'] ?? {}));
    } catch (_) {
      setState(() => patientData = {'name': widget.name ?? 'Patient'});
    } finally {
      setState(() => profileLoading = false);
    }
  }

  Future<void> takeMedication(int id) async {
    setState(() => actionLoading = true);
    try {
      await dio.patch('patient/medications/$id/daily-dosage',
          data: {'daily_dosage_status': 'taken'});
      await fetchMedications();
    } on DioException catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

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

  Future<void> updateProfile(Map<String, dynamic> data) async {
    setState(() => actionLoading = true);
    try {
      await dio.put('patient/update', data: data);
      await fetchProfile();
      if (mounted) {
        _showSuccessSnack('Profile updated successfully!');
      }
    } on DioException catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

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
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.xmark_circle_fill,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
    );
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.checkmark_circle_fill,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(msg),
          ],
        ),
        backgroundColor: const Color(0xFF4BA49C),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
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

  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        patientData: patientData,
        medications: medications,
        loading: medicationsLoading,
        actionLoading: actionLoading,
        onTakeMedication: takeMedication,
        onSeeAll: () => _switchTab(1),
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
      backgroundColor: const Color(0xFFF0F4F8),
      extendBody: true, // ← يخلي المحتوى يمتد تحت الـ navbar
      body: Stack(
        children: [
          // Page content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: child,
            ),
            child: KeyedSubtree(
              key: ValueKey(currentIndex),
              child: pages[currentIndex],
            ),
          ),

          // Global action loading overlay
          if (actionLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const CupertinoActivityIndicator(radius: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────
  Widget _buildBottomNav() {
    return _GlassNavBar(
      currentIndex: currentIndex,
      onTap: _switchTab,
      navScales: _navScales,
      items: const [
        _NavItem(
          activeIcon: CupertinoIcons.house_fill,
          inactiveIcon: CupertinoIcons.house,
          label: 'Home',
        ),
        _NavItem(
          activeIcon: Icons.medication, // Use Material icon for filled state
          inactiveIcon: CupertinoIcons.plus,
          label: 'Meds',
        ),
        _NavItem(
          activeIcon: CupertinoIcons.heart_fill,
          inactiveIcon: CupertinoIcons.heart,
          label: 'Health',
        ),
        _NavItem(
          activeIcon: CupertinoIcons.person_fill,
          inactiveIcon: CupertinoIcons.person,
          label: 'Profile',
        ),
      ],
    );
  }

  // ── FAB ──────────────────────────────────────────────────
  Widget _buildFAB() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF4BA49C), Color(0xFF2D6B65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4BA49C).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: openChatBot,
        child: const Icon(CupertinoIcons.chat_bubble_text_fill,
            color: Colors.white, size: 24),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GLASS NAV BAR WIDGET
// ─────────────────────────────────────────────────────────────
class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<Animation<double>> navScales;
  final List<_NavItem> items;

  const _GlassNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.navScales,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: bottomPad + 10,
          ),
          decoration: BoxDecoration(
            // Frosted glass
            color: Colors.white.withOpacity(0.88),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left two items
              Expanded(child: _buildItem(0)),
              Expanded(child: _buildItem(1)),
              // Center gap for FAB
              const SizedBox(width: 72),
              // Right two items
              Expanded(child: _buildItem(2)),
              Expanded(child: _buildItem(3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final isSelected = currentIndex == index;
    final item = items[index];
    const activeColor = Color(0xFF4BA49C);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: ScaleTransition(
        scale: navScales[index],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated indicator pill
              Stack(
                alignment: Alignment.center,
                children: [
                  // Background pill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 48 : 0,
                    height: isSelected ? 36 : 0,
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Icon(
                    isSelected ? item.activeIcon : item.inactiveIcon,
                    color: isSelected ? activeColor : Colors.grey[400],
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? activeColor : Colors.grey[400],
                ),
                child: Text(item.label),
              ),
              // Active dot indicator
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: isSelected ? 18 : 0,
                height: isSelected ? 3 : 0,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Nav Item model ───────────────────────────────────────────
class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}