import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MediCareApp extends StatefulWidget {
  final String token;
  final String? name;

  const MediCareApp({
    super.key,
    required this.token,
    this.name,
  });

  @override
  State<MediCareApp> createState() => _MediCareAppState();
}

class _MediCareAppState extends State<MediCareApp> {
  final Dio dio = Dio();
  bool moodLoading = false;
  String selectedMood = '';
  List<dynamic> medications = [];

  @override
  void initState() {
    super.initState();
    dio.options.headers['Authorization'] = 'Bearer ${widget.token}';
    fetchMedications();
  }

  Future<void> fetchMedications() async {
    try {
      final res = await dio.get(
        'http://127.0.0.1:8000/api/patient/medications',
      );

      final data = res.data;
      setState(() {
        medications = data != null && data['medications'] != null
            ? List.from(data['medications'])
            : [];
      });
    } catch (_) {
      setState(() {
        medications = [];
      });
    }
  }

  Future<void> sendMood(String mood) async {
    setState(() {
      selectedMood = mood;
      moodLoading = true;
    });

    try {
      final res = await dio.post(
        'http://127.0.0.1:8000/api/patient/ai/mood',
        data: {'mood': mood},
      );

      setState(() => moodLoading = false);

      final String responseText =
          res.data != null && res.data['response'] != null
              ? res.data['response'].toString()
              : 'No response from AI';

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Medical Advice'),
          content: Text(responseText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (_) {
      setState(() => moodLoading = false);
    }
  }

  Future<void> sendChat(String message) async {
    if (message.trim().isEmpty) return;

    setState(() => moodLoading = true);

    try {
      final res = await dio.post(
        'http://127.0.0.1:8000/api/patient/ai/chat',
        data: {'message': message},
      );

      setState(() => moodLoading = false);

      final String responseText =
          res.data != null && res.data['response'] != null
              ? res.data['response'].toString()
              : 'No response from AI';

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Medical Assistant'),
          content: Text(responseText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (_) {
      setState(() => moodLoading = false);
    }
  }

  Future<void> takeMedication(int id) async {
    await dio.patch(
      'http://127.0.0.1:8000/api/patient/medications/$id/daily-dosage',
      data: {'daily_dosage_status': 'taken'},
    );
    fetchMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2DFDF),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 25),
                  _welcome(),
                  const SizedBox(height: 30),
                  _moodSection(),
                  const SizedBox(height: 35),
                  const Text(
                    "Today's Medications",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (medications.isEmpty)
                    const Text(
                      'No medications available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ...medications.map(_medItem).toList(),
                ],
              ),
            ),
          ),
          if (moodLoading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _footer(),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFFE3EFEF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Center(
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF4BA49C),
          onPressed: _openChat,
          child: const Icon(Icons.chat_bubble_outline),
        ),
      ),
    );
  }

  void _openChat() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Medical Assistant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ask a medical question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  sendChat(controller.text);
                },
                child: const Text('Send'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header() {
    return Row(
      children: const [
        Icon(Icons.medical_services, color: Color(0xFF4A6572)),
        SizedBox(width: 10),
        Text(
          'MediCare',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _welcome() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Welcome back, ${widget.name ?? 'Patient'}',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _moodSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _moodBox('sad', Icons.sentiment_dissatisfied),
                  _moodBox('neutral', Icons.sentiment_neutral),
                  _moodBox('happy', Icons.sentiment_very_satisfied),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moodBox(String mood, IconData icon) {
    final bool active = selectedMood == mood;

    return GestureDetector(
      onTap: () => sendMood(mood),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF4A6572).withOpacity(0.25)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 36, color: const Color(0xFF4A6572)),
      ),
    );
  }

  Widget _medItem(dynamic med) {
    final String name =
        med != null && med['medication_name'] != null
            ? med['medication_name'].toString()
            : 'Unknown';

    final String time =
        med != null && med['intake_time'] != null
            ? med['intake_time'].toString()
            : '--:--';

    final bool taken = med != null &&
        med['daily_dosage_status'] != null &&
        med['daily_dosage_status'] == 'taken';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 10),
          taken
              ? const Icon(Icons.check_circle, color: Colors.green)
              : ElevatedButton(
                  onPressed: () => takeMedication(med['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 59, 174, 159),
                  ),
                  child: const Text('Take'),
                ),
        ],
      ),
    );
  }
}
