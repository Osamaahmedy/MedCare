import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final List<Map<String, dynamic>> medications;
  final bool loading;
  final bool actionLoading;
  final Future<void> Function(int) onTakeMedication;
  final VoidCallback onSeeAll;
  final Dio dio;

  const HomePage({
    super.key,
    required this.patientData,
    required this.medications,
    required this.loading,
    required this.actionLoading,
    required this.onTakeMedication,
    required this.onSeeAll,
    required this.dio,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedMood = '';
  bool moodLoading = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData get _greetingIcon {
    final hour = DateTime.now().hour;
    if (hour < 12) return CupertinoIcons.sun_max_fill;
    if (hour < 17) return CupertinoIcons.cloud_sun_fill;
    return CupertinoIcons.moon_stars_fill;
  }

  Color get _greetingColor {
    final hour = DateTime.now().hour;
    if (hour < 12) return Colors.amberAccent;
    if (hour < 17) return Colors.orangeAccent;
    return Colors.indigo.shade200;
  }

  Future<void> _sendMood(String mood) async {
    setState(() {
      selectedMood = mood;
      moodLoading = true;
    });
    try {
      final res = await widget.dio.post('patient/ai/mood', data: {'mood': mood});
      final text = res.data['response']?.toString() ?? 'No advice available.';
      if (!mounted) return;
      _showMoodDialog(mood, text);
    } catch (_) {
      if (!mounted) return;
      _showMoodDialog(mood, 'Could not get advice. Please check your connection.');
    } finally {
      if (mounted) setState(() => moodLoading = false);
    }
  }

  void _showMoodDialog(String mood, String text) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('${mood[0].toUpperCase()}${mood.substring(1)} Mood Advice'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(text),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Icon(CupertinoIcons.bell_slash, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No new notifications yet',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.patientData['name']?.toString() ?? 'Patient';

    return Container(
      color: const Color(0xFFF8FAFB),
      child: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF4BA49C),
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(name),
                const SizedBox(height: 20),
                _buildWelcomeCard(name),
                const SizedBox(height: 24),
                _buildMoodSection(),
                const SizedBox(height: 28),
                _buildScheduleHeader(),
                const SizedBox(height: 12),
                if (widget.loading)
                  const Center(child: CupertinoActivityIndicator())
                else if (widget.medications.isEmpty)
                  _buildEmptyMeds()
                else
                  ...widget.medications.take(3).map(_buildMedItem),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4BA49C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(CupertinoIcons.heart_fill,
                  color: Color(0xFF4BA49C), size: 26),
            ),
            const SizedBox(width: 10),
            const Text(
              'MediCare',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D3142),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              onPressed: _showNotifications,
              icon: Icon(CupertinoIcons.bell,
                  color: Colors.grey[700], size: 26),
            ),
            Positioned(
              right: 12, top: 12,
              child: Container(
                height: 9, width: 9,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4BA49C), Color(0xFF2D6B65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4BA49C).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting,',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Stay healthy today! 💊',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Icon(_greetingIcon, color: _greetingColor, size: 52),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How's your mood?",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142)),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _moodBox('sad', CupertinoIcons.smiley, Colors.orangeAccent),
                  _moodBox('neutral', CupertinoIcons.smiley, Colors.blueAccent),
                  _moodBox('happy', CupertinoIcons.smiley, const Color(0xFF4BA49C)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _moodBox(String mood, IconData icon, Color moodColor) {
    final emojis = {'sad': '😔', 'neutral': '😐', 'happy': '😊'};
    final isSelected = selectedMood == mood;

    return GestureDetector(
      onTap: moodLoading ? null : () => _sendMood(mood),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? moodColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? moodColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(emojis[mood]!, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            Text(
              mood[0].toUpperCase() + mood.substring(1),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? moodColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today's Schedule",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: widget.onSeeAll,
          child: const Text('See All',
              style: TextStyle(color: Color(0xFF4BA49C), fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildMedItem(Map<String, dynamic> med) {
    final name = med['medication_name']?.toString() ?? 'Unknown';
    final time = med['intake_time']?.toString() ?? '--:--';
    final type = med['dosage_type']?.toString() ?? 'pill';
    final condition = med['medical_condition']?.toString() ?? '';
    final isTaken = med['daily_dosage_status'] == 'taken';

    final Map<String, IconData> typeIcons = {
      'syrup': CupertinoIcons.drop_fill,
      'injection': CupertinoIcons.bandage_fill,
      'capsule': CupertinoIcons.capsule_fill,
      'pill': CupertinoIcons.capsule,
    };
    final medIcon = typeIcons[type.toLowerCase()] ?? CupertinoIcons.capsule;
    final color = isTaken ? Colors.green : const Color(0xFF4BA49C);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(medIcon, color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3142),
                              decoration: isTaken
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (condition.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(condition,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12)),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(CupertinoIcons.clock_fill,
                                  size: 12, color: color),
                              const SizedBox(width: 4),
                              Text(time,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: color)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isTaken
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.checkmark_circle_fill,
                                color: Colors.green, size: 28),
                          )
                        : CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            color: const Color(0xFF4BA49C),
                            borderRadius: BorderRadius.circular(12),
                            minSize: 0,
                            onPressed: () => widget.onTakeMedication(med['id']),
                            child: const Text('Take',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
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
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.checkmark_seal_fill,
              color: Colors.green[300], size: 28),
          const SizedBox(width: 14),
          const Text(
            'All caught up for today!',
            style: TextStyle(
                color: Color(0xFF2D3142), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
