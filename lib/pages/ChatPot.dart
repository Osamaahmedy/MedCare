import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Chatpot extends StatefulWidget {
  final String token;

  const Chatpot({
    super.key,
    required this.token,
  });

  @override
  State<Chatpot> createState() => _ChatpotState();
}

class _ChatpotState extends State<Chatpot> {
  final Dio dio = Dio();
  final TextEditingController controller = TextEditingController();

  final List<String> userMessages = [];
  final List<String> botMessages = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    dio.options.headers['Authorization'] = 'Bearer ${widget.token}';
  }

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final msg = controller.text;
    controller.clear();

    setState(() {
      userMessages.add(msg);
      botMessages.add('');
      loading = true;
    });

    try {
      final res = await dio.post(
        'http://127.0.0.1:8000/api/patient/ai/chat',
        data: {'message': msg},
      );

      setState(() {
        botMessages.last = res.data['response'].toString();
      });
    } catch (e) {
      setState(() {
        botMessages.last = e.toString();
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: userMessages.length,
            itemBuilder: (_, i) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(userMessages[i]),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(botMessages[i]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(controller: controller),
            ),
            loading
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
          ],
        ),
      ],
    );
  }
}
