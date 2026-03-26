import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class HealthPage extends StatefulWidget {
  final Dio dio;
  const HealthPage({super.key, required this.dio});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> consultants = [];
  List<Map<String, dynamic>> filtered = [];
  bool loading = true;
  String _selectedCategory = 'All';
  final searchCtrl = TextEditingController();

  // تُجمع الأقسام ديناميكياً من الـ API
  List<String> get _categories {
    final deps = consultants
        .map((c) => c['department']?.toString() ?? '')
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    return ['All', ...deps];
  }

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

  Future<void> fetchConsultants() async {
    setState(() => loading = true);
    try {
      final res = await widget.dio.get(
        'http://127.0.0.1:8000/api/consultants',
        options: Options(headers: {}),
      );
      final data = res.data['data'];
      setState(() {
        consultants = data is List
            ? List<Map<String, dynamic>>.from(data)
            : [];
        _applyFilters();
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

  void _filter() => _applyFilters();

  void _applyFilters() {
    final q = searchCtrl.text.toLowerCase();
    setState(() {
      filtered = consultants.where((c) {
        final matchesQuery = q.isEmpty ||
            c['name'].toString().toLowerCase().contains(q) ||
            c['department'].toString().toLowerCase().contains(q) ||
            c['profession'].toString().toLowerCase().contains(q);
        final matchesCategory = _selectedCategory == 'All' ||
            c['department']?.toString() == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  // ─── Details Bottom Sheet ────────────────────────────────
  void _showDetails(Map<String, dynamic> consultant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConsultantDetailSheet(consultant: consultant),
    );
  }

  // ─── Avatar ──────────────────────────────────────────────
  Widget _buildAvatar(Map<String, dynamic> consultant,
      {double size = 80}) {
    final imageUrl = consultant['image'];
    final name = consultant['name']?.toString() ?? '?';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4BA49C), Color(0xFF2D6B65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.toString().isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(initial,
                    style: TextStyle(
                        fontSize: size * 0.38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            )
          : Center(
              child: Text(initial,
                  style: TextStyle(
                      fontSize: size * 0.38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
    );
  }

  // ─── Card ─────────────────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> consultant) {
    final isOnline = consultant['status'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4BA49C).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDetails(consultant),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar + online dot
              Stack(
                children: [
                  _buildAvatar(consultant),
                  if (isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34D399),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            consultant['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142)),
                          ),
                        ),
                        if (isOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Online',
                                style: TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Specialty badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BA49C).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        consultant['profession'] ?? '',
                        style: const TextStyle(
                            color: Color(0xFF4BA49C),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stats row
                    Row(
                      children: [
                        _statChip(
                          CupertinoIcons.briefcase,
                          '${consultant['experience'] ?? ''} yrs',
                        ),
                        const SizedBox(width: 8),
                        _statChip(
                          CupertinoIcons.checkmark_shield,
                          '${consultant['completed_requests'] ?? 0} cases',
                        ),
                        if (consultant['price'] != null) ...[
                          const SizedBox(width: 8),
                          _statChip(
                            CupertinoIcons.money_dollar_circle,
                            consultant['price'].toString(),
                            highlight: true,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Arrow
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4BA49C).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.chevron_forward,
                    size: 15, color: Color(0xFF4BA49C)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label,
      {bool highlight = false}) {
    return Row(
      children: [
        Icon(icon,
            size: 12,
            color: highlight
                ? const Color(0xFF2D6B65)
                : Colors.grey[400]),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                color: highlight
                    ? const Color(0xFF2D6B65)
                    : Colors.grey[500],
                fontSize: 12,
                fontWeight:
                    highlight ? FontWeight.w700 : FontWeight.normal)),
      ],
    );
  }

  // ─── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 16,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Find Specialist',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142))),
                          const SizedBox(height: 2),
                          Text(
                            '${filtered.length} specialists available',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13.5),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Online count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4BA49C),
                              Color(0xFF2D6B65)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34D399),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${consultants.where((c) => c['status'] == true).length} Online',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Search Bar ───────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search by name or specialty...',
                        hintStyle: TextStyle(
                            color: Colors.grey[400], fontSize: 14),
                        prefixIcon: const Icon(CupertinoIcons.search,
                            color: Color(0xFF4BA49C), size: 20),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                    CupertinoIcons.xmark_circle_fill,
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
                  const SizedBox(height: 14),

                  // ── Category Chips ───────────────────────
                  if (!loading)
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final cat = _categories[i];
                          final selected = cat == _selectedCategory;
                          return GestureDetector(
                            onTap: () {
                              setState(
                                  () => _selectedCategory = cat);
                              _applyFilters();
                            },
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF4BA49C)
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF4BA49C)
                                      : Colors.grey.shade200,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF4BA49C)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset:
                                              const Offset(0, 3),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // ── List ─────────────────────────────────────────
            Expanded(
              child: loading
                  ? _buildSkeleton()
                  : filtered.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: const Color(0xFF4BA49C),
                          onRefresh: fetchConsultants,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                24, 20, 24, 24),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) =>
                                _buildCard(filtered[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Skeleton Loading ─────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            _shimmer(80, 80, radius: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmer(12, 130),
                  const SizedBox(height: 8),
                  _shimmer(10, 80),
                  const SizedBox(height: 10),
                  _shimmer(10, 180),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer(double h, double w, {double radius = 8}) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF4BA49C).withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.person_crop_circle_badge_xmark,
                size: 52, color: Color(0xFF4BA49C)),
          ),
          const SizedBox(height: 20),
          const Text('No specialists found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142))),
          const SizedBox(height: 6),
          Text('Try adjusting your search or filters',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 20),
          CupertinoButton(
            color: const Color(0xFF4BA49C),
            borderRadius: BorderRadius.circular(14),
            onPressed: () {
              searchCtrl.clear();
              setState(() => _selectedCategory = 'All');
              _applyFilters();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CONSULTANT DETAIL SHEET
// ─────────────────────────────────────────────────────────────
class _ConsultantDetailSheet extends StatelessWidget {
  final Map<String, dynamic> consultant;
  const _ConsultantDetailSheet({required this.consultant});

  Widget _infoChip(IconData icon, String label, {Color? color}) {
    final c = color ?? const Color(0xFF4BA49C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12.5, color: c, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAvatar(double size) {
    final imageUrl = consultant['image'];
    final name = consultant['name']?.toString() ?? '?';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4BA49C), Color(0xFF2D6B65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF4BA49C).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.toString().isNotEmpty
          ? Image.network(imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                    child: Text(initial,
                        style: TextStyle(
                            fontSize: size * 0.38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ))
          : Center(
              child: Text(initial,
                  style: TextStyle(
                      fontSize: size * 0.38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = consultant['status'] == true;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // ── Hero header ─────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4BA49C), Color(0xFF2D6B65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _buildAvatar(68),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(consultant['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(consultant['profession'] ?? '',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(CupertinoIcons.building_2_fill,
                              size: 12, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(consultant['department'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isOnline)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle,
                            size: 8, color: Color(0xFF34D399)),
                        SizedBox(width: 4),
                        Text('Online',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Stats ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _statBox(
                    CupertinoIcons.briefcase_fill,
                    '${consultant['experience'] ?? '—'}',
                    'Years Exp.',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statBox(
                    CupertinoIcons.checkmark_shield_fill,
                    '${consultant['completed_requests'] ?? 0}',
                    'Cases',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statBox(
                    CupertinoIcons.money_dollar_circle_fill,
                    consultant['price']?.toString() ?? '—',
                    'Price',
                  ),
                ),
              ],
            ),
          ),

          // ── Bio ──────────────────────────────────────────
          if (consultant['bio'] != null &&
              consultant['bio'].toString().isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(CupertinoIcons.info_circle_fill,
                            size: 16, color: Color(0xFF4BA49C)),
                        SizedBox(width: 6),
                        Text('About',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF2D3142))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(consultant['bio'],
                        style: TextStyle(
                            color: Colors.grey[600],
                            height: 1.6,
                            fontSize: 13.5)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // ── CTA Buttons ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Row(
              children: [
                // Chat button
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4BA49C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(CupertinoIcons.chat_bubble_text_fill,
                      color: Color(0xFF4BA49C)),
                ),
                const SizedBox(width: 12),
                // Book button
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: CupertinoButton(
                      color: const Color(0xFF4BA49C),
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () => Navigator.pop(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.calendar_badge_plus,
                              size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Book Appointment',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4BA49C), size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142))),
          const SizedBox(height: 2),
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }
}