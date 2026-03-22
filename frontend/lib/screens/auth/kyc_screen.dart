import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _aadharController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _handleSubmitKyc() async {
    if (_aadharController.text.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 12-digit Aadhar number.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await ApiService.submitKyc(_aadharController.text, pan: _panController.text);

    if (mounted) {
      setState(() => _isSubmitting = false);
      
      if (result['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.redAccent),
        );
      } else {
        // Show Success
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('KYC Submitted'),
              ],
            ),
            content: const Text('Your identity verification is being processed. You can now access your dashboard.'),
            actions: [
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Proceed to Home', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    }
  }

  void _handleDigiLockerKyc() async {
    setState(() => _isSubmitting = true);
    final result = await ApiService.initiateSurepassKyc();
    setState(() => _isSubmitting = false);

    if (result['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
    } else if (result['url'] != null) {
      final url = Uri.parse(result['url']);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        // After launching, we expect the user to come back. 
        // We can show a dialog saying "Waiting for verification"
        _showWaitingDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch verification URL')));
      }
    }
  }

  void _showWaitingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verification in Progress'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFD4AF37)),
            SizedBox(height: 20),
            Text('Once you complete the DigiLocker flow in your browser, we will automatically update your status.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Check Status')),
        ],
      ),
    );
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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1C)),
            onPressed: () => context.go('/otp'),
          ),
          title: const Text(
            'Identity Verification',
            style: TextStyle(
              color: Color(0xFF1A1C1C),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Progress Header
              Row(
                children: [
                   _buildStepIndicator(1, "Basic Details", true),
                   _buildConnector(true),
                   _buildStepIndicator(2, "Identity", true),
                   _buildConnector(false),
                   _buildStepIndicator(3, "Finish", false),
                ],
              ),
              const SizedBox(height: 40),

              const Text(
                'Verify your Identity',
                style: TextStyle(
                  color: Color(0xFF1A1C1C),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'To comply with UIDAI and RBI regulations, please provide your identification details.',
                style: TextStyle(
                  color: Color(0xFF5D5E5F),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // DigiLocker Option
              GestureDetector(
                onTap: _handleDigiLockerKyc,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.flash_on, color: Color(0xFFD4AF37), size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fast Verify via DigiLocker',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1C1C)),
                          ),
                          Text(
                            'Instant approval in 60 seconds',
                            style: TextStyle(fontSize: 12, color: Color(0xFF5D5E5F)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Color(0xFFD4AF37)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR USE MANUAL FORM', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                ],
              ),
              const SizedBox(height: 32),

              _buildLabel('AADHAR NUMBER'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _aadharController,
                hintText: '0000 0000 0000',
                keyboardType: TextInputType.number,
                maxLength: 12,
              ),
              const SizedBox(height: 24),

              _buildLabel('PAN NUMBER (OPTIONAL)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _panController,
                hintText: 'ABCDE1234F',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 48),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD709).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD709).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF735C00), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your data is encrypted and stored securely following institutional-grade standards.',
                        style: TextStyle(
                          color: Color(0xFF735C00),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _isSubmitting
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                  : GestureDetector(
                      onTap: _handleSubmitKyc,
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
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Submit Verification',
                            style: TextStyle(
                              color: Color(0xFF241A00),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isCompleted) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isCompleted ? const Color(0xFFD4AF37) : const Color(0xFFE0E0E0),
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text('$step', style: const TextStyle(fontSize: 12, color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF5D5E5F))),
      ],
    );
  }

  Widget _buildConnector(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: active ? const Color(0xFFD4AF37) : const Color(0xFFE0E0E0),
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
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: const TextStyle(color: Color(0xFF1A1C1C), fontSize: 14),
        decoration: InputDecoration(
          counterText: "",
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFD0C5AF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
