import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  int _step = 1; // 1: Phone, 2: OTP, 3: New Password
  String? _resetToken;
  bool _isLoading = false;

  void _sendOtp() async {
    if (_phoneController.text.length < 10) return;
    setState(() => _isLoading = true);
    final result = await ApiService.sendForgotPasswordOtp(_phoneController.text);
    setState(() => _isLoading = false);
    
    if (result['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
    } else {
      setState(() => _step = 2);
    }
  }

  void _verifyOtp() async {
    if (_otpController.text.length < 6) return;
    setState(() => _isLoading = true);
    final result = await ApiService.verifyForgotPasswordOtp(_phoneController.text, _otpController.text);
    setState(() => _isLoading = false);
    
    if (result['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
    } else {
      setState(() {
        _resetToken = result['resetToken'];
        _step = 3;
      });
    }
  }

  void _resetPassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _isLoading = true);
    final result = await ApiService.resetPassword(_resetToken!, _passwordController.text);
    setState(() => _isLoading = false);
    
    if (result['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Your password has been reset. Please login with your new password.'),
          actions: [
            TextButton(onPressed: () => context.go('/login'), child: const Text('Login')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_step == 1) ...[
              const Text('Enter your registered phone number to receive an OTP.'),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixText: '+91 '),
              ),
              const SizedBox(height: 20),
              _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _sendOtp, child: const Text('Send OTP')),
            ],
            if (_step == 2) ...[
              Text('Enter the 6-digit OTP sent to ${_phoneController.text}'),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'OTP'),
              ),
              const SizedBox(height: 20),
              _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _verifyOtp, child: const Text('Verify OTP')),
            ],
            if (_step == 3) ...[
              const Text('Set your new login password.'),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
              ),
              const SizedBox(height: 20),
              _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _resetPassword, child: const Text('Reset Password')),
            ],
          ],
        ),
      ),
    );
  }
}
