import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  PRIVACY POLICY PAGE
// ─────────────────────────────────────────────
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _sections = [
    _PolicySection(
      icon: CupertinoIcons.info_circle_fill,
      title: 'Information We Collect',
      body:
          'We collect personal information you provide directly to us, such as your name, email address, phone number, and medical history. This data helps us deliver personalized healthcare services.',
    ),
    _PolicySection(
      icon: CupertinoIcons.lock_fill,
      title: 'How We Use Your Data',
      body:
          'Your information is used solely to improve your care experience, communicate appointment reminders, and maintain accurate medical records. We never sell your data to third parties.',
    ),
    _PolicySection(
      icon: CupertinoIcons.share,
      title: 'Data Sharing',
      body:
          'We may share anonymized data with medical research partners or regulatory bodies when required by law. Your identity remains protected at all times.',
    ),
    _PolicySection(
      icon: CupertinoIcons.shield_lefthalf_fill,
      title: 'Data Security',
      body:
          'All data is encrypted in transit and at rest using industry-standard AES-256 encryption. Access is restricted to authorised medical personnel only.',
    ),
    _PolicySection(
      icon: CupertinoIcons.person_crop_circle_badge_checkmark,
      title: 'Your Rights',
      body:
          'You have the right to access, correct, or delete your personal data at any time. Contact our support team to exercise your rights.',
    ),
    _PolicySection(
      icon: CupertinoIcons.refresh_circled_solid,
      title: 'Policy Updates',
      body:
          'We may update this policy periodically. We will notify you of significant changes via email or in-app notification.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF4BA49C),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.back,
                    color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Privacy Policy',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4BA49C), Color(0xFF2D6B65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // decorative circles
                  Positioned(
                    top: -30, right: -30,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10, right: 40,
                    child: Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  // shield icon
                  const Positioned(
                    top: 48, right: 32,
                    child: Icon(CupertinoIcons.lock_shield_fill,
                        size: 72, color: Colors.white24),
                  ),
                  // last-updated chip
                  Positioned(
                    bottom: 48, left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Last updated: March 2026',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Intro card ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F5F4), Color(0xFFD0EDEB)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: const Color(0xFF4BA49C).withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BA49C).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.hand_raised_fill,
                          color: Color(0xFF4BA49C), size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Your privacy matters. Please read how we handle your personal health data.',
                        style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF2D6B65),
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Sections ──────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _PolicyCard(section: _sections[i]),
              childCount: _sections.length,
            ),
          ),

          // ── Footer ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                children: [
                  const Divider(height: 32),
                  Text(
                    'Questions about your privacy?\nContact us at privacy@healthapp.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4BA49C),
                      side: const BorderSide(color: Color(0xFF4BA49C)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {},
                    icon: const Icon(CupertinoIcons.mail, size: 18),
                    label: const Text('Contact Support'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Policy Section model ─────────────────────
class _PolicySection {
  final IconData icon;
  final String title;
  final String body;
  const _PolicySection(
      {required this.icon, required this.title, required this.body});
}

// ─── Policy Card widget ───────────────────────
class _PolicyCard extends StatefulWidget {
  final _PolicySection section;
  const _PolicyCard({required this.section});

  @override
  State<_PolicyCard> createState() => _PolicyCardState();
}

class _PolicyCardState extends State<_PolicyCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (v) => setState(() => _expanded = v),
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _expanded
                  ? const Color(0xFF4BA49C)
                  : const Color(0xFF4BA49C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.section.icon,
                color: _expanded
                    ? Colors.white
                    : const Color(0xFF4BA49C),
                size: 20),
          ),
          title: Text(
            widget.section.title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _expanded
                    ? const Color(0xFF4BA49C)
                    : const Color(0xFF2D3142)),
          ),
          trailing: AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(CupertinoIcons.chevron_down,
                size: 16,
                color: _expanded
                    ? const Color(0xFF4BA49C)
                    : Colors.grey),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.section.body,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SECURITY SETTINGS PAGE
// ─────────────────────────────────────────────
class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() =>
      _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _biometrics = true;
  bool _twoFactor = false;
  bool _loginAlerts = true;
  bool _dataEncryption = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF2D6B65),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.back,
                    color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Security Settings',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3D8A83), Color(0xFF1A4A45)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -20, right: -20,
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 44, right: 28,
                    child: Icon(CupertinoIcons.shield_fill,
                        size: 80, color: Colors.white12),
                  ),
                  // security score badge
                  Positioned(
                    bottom: 44, left: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(CupertinoIcons.checkmark_seal_fill,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 5),
                              Text('Security Score: Good',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Toggle Section ──────────────────────
                  _sectionHeader(
                      'Protection', CupertinoIcons.lock_fill),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    icon: CupertinoIcons.person_crop_circle_fill_badge_checkmark,
                    title: 'Biometric Login',
                    subtitle: 'Use Face ID or fingerprint to sign in',
                    value: _biometrics,
                    onChanged: (v) =>
                        setState(() => _biometrics = v),
                  ),
                  _buildToggleCard(
                    icon: CupertinoIcons.device_phone_portrait,
                    title: 'Two-Factor Authentication',
                    subtitle: 'Receive an OTP on your phone',
                    value: _twoFactor,
                    onChanged: (v) =>
                        setState(() => _twoFactor = v),
                    badge: !_twoFactor ? 'Recommended' : null,
                  ),
                  _buildToggleCard(
                    icon: CupertinoIcons.bell_fill,
                    title: 'Login Alerts',
                    subtitle: 'Get notified on new sign-ins',
                    value: _loginAlerts,
                    onChanged: (v) =>
                        setState(() => _loginAlerts = v),
                  ),
                  _buildToggleCard(
                    icon: CupertinoIcons.lock_rotation,
                    title: 'Data Encryption',
                    subtitle: 'AES-256 encryption always on',
                    value: _dataEncryption,
                    onChanged: (v) =>
                        setState(() => _dataEncryption = v),
                    locked: true,
                  ),

                  const SizedBox(height: 24),

                  // ── Action Tiles ────────────────────────
                  _sectionHeader(
                      'Account Actions',
                      CupertinoIcons.settings_solid),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    icon: CupertinoIcons.lock_rotation_open,
                    iconColor: const Color(0xFF4BA49C),
                    title: 'Change Password',
                    subtitle: 'Last changed 30 days ago',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: CupertinoIcons.device_laptop,
                    iconColor: Colors.blue,
                    title: 'Active Sessions',
                    subtitle: '2 devices currently signed in',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: CupertinoIcons.doc_plaintext,
                    iconColor: Colors.orange,
                    title: 'Download My Data',
                    subtitle: 'Export a copy of your health records',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: CupertinoIcons.trash,
                    iconColor: Colors.red,
                    title: 'Delete Account',
                    subtitle: 'Permanently remove your data',
                    onTap: () => _confirmDelete(context),
                    destructive: true,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4BA49C)),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF4BA49C),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? badge,
    bool locked = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF4BA49C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4BA49C), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3142))),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(badge,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12.5, color: Colors.grey[500])),
              ],
            ),
          ),
          locked
              ? const Icon(CupertinoIcons.lock_fill,
                  size: 16, color: Color(0xFF4BA49C))
              : CupertinoSwitch(
                  value: value,
                  activeColor: const Color(0xFF4BA49C),
                  onChanged: onChanged,
                ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: destructive
                    ? Colors.red
                    : const Color(0xFF2D3142))),
        subtitle: Text(subtitle,
            style:
                TextStyle(fontSize: 12.5, color: Colors.grey[500])),
        trailing: Icon(CupertinoIcons.chevron_forward,
            size: 15,
            color: destructive ? Colors.red[200] : Colors.grey[400]),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'This action is permanent. All your health data will be erased.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE PAGE  (updated _actionCard calls)
// ─────────────────────────────────────────────
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
    final nameCtrl =
        TextEditingController(text: patientData['name']?.toString() ?? '');
    final emailCtrl =
        TextEditingController(text: patientData['email']?.toString() ?? '');
    final phoneCtrl =
        TextEditingController(text: patientData['phone']?.toString() ?? '');
    final ageCtrl =
        TextEditingController(text: patientData['age']?.toString() ?? '');
    final addressCtrl =
        TextEditingController(text: patientData['address']?.toString() ?? '');
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
                      width: 40,
                      height: 4,
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
                    left: 24,
                    right: 24,
                    top: 20,
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
                      _editField(
                          addressCtrl, 'Address', CupertinoIcons.location),
                      const SizedBox(height: 14),
                      _editField(medCtrl, 'Medical Description',
                          CupertinoIcons.doc_text,
                          maxLines: 3),
                      const SizedBox(height: 16),
                      Row(
                        children: ['male', 'female']
                            .map((g) => Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setModalState(() => gender = g),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: EdgeInsets.only(
                                          right: g == 'male' ? 8 : 0),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: gender == g
                                            ? const Color(0xFF4BA49C)
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(14),
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
                                ))
                            .toList(),
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
                            color:
                                const Color(0xFF4BA49C).withOpacity(0.35),
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
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 15)),
                    ],
                    const SizedBox(height: 28),
                    _infoCard('Phone',
                        phone.isNotEmpty ? phone : 'Not set',
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
                      _infoCard(
                          'Address', address, CupertinoIcons.location),

                    const SizedBox(height: 16),

                    // ✅ Navigate to full pages
                    _actionCard(
                      'Privacy Policy',
                      CupertinoIcons.lock_shield,
                      () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const PrivacyPolicyPage(),
                        ),
                      ),
                    ),
                    _actionCard(
                      'Security Settings',
                      CupertinoIcons.shield_lefthalf_fill,
                      () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const SecuritySettingsPage(),
                        ),
                      ),
                    ),

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

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _confirmLogout(context),
                        icon: const Icon(CupertinoIcons.square_arrow_right),
                        label: const Text('Logout',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
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
                  style:
                      TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3142))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard(String title, IconData icon, VoidCallback onTap) {
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