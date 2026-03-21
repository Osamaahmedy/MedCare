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

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final conditionCtrl = TextEditingController();
    String dosageType = 'pill';
    // ✅ intake_days مطلوب من الـ API
    final List<String> allDays = [
      'sunday', 'monday', 'tuesday', 'wednesday',
      'thursday', 'friday', 'saturday'
    ];
    List<String> selectedDays = List.from(allDays); // افتراضياً كل الأيام

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Handle + Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Add Medication',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(CupertinoIcons.xmark_circle_fill,
                              color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24, right: 24, top: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sheetField(nameCtrl, 'Medication Name',
                          CupertinoIcons.capsule),
                      const SizedBox(height: 16),
                      _sheetField(conditionCtrl, 'Medical Condition',
                          CupertinoIcons.heart),
                      const SizedBox(height: 16),
                      _sheetField(descCtrl, 'Treatment Description',
                          CupertinoIcons.doc_text,
                          maxLines: 2),
                      const SizedBox(height: 16),
                      _sheetField(
                          timeCtrl, 'Intake Time (e.g., 08:00)',
                          CupertinoIcons.clock,
                          keyboardType: TextInputType.datetime),
                      const SizedBox(height: 20),
                      // ✅ Dosage Type Selector
                      const Text('Dosage Type',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3142))),
                      const SizedBox(height: 10),
                      Row(
                        children: ['pill', 'capsule', 'syrup', 'injection']
                            .map((type) => Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setModalState(() => dosageType = type),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: dosageType == type
                                            ? const Color(0xFF4BA49C)
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: dosageType == type
                                              ? const Color(0xFF4BA49C)
                                              : Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        type[0].toUpperCase() +
                                            type.substring(1),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: dosageType == type
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      // ✅ Intake Days Selector
                      const Text('Intake Days',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3142))),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allDays.map((day) {
                          final selected = selectedDays.contains(day);
                          return GestureDetector(
                            onTap: () => setModalState(() {
                              selected
                                  ? selectedDays.remove(day)
                                  : selectedDays.add(day);
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF4BA49C)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF4BA49C)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Text(
                                day[0].toUpperCase() + day.substring(1, 3),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CupertinoButton(
                          color: const Color(0xFF4BA49C),
                          borderRadius: BorderRadius.circular(16),
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
                              'medical_condition': conditionCtrl.text.trim(),
                              'treatment_description': descCtrl.text.trim(),
                            });
                          },
                          child: const Text('Add Medication',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
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
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('My Medications',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142))),
                      Text(
                        '${medications.length} medication${medications.length != 1 ? 's' : ''}',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showAddDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BA49C),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4BA49C).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.add, color: Colors.white, size: 18),
                          SizedBox(width: 4),
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
            ),
            const SizedBox(height: 16),
            Expanded(
              child: loading
                  ? const Center(child: CupertinoActivityIndicator())
                  : medications.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: const Color(0xFF4BA49C),
                          onRefresh: onRefresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: medications.length,
                            itemBuilder: (ctx, i) =>
                                _buildCard(context, medications[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> med) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 56, width: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF4BA49C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                typeIcons[type.toLowerCase()] ?? CupertinoIcons.capsule,
                color: const Color(0xFF4BA49C),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(CupertinoIcons.clock,
                          size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(time,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13)),
                      if (condition.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(condition,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isTaken ? Colors.green : const Color(0xFF4BA49C))
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isTaken ? 'Taken ✓' : type[0].toUpperCase() + type.substring(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isTaken ? Colors.green : const Color(0xFF4BA49C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(CupertinoIcons.delete,
                  color: Colors.red[300], size: 22),
              onPressed: () =>
                  _confirmDelete(context, med['id'], name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 20)
              ],
            ),
            child: Icon(CupertinoIcons.capsule,
                size: 50, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),
          const Text('No medications yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142))),
          const SizedBox(height: 8),
          const Text('Add your first medication to get started',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
