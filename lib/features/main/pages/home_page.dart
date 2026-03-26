import 'dart:ui';
import 'dart:math' as math;
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

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  String selectedMood = '';
  bool moodLoading = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  // ─── Greeting ─────────────────────────────────────────────
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData get _greetingIcon {
    final h = DateTime.now().hour;
    if (h < 12) return CupertinoIcons.sun_max_fill;
    if (h < 17) return CupertinoIcons.cloud_sun_fill;
    return CupertinoIcons.moon_stars_fill;
  }

  Color get _greetingColor {
    final h = DateTime.now().hour;
    if (h < 12) return Colors.amberAccent;
    if (h < 17) return Colors.orangeAccent;
    return Colors.indigo.shade200;
  }

  // ─── Stats ────────────────────────────────────────────────
  int get _takenCount => widget.medications
      .where((m) => m['daily_dosage_status'] == 'taken')
      .length;
  int get _totalCount => widget.medications.length;
  double get _progress =>
      _totalCount == 0 ? 0 : _takenCount / _totalCount;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6, end: 6)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  // ─── Mood API ─────────────────────────────────────────────
  Future<void> _sendMood(String mood) async {
    setState(() {
      selectedMood = mood;
      moodLoading = true;
    });

    // Show the beautiful loading overlay immediately
    _showMoodLoadingOverlay(mood);

    try {
      final res =
          await widget.dio.post('patient/ai/mood', data: {'mood': mood});
      final text =
          res.data['response']?.toString() ?? 'No advice available.';
      if (!mounted) return;
      Navigator.pop(context); // close loading
      await Future.delayed(const Duration(milliseconds: 200));
      _showMoodResponse(mood, text);
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 200));
      _showMoodResponse(
          mood, 'Could not get advice. Please check your connection.');
    } finally {
      if (mounted) setState(() => moodLoading = false);
    }
  }

  // ─── Mood Loading Overlay ─────────────────────────────────
  void _showMoodLoadingOverlay(String mood) {
    const moodData = {
      'sad': {
        'emoji': '😔',
        'label': 'Analyzing your feelings...',
        'color': Color(0xFFFF8C42),
        'bg': Color(0xFFFFF5EE),
        'particles': ['💛', '🌤', '✨', '🌸'],
      },
      'neutral': {
        'emoji': '😐',
        'label': 'Getting personalized tips...',
        'color': Color(0xFF4A90D9),
        'bg': Color(0xFFF0F7FF),
        'particles': ['💙', '⭐', '🌀', '💫'],
      },
      'happy': {
        'emoji': '😊',
        'label': 'Celebrating with you...',
        'color': Color(0xFF4BA49C),
        'bg': Color(0xFFF0FAF9),
        'particles': ['💚', '🌟', '🎉', '✨'],
      },
    };

    final data = moodData[mood]!;
    final color = data['color'] as Color;
    final bg = data['bg'] as Color;
    final emoji = data['emoji'] as String;
    final label = data['label'] as String;
    final particles = data['particles'] as List<String>;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => _MoodLoadingDialog(
        mood: mood,
        color: color,
        bg: bg,
        emoji: emoji,
        label: label,
        particles: particles,
      ),
    );
  }

  // ─── Mood Response Sheet ──────────────────────────────────
  void _showMoodResponse(String mood, String text) {
    const moodMeta = {
      'sad': {
        'emoji': '😔',
        'gradient': [Color(0xFFFF8C42), Color(0xFFFFB347)],
        'title': 'Feeling Down?',
        'subtitle': "Here's some care for you",
      },
      'neutral': {
        'emoji': '😐',
        'gradient': [Color(0xFF4A90D9), Color(0xFF74B9FF)],
        'title': 'Staying Balanced',
        'subtitle': 'Tips to boost your day',
      },
      'happy': {
        'emoji': '😊',
        'gradient': [Color(0xFF4BA49C), Color(0xFF2D6B65)],
        'title': "You're Glowing!",
        'subtitle': 'Keep up the great energy',
      },
    };

    final meta = moodMeta[mood]!;
    final gradient = meta['gradient'] as List<Color>;
    final emoji = meta['emoji'] as String;
    final title = meta['title'] as String;
    final subtitle = meta['subtitle'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoodResponseSheet(
        emoji: emoji,
        gradient: gradient,
        title: title,
        subtitle: subtitle,
        text: text,
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
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4BA49C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(CupertinoIcons.bell_fill,
                      color: Color(0xFF4BA49C), size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Notifications',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8), shape: BoxShape.circle),
              child:
                  Icon(CupertinoIcons.bell_slash, size: 40, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            const Text('No new notifications yet',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final name = widget.patientData['name']?.toString() ?? 'Patient';
    final firstName = name.split(' ').first;

    return Container(
      color: const Color(0xFFF0F4F8),
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
                _buildHeader(),
                const SizedBox(height: 20),
                _buildWelcomeCard(firstName),
                const SizedBox(height: 16),
                if (!widget.loading && _totalCount > 0)
                  _buildProgressCard(),
                const SizedBox(height: 16),
                _buildQuickStats(),
                const SizedBox(height: 28),
                _buildMoodSection(),
                const SizedBox(height: 28),
                _buildScheduleHeader(),
                const SizedBox(height: 12),
                if (widget.loading)
                  _buildMedSkeleton()
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

  // ─── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF4BA49C), Color(0xFF2D6B65)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF4BA49C).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Icon(CupertinoIcons.heart_fill,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        const Text('MediCare',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D3142),
                letterSpacing: -0.5)),
        const Spacer(),
        Stack(
          children: [
            GestureDetector(
              onTap: _showNotifications,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child:
                    Icon(CupertinoIcons.bell, color: Colors.grey[700], size: 22),
              ),
            ),
            Positioned(
              right: 8, top: 8,
              child: Container(
                height: 9, width: 9,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Welcome Card ─────────────────────────────────────────
  Widget _buildWelcomeCard(String firstName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4BA49C), Color(0xFF2D6B65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF4BA49C).withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 12))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07)),
            ),
          ),
          Positioned(
            bottom: -10, right: 60,
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07)),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_greetingIcon, color: _greetingColor, size: 16),
                        const SizedBox(width: 5),
                        Text(_greeting,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(firstName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Stay healthy today 💊',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _floatAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _floatAnim.value),
                  child: child,
                ),
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_greetingIcon, color: _greetingColor, size: 42),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Progress Card ────────────────────────────────────────
  Widget _buildProgressCard() {
    final percent = (_progress * 100).toInt();
    final Color progressColor;
    final String progressLabel;
    if (_progress == 1.0) {
      progressColor = Colors.green;
      progressLabel = 'All done! 🎉';
    } else if (_progress >= 0.5) {
      progressColor = const Color(0xFF4BA49C);
      progressLabel = 'Good progress!';
    } else {
      progressColor = Colors.orange;
      progressLabel = 'Keep going!';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Today's Progress",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700])),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(progressLabel,
                    style: TextStyle(
                        fontSize: 12,
                        color: progressColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[100],
                    color: progressColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('$_takenCount/$_totalCount',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progressColor)),
            ],
          ),
          const SizedBox(height: 6),
          Text('$percent% of today\'s medications taken',
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  // ─── Quick Stats ──────────────────────────────────────────
  Widget _buildQuickStats() {
    final age = widget.patientData['age']?.toString() ?? '--';
    return Row(
      children: [
        _quickStatCard(
            icon: CupertinoIcons.capsule_fill,
            label: 'Medications',
            value: '$_totalCount',
            color: const Color(0xFF4BA49C)),
        const SizedBox(width: 12),
        _quickStatCard(
            icon: CupertinoIcons.checkmark_seal_fill,
            label: 'Taken Today',
            value: '$_takenCount',
            color: Colors.green),
        const SizedBox(width: 12),
        _quickStatCard(
            icon: CupertinoIcons.calendar,
            label: 'Age',
            value: age,
            color: Colors.blueAccent),
      ],
    );
  }

  Widget _quickStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 10.5, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  // ─── Mood Section ─────────────────────────────────────────
  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("How are you feeling?",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Row(
            children: [
              _moodBox('sad', '😔', const Color(0xFFFF8C42), 'Not great'),
              _moodBox('neutral', '😐', const Color(0xFF4A90D9), 'Okay'),
              _moodBox('happy', '😊', const Color(0xFF4BA49C), 'Great!'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moodBox(
      String mood, String emoji, Color moodColor, String label) {
    final isSelected = selectedMood == mood;
    return Expanded(
      child: GestureDetector(
        onTap: moodLoading ? null : () => _sendMood(mood),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? moodColor.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? moodColor : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: moodColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: isSelected ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Text(emoji, style: const TextStyle(fontSize: 36)),
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? moodColor : Colors.grey[400])),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Schedule Header ──────────────────────────────────────
  Widget _buildScheduleHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFF4BA49C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(CupertinoIcons.calendar,
              color: Color(0xFF4BA49C), size: 16),
        ),
        const SizedBox(width: 8),
        const Text("Today's Schedule",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142))),
        const Spacer(),
        GestureDetector(
          onTap: widget.onSeeAll,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4BA49C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('See All',
                style: TextStyle(
                    color: Color(0xFF4BA49C),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  // ─── Med Item ─────────────────────────────────────────────
  Widget _buildMedItem(Map<String, dynamic> med) {
    final name = med['medication_name']?.toString() ?? 'Unknown';
    final time = med['intake_time']?.toString() ?? '--:--';
    final type = med['dosage_type']?.toString() ?? 'pill';
    final condition = med['medical_condition']?.toString() ?? '';
    final isTaken = med['daily_dosage_status'] == 'taken';

    const typeIcons = {
      'syrup': CupertinoIcons.drop_fill,
      'injection': CupertinoIcons.bandage_fill,
      'capsule': CupertinoIcons.capsule_fill,
      'pill': CupertinoIcons.capsule,
    };
    const typeColors = {
      'syrup': Color(0xFF3B82F6),
      'injection': Color(0xFFEF4444),
      'capsule': Color(0xFFF59E0B),
      'pill': Color(0xFF4BA49C),
    };

    final medIcon =
        typeIcons[type.toLowerCase()] ?? CupertinoIcons.capsule;
    final typeColor =
        typeColors[type.toLowerCase()] ?? const Color(0xFF4BA49C);
    final color = isTaken ? Colors.green : typeColor;

    return AnimatedOpacity(
      opacity: isTaken ? 0.7 : 1.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6))
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
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(medIcon, color: color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2D3142),
                                    decoration: isTaken
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: Colors.green)),
                            if (condition.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(condition,
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12)),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.clock_fill,
                                          size: 11, color: color),
                                      const SizedBox(width: 4),
                                      Text(time,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: color)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    type[0].toUpperCase() + type.substring(1),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: typeColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      isTaken
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle),
                              child: const Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  color: Colors.green,
                                  size: 30),
                            )
                          : GestureDetector(
                              onTap: () =>
                                  widget.onTakeMedication(med['id']),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4BA49C),
                                      Color(0xFF2D6B65)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xFF4BA49C)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3))
                                  ],
                                ),
                                child: const Text('Take',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedSkeleton() {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22)),
          child: Row(
            children: [
              _shimmer(46, 46, radius: 14),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmer(13, 150),
                    const SizedBox(height: 8),
                    _shimmer(10, 90),
                    const SizedBox(height: 8),
                    _shimmer(10, 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmer(double h, double w, {double radius = 8}) => Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(radius)),
      );

  Widget _buildEmptyMeds() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.green.withOpacity(0.05),
          Colors.green.withOpacity(0.1),
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(CupertinoIcons.checkmark_seal_fill,
                color: Colors.green, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('All caught up!',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              Text('No medications for today',
                  style:
                      TextStyle(color: Colors.green[400], fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Text('🎉', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  MOOD LOADING DIALOG  ← الجزء الرئيسي الجديد
// ─────────────────────────────────────────────────────────────
class _MoodLoadingDialog extends StatefulWidget {
  final String mood;
  final Color color;
  final Color bg;
  final String emoji;
  final String label;
  final List<String> particles;

  const _MoodLoadingDialog({
    required this.mood,
    required this.color,
    required this.bg,
    required this.emoji,
    required this.label,
    required this.particles,
  });

  @override
  State<_MoodLoadingDialog> createState() => _MoodLoadingDialogState();
}

class _MoodLoadingDialogState extends State<_MoodLoadingDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _rotateCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _dotCtrl;

  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;
  late Animation<double> _particleAnim;

  final _random = math.Random();
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _rotateAnim = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_rotateCtrl);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _particleAnim = Tween<double>(begin: 0, end: 1).animate(_particleCtrl);

    // Animate the dots "..."
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
    _dotCtrl.addListener(() {
      if (_dotCtrl.value > 0.66) {
        if (_dotCount != 3) setState(() => _dotCount = 3);
      } else if (_dotCtrl.value > 0.33) {
        if (_dotCount != 2) setState(() => _dotCount = 2);
      } else {
        if (_dotCount != 1) setState(() => _dotCount = 1);
      }
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _rotateCtrl.dispose();
    _particleCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.25),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Orbiting particles + pulsing emoji ───────────
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  AnimatedBuilder(
                    animation: _scaleAnim,
                    builder: (_, __) => Transform.scale(
                      scale: _scaleAnim.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.color.withOpacity(0.06),
                        ),
                      ),
                    ),
                  ),
                  // Inner ring
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withOpacity(0.1),
                    ),
                  ),
                  // Orbiting particles
                  AnimatedBuilder(
                    animation: _rotateAnim,
                    builder: (_, __) {
                      return Stack(
                        alignment: Alignment.center,
                        children: List.generate(
                          widget.particles.length,
                          (i) {
                            final angle = _rotateAnim.value +
                                (2 * math.pi / widget.particles.length) * i;
                            const radius = 62.0;
                            return Transform.translate(
                              offset: Offset(
                                radius * math.cos(angle),
                                radius * math.sin(angle),
                              ),
                              child: Text(
                                widget.particles[i],
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  // Center emoji — pulsing
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 52),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Animated dots loader ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i < _dotCount;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 10 : 8,
                  height: active ? 10 : 8,
                  decoration: BoxDecoration(
                    color: active
                        ? widget.color
                        : widget.color.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),

            const SizedBox(height: 14),

            // ── Label ────────────────────────────────────────
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'AI is preparing advice for you',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  MOOD RESPONSE SHEET
// ─────────────────────────────────────────────────────────────
class _MoodResponseSheet extends StatefulWidget {
  final String emoji;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String text;

  const _MoodResponseSheet({
    required this.emoji,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.text,
  });

  @override
  State<_MoodResponseSheet> createState() => _MoodResponseSheetState();
}

class _MoodResponseSheetState extends State<_MoodResponseSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ─────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
              ),

              // ── Hero Header ────────────────────────────────
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10, top: -10,
                      child: Text(widget.emoji,
                          style: const TextStyle(fontSize: 70)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Advice Card ────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.gradient.first.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(CupertinoIcons.sparkles,
                          color: widget.gradient.first, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.65,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Button ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: widget.gradient),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: widget.gradient.first.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Got it, thanks! 👍',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}