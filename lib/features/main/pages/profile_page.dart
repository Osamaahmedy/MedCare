import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final bool loading;
  final bool actionLoading;
  final Future<void> Function(Map<String, dynamic>) onUpdate;
  final Future<void> Function() onLogout;

  const ProfilePage({
    super.key,
    required this.patientData,
    required this.loading,
    required this.actionLoading,
    required this.onUpdate,
    required this.onLogout,
  });

  void _showEditDialog(BuildContext context) {
    final nameCtrl = TextEditingController(
        text: patientData['name']?.toString() ?? '');
    final emailCtrl = TextEditingController(
        text: patientData['email']?.toString() ?? '');
    final phoneCtrl = TextEditingController(
        text: patientData['phone']?.toString() ?? '');
    final ageCtrl = TextEditingController(
        text: patientData['age']?.toString() ?? '');
    final addressCtrl = TextEditingController(
        text: patientData['address']?.toString() ?? '');
    final medCtrl = TextEditingController(
        text: patientData['medical_description']?.toString() ?? '');
    String gender = patientData['gender']?.toString() ?? 'male';

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
                        const Text('Edit Profile',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
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
                    children: [
                      _editField(nameCtrl, 'Full Name', CupertinoIcons.person),
                      const SizedBox(height: 14),
                      _editField(emailCtrl, 'Email', CupertinoIcons.mail,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      _editField(phoneCtrl, 'Phone', CupertinoIcons.phone,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 14),
                      _editField(ageCtrl, 'Age', CupertinoIcons.calendar,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 14),
                      _editField(addressCtrl, 'Address',
                          CupertinoIcons.location),
                      const SizedBox(height: 14),
                      _editField(medCtrl, 'Medical Description',
                          CupertinoIcons.doc_text,
                          maxLines: 3),
                      const SizedBox(height: 16),
                      // Gender selector
                      Row(
                        children: ['male', 'female'].map((g) => Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => gender = g),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(
                                  right: g == 'male' ? 8 : 0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                color: gender == g
                                    ? const Color(0xFF4BA49C)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: gender == g
                                      ? const Color(0xFF4BA49C)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Text(
                                g[0].toUpperCase() + g.substring(1),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: gender == g
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CupertinoButton(
                          color: const Color(0xFF4BA49C),
                          borderRadius: BorderRadius.circular(16),
                          onPressed: () {
                            Navigator.pop(ctx);
                            onUpdate({
                              'name': nameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'age': int.tryParse(ageCtrl.text),
                              'address': addressCtrl.text.trim(),
                              'medical_description': medCtrl.text.trim(),
                              'gender': gender,
                            });
                          },
                          child: const Text('Save Changes',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
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

  Widget _editField(
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
        hintStyle: TextStyle(color: Colors.grey[400]),
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

  @override
  Widget build(BuildContext context) {
    final name = patientData['name']?.toString() ?? 'Patient';
    final email = patientData['email']?.toString() ?? '';
    final phone = patientData['phone']?.toString() ?? '';
    final age = patientData['age']?.toString() ?? '';
    final gender = patientData['gender']?.toString() ?? '';
    final address = patientData['address']?.toString() ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: loading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // ✅ Avatar مع تدرج
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4BA49C), Color(0xFF2D6B65)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4BA49C).withOpacity(0.35),
                            spreadRadius: 4,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.transparent,
                        child: Text(initial,
                            style: const TextStyle(
                                fontSize: 44,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(name,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142))),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(email,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 15)),
                    ],
                    const SizedBox(height: 28),

                    // ✅ بيانات حقيقية من الـ API
                    _infoCard('Phone', phone.isNotEmpty ? phone : 'Not set',
                        CupertinoIcons.phone),
                    _infoCard(
                        'Age',
                        age.isNotEmpty ? '$age years' : 'Not set',
                        CupertinoIcons.calendar),
                    _infoCard(
                        'Gender',
                        gender.isNotEmpty
                            ? gender[0].toUpperCase() + gender.substring(1)
                            : 'Not set',
                        CupertinoIcons.person),
                    if (address.isNotEmpty)
                      _infoCard('Address', address,
                          CupertinoIcons.location),

                    const SizedBox(height: 16),
                    _actionCard('Privacy Policy',
                        CupertinoIcons.lock_shield, () {}),
                    _actionCard('Security Settings',
                        CupertinoIcons.shield_lefthalf_fill, () {}),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: CupertinoButton(
                        color: const Color(0xFF4BA49C),
                        borderRadius: BorderRadius.circular(16),
                        onPressed: () => _showEditDialog(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.pencil,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Edit Profile',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ✅ Logout يستدعي API
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(
                              color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _confirmLogout(context),
                        icon: const Icon(CupertinoIcons.square_arrow_right),
                        label: const Text('Logout',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4BA49C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4BA49C), size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3142))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
      String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4BA49C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4BA49C), size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
        trailing: const Icon(CupertinoIcons.chevron_forward,
            size: 16, color: Colors.grey),
      ),
    );
  }
}
