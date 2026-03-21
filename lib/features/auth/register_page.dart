import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/api.dart';
import '../../core/ui_helpers.dart';
import '../auth/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final medicalController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();

  String gender = 'female';
  bool loading = false;
  bool obscurePassword = true;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    medicalController.dispose();
    ageController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate() || loading) return;
    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      await ApiService.dio.post(
        'patient/register',
        data: {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'medical_description': medicalController.text.trim(),
          'age': ageController.text.isEmpty
              ? null
              : int.tryParse(ageController.text),
          'gender': gender,
          'address': addressController.text.trim(),
        },
      );

      UIHelpers.showMessage(context, 'Account created successfully!', true);

if (mounted) {
  Navigator.pushReplacement(
    context,
    CupertinoPageRoute(
      builder: (_) => const LoginPage(),
    ),
  );
}

    } on DioException catch (e) {
      setState(() {
        if (e.response?.statusCode == 422) {
          // ✅ استخراج رسائل validation من Laravel
          final errors = e.response?.data['errors'];
          if (errors != null && errors is Map) {
            errorMessage = (errors.values.first as List).first.toString();
          } else {
            errorMessage = e.response?.data['message'] ?? 'Invalid data.';
          }
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown) {
          errorMessage = 'No internet connection. Please try again.';
        } else {
          errorMessage = 'Something went wrong. Please try again.';
        }
      });
    } catch (_) {
      setState(() => errorMessage = 'Unexpected error. Please try again.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7FD8CC), Color(0xFFD6F6F4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ✅ Header خارج الكارد مثل iOS
                  _buildHeader()
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2),

                  const SizedBox(height: 32),

                  // ✅ Glass Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A3644).withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Section: Personal Info ──
                            _sectionLabel('Personal Information'),
                            const SizedBox(height: 12),

                            _buildField(
                              controller: nameController,
                              placeholder: 'Full Name',
                              icon: CupertinoIcons.person,
                              validator: (v) =>
                                  v!.trim().isEmpty ? 'Full name is required' : null,
                            ),

                            _buildField(
                              controller: phoneController,
                              placeholder: 'Phone Number',
                              icon: CupertinoIcons.phone,
                              keyboardType: TextInputType.phone,
                              validator: (v) =>
                                  v!.trim().length < 9 ? 'Invalid phone number' : null,
                            ),

                            _buildField(
                              controller: emailController,
                              placeholder: 'Email Address',
                              icon: CupertinoIcons.mail,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  !v!.contains('@') ? 'Invalid email address' : null,
                            ),

                            _buildField(
                              controller: passwordController,
                              placeholder: 'Password',
                              icon: CupertinoIcons.lock,
                              isPassword: true,
                              obscure: obscurePassword,
                              toggle: () => setState(
                                () => obscurePassword = !obscurePassword,
                              ),
                              validator: (v) =>
                                  v!.length < 6 ? 'Minimum 6 characters' : null,
                            ),

                            const SizedBox(height: 8),
                            // ── Section: Additional Info ──
                            _sectionLabel('Additional Information'),
                            const SizedBox(height: 12),

                            // ✅ Age + Gender في صف واحد
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildField(
                                    controller: ageController,
                                    placeholder: 'Age',
                                    icon: CupertinoIcons.calendar,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: _buildGenderDropdown(),
                                ),
                              ],
                            ),

                            _buildField(
                              controller: addressController,
                              placeholder: 'Address',
                              icon: CupertinoIcons.location,
                            ),

                            _buildField(
                              controller: medicalController,
                              placeholder: 'Medical Description (optional)',
                              icon: CupertinoIcons.doc_text,
                              maxLines: 3,
                            ),

                            // ✅ Error message box
                            if (errorMessage != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemRed
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: CupertinoColors.systemRed
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.exclamationmark_circle,
                                      color: CupertinoColors.systemRed,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage!,
                                        style: const TextStyle(
                                          color: CupertinoColors.systemRed,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 300.ms).shake(),
                            ],

                            const SizedBox(height: 24),

                            // ✅ زر Create Account
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: CupertinoButton(
                                color: const Color(0xFF1A3644),
                                borderRadius: BorderRadius.circular(16),
                                onPressed: loading ? null : register,
                                child: loading
                                    ? const CupertinoActivityIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // ✅ رابط تسجيل الدخول تحت الكارد
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: const Color(0xFF1A3644).withOpacity(0.65),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFF1A3644),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ عنوان القسم بنمط iOS
  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A3644).withOpacity(0.45),
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.35),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A3644).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.person_badge_plus,
            size: 44,
            color: Color(0xFF1A3644),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3644),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Fill in your details to get started',
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF1A3644).withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggle,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 15.5, color: Color(0xFF1A3644)),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            color: const Color(0xFF1A3644).withOpacity(0.38),
            fontSize: 15.5,
          ),
          prefixIcon: Icon(icon, size: 19, color: const Color(0xFF3A7A8A)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                    size: 19,
                    color: const Color(0xFF3A7A8A),
                  ),
                  onPressed: toggle,
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: const Color(0xFF1A3644).withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFF3A7A8A),
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: CupertinoColors.systemRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: CupertinoColors.systemRed,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: gender,
        dropdownColor: const Color(0xFFE8FAF8),
        borderRadius: BorderRadius.circular(14),
        style: const TextStyle(
          fontSize: 15.5,
          color: Color(0xFF1A3644),
        ),
        icon: const Icon(
          CupertinoIcons.chevron_down,
          size: 16,
          color: Color(0xFF3A7A8A),
        ),
        decoration: InputDecoration(
          hintText: 'Gender',
          prefixIcon: const Icon(
            CupertinoIcons.person_2,
            size: 19,
            color: Color(0xFF3A7A8A),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: const Color(0xFF1A3644).withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFF3A7A8A),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'male', child: Text('Male')),
          DropdownMenuItem(value: 'female', child: Text('Female')),
        ],
        onChanged: (v) {
          if (v != null) setState(() => gender = v);
        },
      ),
    );
  }
}
