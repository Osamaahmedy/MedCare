import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class HealthPage extends StatefulWidget {
  final Dio dio;
  const HealthPage({super.key, required this.dio});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  List<Map<String, dynamic>> consultants = [];
  List<Map<String, dynamic>> filtered = [];
  bool loading = true;
  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchConsultants();
    searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // ✅ جلب الأطباء من API بدل الـ hardcoded
  Future<void> fetchConsultants() async {
    try {
      final res = await widget.dio.get(
        'http://127.0.0.1:8000/api/consultants',
        options: Options(headers: {}), // public endpoint لا يحتاج token
      );
      final data = res.data['data'];
      setState(() {
        consultants = data is List
            ? List<Map<String, dynamic>>.from(data)
            : [];
        filtered = List.from(consultants);
        loading = false;
      });
    } catch (_) {
      setState(() {
        consultants = [];
        filtered = [];
        loading = false;
      });
    }
  }

  void _filter() {
    final q = searchCtrl.text.toLowerCase();
    setState(() {
      filtered = consultants
          .where((c) =>
              c['name'].toString().toLowerCase().contains(q) ||
              c['department'].toString().toLowerCase().contains(q) ||
              c['profession'].toString().toLowerCase().contains(q))
          .toList();
    });
  }

  void _showDetails(Map<String, dynamic> consultant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildAvatar(consultant, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(consultant['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(consultant['profession'] ?? '',
                          style: const TextStyle(
                              color: Color(0xFF4BA49C),
                              fontWeight: FontWeight.w600)),
                      Text(consultant['department'] ?? '',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (consultant['bio'] != null && consultant['bio'].toString().isNotEmpty) ...[
              Text('About',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700])),
              const SizedBox(height: 6),
              Text(consultant['bio'],
                  style: TextStyle(color: Colors.grey[600], height: 1.5)),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                _infoChip(CupertinoIcons.briefcase,
                    '${consultant['experience'] ?? ''} yrs'),
                const SizedBox(width: 10),
                _infoChip(CupertinoIcons.money_dollar_circle,
                    consultant['price'] ?? ''),
                const SizedBox(width: 10),
                _infoChip(CupertinoIcons.checkmark_shield,
                    '${consultant['completed_requests'] ?? 0} cases'),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: CupertinoButton(
                color: const Color(0xFF4BA49C),
                borderRadius: BorderRadius.circular(16),
                onPressed: () => Navigator.pop(context),
                child: const Text('Book Appointment',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4BA49C).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4BA49C)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4BA49C),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> consultant, {double size = 80}) {
    final imageUrl = consultant['image'];
    final name = consultant['name']?.toString() ?? '?';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      height: size, width: size,
      decoration: BoxDecoration(
        color: const Color(0xFF4BA49C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.toString().isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(initial,
                    style: TextStyle(
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4BA49C))),
              ),
            )
          : Center(
              child: Text(initial,
                  style: TextStyle(
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4BA49C))),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Find Specialist',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142))),
                  const SizedBox(height: 4),
                  Text('${filtered.length} specialists available',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  const SizedBox(height: 16),
                  // ✅ Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search by name or specialty...',
                        hintStyle: TextStyle(
                            color: Colors.grey[400], fontSize: 15),
                        prefixIcon: const Icon(CupertinoIcons.search,
                            color: Color(0xFF4BA49C)),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(CupertinoIcons.xmark_circle_fill,
                                    color: Colors.grey[400]),
                                onPressed: () {
                                  searchCtrl.clear();
                                  _filter();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CupertinoActivityIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.search,
                                  size: 50, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text('No specialists found',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF4BA49C),
                          onRefresh: fetchConsultants,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) =>
                                _buildCard(filtered[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> consultant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDetails(consultant),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  _buildAvatar(consultant),
                  if (consultant['status'] == true)
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        height: 16, width: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(consultant['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BA49C).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        consultant['profession'] ?? '',
                        style: const TextStyle(
                            color: Color(0xFF4BA49C),
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(CupertinoIcons.briefcase,
                            size: 13, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text('${consultant['experience'] ?? ''} exp',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                        const SizedBox(width: 10),
                        Icon(CupertinoIcons.checkmark_shield,
                            size: 13, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                            '${consultant['completed_requests'] ?? 0} cases',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.chevron_forward,
                    size: 16, color: Color(0xFF4BA49C)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
