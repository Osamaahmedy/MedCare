import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/ui_helpers.dart';

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

    try {
      setState(() => loading = true);

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

      UIHelpers.showMessage(context, 'Account created successfully', true);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      UIHelpers.showMessage(
        context,
        'Something went wrong. Please check your data.',
        false,
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
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
            colors: [
              Color.fromARGB(255, 160, 227, 217),
              Color.fromARGB(255, 214, 246, 244),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 28),

                          _buildField(
                            controller: nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (v) =>
                                v!.isEmpty ? 'Full name is required' : null,
                          ),

                          _buildField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_iphone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                v!.length < 9 ? 'Invalid phone number' : null,
                          ),

                          _buildField(
                            controller: emailController,
                            label: 'Email Address',
                            icon: Icons.alternate_email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                !v!.contains('@')
                                    ? 'Invalid email address'
                                    : null,
                          ),

                          _buildField(
                            controller: passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscure: obscurePassword,
                            toggle: () => setState(
                              () => obscurePassword = !obscurePassword,
                            ),
                            validator: (v) =>
                                v!.length < 6
                                    ? 'Password is too short'
                                    : null,
                          ),

                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildField(
                                  controller: ageController,
                                  label: 'Age',
                                  icon: Icons.cake_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 3,
                                child: _buildGenderDropdown(),
                              ),
                            ],
                          ),

                          _buildField(
                            controller: addressController,
                            label: 'Address',
                            icon: Icons.location_on_outlined,
                          ),

                          _buildField(
                            controller: medicalController,
                            label: 'Medical Description',
                            icon: Icons.notes_rounded,
                            maxLines: 2,
                          ),

                          const SizedBox(height: 30),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Icon(
          Icons.person_add_alt_1_rounded,
          size: 52,
          color: Color(0xFF1A3644),
        ),
        SizedBox(height: 12),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A3644),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Fill the details below to get started',
          style: TextStyle(fontSize: 14, color: Color(0xFF5A8E9E)),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggle,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF1A3644)),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1A3644)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: const Color(0xFF1A3644),
                  ),
                  onPressed: toggle,
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.45),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        value: gender,
        dropdownColor: const Color.fromARGB(255, 214, 246, 244),
        decoration: const InputDecoration(
          labelText: 'Gender',
          labelStyle: TextStyle(color: Color(0xFF1A3644)),
          border: InputBorder.none,
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: loading ? null : register,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A3644),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
