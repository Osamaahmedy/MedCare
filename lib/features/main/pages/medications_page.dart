import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MedicationsPage extends StatelessWidget {
  final List<Map<String, dynamic>> medications;
  final bool loading;
  final bool actionLoading;
  final Future<void> Function(int) onDelete;
  final Future<void> Function(Map<String, dynamic>) onAdd;
  final Future<void> Function() onRefresh;

  const MedicationsPage({
    super.key,
    required this.medications,
    required this.loading,
    required this.actionLoading,
    required this.onDelete,
    required this.onAdd,
    required this.onRefresh,
  });

  // ─── Dosage meta ──────────────────────────────────────────
  static const Map<String, IconData> _typeIcons = {
    'syrup': CupertinoIcons.drop_fill,
    'injection': CupertinoIcons.bandage_fill,
    'capsule': CupertinoIcons.capsule_fill,
    'pill': CupertinoIcons.capsule,
  };

  static const Map<String, Color> _typeColors = {
    'syrup': Color(0xFF3B82F6),
    'injection': Color(0xFFEF4444),
    'capsule': Color(0xFFF59E0B),
    'pill': Color(0xFF4BA49C),
  };

  // ─── Stats strip ─────────────────────────────────────────
  int get _takenCount =>
      medications.where((m) => m['daily_dosage_status'] == 'taken').length;

  int get _pendingCount => medications.length - _takenCount;

  // ─────────────────────────────────────────────────────────
  //  ADD DIALOG
  // ─────────────────────────────────────────────────────────
  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final conditionCtrl = TextEditingController();
    String dosageType = 'pill';
    final List<String> allDays = [
      'sunday', 'monday', 'tuesday', 'wednesday',
      'thursday', 'friday', 'saturday',
    ];
    List<String> selectedDays = List.from(allDays);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F4F8),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // ── Sheet Header ──────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4BA49C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(CupertinoIcons.capsule_fill,
                              color: Color(0xFF4BA49C), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('Add Medication',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142))),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(CupertinoIcons.xmark,
                                color: Colors.grey[500], size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Sheet Body ────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20, right: 20, top: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fields
                      _sheetField(nameCtrl, 'Medication Name',
                          CupertinoIcons.capsule),
                      const SizedBox(height: 14),
                      _sheetField(conditionCtrl, 'Medical Condition',
                          CupertinoIcons.heart),
                      const SizedBox(height: 14),
                      _sheetField(descCtrl, 'Treatment Description',
                          CupertinoIcons.doc_text,
                          maxLines: 2),
                      const SizedBox(height: 14),
                      // Time picker row
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                            builder: (c, child) => Theme(
                              data: Theme.of(c).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF4BA49C),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            final h = picked.hour
                                .toString()
                                .padLeft(2, '0');
                            final m = picked.minute
                                .toString()
                                .padLeft(2, '0');
                            timeCtrl.text = '$h:$m';
                            setModalState(() {});
                          }
                        },
                        child: AbsorbPointer(
                          child: _sheetField(
                            timeCtrl,
                            'Intake Time — tap to pick',
                            CupertinoIcons.clock,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ── Dosage Type ───────────────────────
                      _sectionLabel('Dosage Type',
                          CupertinoIcons.square_grid_2x2_fill),
                      const SizedBox(height: 12),
                      Row(
                        children: ['pill', 'capsule', 'syrup', 'injection']
                            .map((type) {
                          final selected = dosageType == type;
                          final color = _typeColors[type] ??
                              const Color(0xFF4BA49C);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(
                                  () => dosageType = type),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? color
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected
                                        ? color
                                        : Colors.grey.shade200,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color:
                                                color.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset:
                                                const Offset(0, 3),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      _typeIcons[type] ??
                                          CupertinoIcons.capsule,
                                      size: 20,
                                      color: selected
                                          ? Colors.white
                                          : color,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      type[0].toUpperCase() +
                                          type.substring(1),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      // ── Intake Days ───────────────────────
                      Row(
                        children: [
                          _sectionLabel('Intake Days',
                              CupertinoIcons.calendar),
                          const Spacer(),
                          // Select All toggle
                          GestureDetector(
                            onTap: () => setModalState(() {
                              selectedDays =
                                  selectedDays.length == allDays.length
                                      ? []
                                      : List.from(allDays);
                            }),
                            child: Text(
                              selectedDays.length == allDays.length
                                  ? 'Clear All'
                                  : 'Select All',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4BA49C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: allDays.map((day) {
                          final selected = selectedDays.contains(day);
                          return GestureDetector(
                            onTap: () => setModalState(() {
                              selected
                                  ? selectedDays.remove(day)
                                  : selectedDays.add(day);
                            }),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF4BA49C)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF4BA49C)
                                      : Colors.grey.shade200,
                                  width: 1.5,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF4BA49C)
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  day[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white
                                        : Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: CupertinoButton(
                          color: const Color(0xFF4BA49C),
                          borderRadius: BorderRadius.circular(18),
                          onPressed: () {
                            if (nameCtrl.text.trim().isEmpty ||
                                timeCtrl.text.trim().isEmpty ||
                                selectedDays.isEmpty) return;
                            Navigator.pop(ctx);
                            onAdd({
                              'medication_name': nameCtrl.text.trim(),
                              'dosage_type': dosageType,
                              'intake_time': timeCtrl.text.trim(),
                              'intake_days': selectedDays,
                              'medical_condition':
                                  conditionCtrl.text.trim(),
                              'treatment_description':
                                  descCtrl.text.trim(),
                            });
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.add_circled_solid,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Add Medication',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
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

  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF4BA49C)),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: Color(0xFF4BA49C),
          ),
        ),
      ],
    );
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: Color(0xFF2D3142)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF4BA49C), size: 20),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF4BA49C), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onDelete(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Card ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 16,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Medications',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142))),
                          const SizedBox(height: 2),
                          Text(
                            '${medications.length} medication${medications.length != 1 ? 's' : ''}',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showAddDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF4BA49C),
                                Color(0xFF2D6B65)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4BA49C)
                                    .withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(CupertinoIcons.add,
                                  color: Colors.white, size: 17),
                              SizedBox(width: 5),
                              Text('Add New',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Stats Strip ──────────────────────────
                  if (!loading && medications.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _statPill(
                          icon: CupertinoIcons.checkmark_circle_fill,
                          label: 'Taken',
                          value: _takenCount,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        _statPill(
                          icon: CupertinoIcons.clock_fill,
                          label: 'Pending',
                          value: _pendingCount,
                          color: const Color(0xFF4BA49C),
                        ),
                        const SizedBox(width: 10),
                        _statPill(
                          icon: CupertinoIcons.capsule_fill,
                          label: 'Total',
                          value: medications.length,
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────
            Expanded(
              child: loading
                  ? _buildSkeleton()
                  : medications.isEmpty
                      ? _buildEmpty(context)
                      : RefreshIndicator(
                          color: const Color(0xFF4BA49C),
                          onRefresh: onRefresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                24, 20, 24, 24),
                            itemCount: medications.length,
                            itemBuilder: (ctx, i) =>
                                _buildCard(ctx, medications[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Stat Pill ────────────────────────────────────────────
  Widget _statPill({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text('$value',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  // ─── Card ─────────────────────────────────────────────────
  Widget _buildCard(BuildContext context, Map<String, dynamic> med) {
    final name =
        med['medication_name']?.toString() ?? 'Unknown';
    final time = med['intake_time']?.toString() ?? '--:--';
    final type = med['dosage_type']?.toString() ?? 'pill';
    final condition = med['medical_condition']?.toString() ?? '';
    final days = med['intake_days'];
    final isTaken = med['daily_dosage_status'] == 'taken';
    final typeColor =
        _typeColors[type.toLowerCase()] ?? const Color(0xFF4BA49C);
    final typeIcon =
        _typeIcons[type.toLowerCase()] ?? CupertinoIcons.capsule;

    String daysLabel = '';
    if (days is List && days.isNotEmpty) {
      daysLabel = days.length == 7
          ? 'Every day'
          : days
              .map((d) => d.toString()[0].toUpperCase())
              .join(' · ');
    }

    return Dismissible(
      key: ValueKey(med['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.delete, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        bool confirmed = false;
        await showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Delete Medication'),
            content:
                Text('Are you sure you want to delete "$name"?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  confirmed = true;
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed) onDelete(med['id']);
        return false; // نتركه يحذف عبر onDelete
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon box
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(typeIcon, color: typeColor, size: 26),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + status badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isTaken
                                    ? Colors.green
                                    : typeColor)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isTaken
                                    ? CupertinoIcons
                                        .checkmark_circle_fill
                                    : typeIcon,
                                size: 11,
                                color: isTaken
                                    ? Colors.green
                                    : typeColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isTaken
                                    ? 'Taken'
                                    : type[0].toUpperCase() +
                                        type.substring(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isTaken
                                      ? Colors.green
                                      : typeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Time + condition
                    Row(
                      children: [
                        Icon(CupertinoIcons.clock_fill,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(time,
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500)),
                        if (condition.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(condition,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12)),
                          ),
                        ],
                      ],
                    ),

                    // Days row
                    if (daysLabel.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(CupertinoIcons.calendar,
                              size: 12, color: typeColor),
                          const SizedBox(width: 4),
                          Text(daysLabel,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: typeColor,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Delete button
              GestureDetector(
                onTap: () =>
                    _confirmDelete(context, med['id'], name),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(CupertinoIcons.delete,
                      color: Colors.red[300], size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Skeleton ─────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            _shimmer(58, 58, radius: 16),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmer(14, 160),
                  const SizedBox(height: 8),
                  _shimmer(11, 100),
                  const SizedBox(height: 8),
                  _shimmer(11, 130),
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
  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5F4), Color(0xFFD0EDEB)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.capsule_fill,
                  size: 52, color: Color(0xFF4BA49C)),
            ),
            const SizedBox(height: 24),
            const Text('No medications yet',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142))),
            const SizedBox(height: 8),
            Text(
              'Keep track of your daily medications\nand never miss a dose.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey[500], fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            CupertinoButton(
              color: const Color(0xFF4BA49C),
              borderRadius: BorderRadius.circular(16),
              onPressed: () => _showAddDialog(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.add, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Add First Medication',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}