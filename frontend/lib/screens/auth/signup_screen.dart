import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  
  DateTime? _selectedDate;
  bool _formSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      if (_isUnder18(picked)) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be at least 18 years old to join SILVRA.')),
        );
      } else {
        setState(() {
          _selectedDate = picked;
          _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    }
  }

  bool _isUnder18(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age < 18;
  }

  void _handleCreateAccount() async {
    setState(() {
      _formSubmitted = true;
    });
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your Date of Birth.')),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
      );

      try {
        // Check if phone exists
        final phoneExists = await ApiService.checkPhoneExists(_phoneController.text);
        if (!context.mounted) return;
        if (phoneExists) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This phone number is already registered.')),
          );
          return;
        }

        // Check if email exists
        final emailExists = await ApiService.checkEmailExists(_emailController.text);
        if (!context.mounted) return;
        if (emailExists) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This email address is already registered.')),
          );
          return;
        }

        Navigator.pop(context); // Close loading
        context.go('/otp', extra: {
          'phone': _phoneController.text,
          'password': _passwordController.text,
          'name': _nameController.text,
          'email': _emailController.text,
          'dob': _dobController.text,
        });
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Network error. Please try again later.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFECC813)),
            onPressed: () => context.go('/login'),
          ),
          title: const Text(
            'SILVRA',
            style: TextStyle(
              color: Color(0xFF1A1C1C),
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.90,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            autovalidateMode: _formSubmitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create your account',
                        style: TextStyle(
                          color: Color(0xFF1A1C1C),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please provide your details to begin your journey.',
                        style: TextStyle(
                          color: Color(0xFF5D5E5F),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildLabel('FULL NAME'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Johnnathan Silver',
                        validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('DATE OF BIRTH (DD/MM/YYYY)'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _dobController,
                            hintText: 'Select your birth date',
                            validator: (val) => val == null || val.isEmpty ? 'Date of birth is required' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('EMAIL ADDRESS'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'john@vault.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                           if (val == null || val.isEmpty) return 'Email is required';
                           if (!val.contains('@')) return 'Invalid email address';
                           return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('MOBILE NUMBER'),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '+91',
                                style: TextStyle(
                                  color: Color(0xFF1A1C1C),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              hintText: '(555) 000-0000',
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Phone number is required';
                                if (val.length < 10) return 'Invalid phone number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('PASSWORD'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Minimum 8 characters',
                        obscureText: true,
                        validator: (val) => val == null || val.length < 8 ? 'Password must be at least 8 characters' : null,
                      ),
                      const SizedBox(height: 32),

                      GestureDetector(
                        onTap: _handleCreateAccount,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFF7E37B)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: -5,
                              )
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Create account',
                              style: TextStyle(
                                color: Color(0xFF241A00),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'By joining, you agree to our ',
                            style: const TextStyle(color: Color(0xFF5D5E5F), fontSize: 12),
                            children: [
                              TextSpan(
                                text: 'Terms of Gold Custody',
                                style: const TextStyle(color: Color(0xFF735C00), fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                Text(
                  '© 2024 The Digital Vault. Secure Institutional Grade Encryption.',
                  style: TextStyle(color: const Color(0xFFA0A0A0), fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFooterLink('Privacy\nPolicy'),
                    _buildFooterLink('Terms of Gold\nCustody'),
                    _buildFooterLink('Security\nGuarantee'),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF4D4635),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF1A1C1C), fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFD0C5AF)),
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1),
        ),
        errorStyle: const TextStyle(height: 0.8, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 10),
    );
  }
}
