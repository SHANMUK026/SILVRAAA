import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import 'dart:async';

class OtpScreen extends StatefulWidget {
  final dynamic phoneNumber; // Can be String (login) or Map (signup)
  const OtpScreen({super.key, this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  Timer? _timer;
  int _start = 45;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
    );

    try {
      if (widget.phoneNumber is Map) {
        // SIGNUP FLOW: Call register
        final data = widget.phoneNumber as Map;
        final result = await ApiService.register(
          name: data['name'],
          email: data['email'],
          phone: data['phone'],
          password: data['password'],
        );

        if (!mounted) return;
        Navigator.pop(context); // Close loading

        if (result['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
          return;
        }
      } else {
        // LOGIN/FORGOT PASSWORD: Just verify OTP (Simulator logic)
        await Future.delayed(const Duration(seconds: 1)); // Simulate check
        if (!mounted) return;
        Navigator.pop(context); // Close loading
      }

      if (mounted) context.go('/kyc');
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeStr = '00:${_start.toString().padLeft(2, '0')}';
    
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1C)),
            onPressed: () => context.go('/signup'),
          ),
          title: const Text(
            'Verification',
            style: TextStyle(
              color: Color(0xFF1A1C1C),
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                const Color(0xFFFFD709).withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Verify your phone',
                        style: TextStyle(
                          color: Color(0xFF1A1C1C),
                          fontSize: 28,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(color: Color(0xFF5D5E5F), fontSize: 14, fontFamily: 'Inter'),
                          children: [
                            const TextSpan(text: 'Enter the 6-digit code sent to '),
                            TextSpan(
                              text: widget.phoneNumber is Map ? (widget.phoneNumber as Map)['phone'] : (widget.phoneNumber ?? '+91 98765 43210'),
                              style: const TextStyle(color: Color(0xFF1A1C1C), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // 6-digit OTP Inputs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) => _buildOtpBox(index)),
                      ),
                      const SizedBox(height: 48),

                      // Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined, size: 20, color: Color(0xFFECC813)),
                          const SizedBox(width: 8),
                          Text(
                            'Resend code in $timeStr',
                            style: const TextStyle(
                              color: Color(0xFFECC813),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Spam Link
                      const Text.rich(
                        TextSpan(
                          text: 'Didn\'t receive the code? ',
                          style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 13),
                          children: [
                            TextSpan(
                              text: 'Check Spam',
                              style: TextStyle(color: Color(0xFF435942), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Verify Button
                      GestureDetector(
                        onTap: _verifyOtp,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD709),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD709).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: -5,
                              )
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Verify & Proceed',
                              style: TextStyle(
                                color: Color(0xFF5B4B00),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer Icons
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFooterIcon(Icons.shield_outlined, 'SECURITY'),
                    const SizedBox(width: 60),
                    _buildFooterIcon(Icons.help_outline, 'HELP'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 46,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus ? const Color(0xFFECC813) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Center(
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1C1C)),
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
            hintText: "·",
            hintStyle: TextStyle(color: Color(0xFFA0A0A0), fontSize: 24),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Icon(icon, color: const Color(0xFFA0A0A0), size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFA0A0A0),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
