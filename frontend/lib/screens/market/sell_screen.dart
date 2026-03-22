import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/primary_button.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _amountController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Sell 24K Gold'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Live Sell Price', style: TextStyle(color: AppColors.textHint)),
                    Text('₹6,300.00 / gm', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.error)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('Available Balance: 15.402 gm', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              
              const Center(child: Text('Sell in gm', style: TextStyle(color: AppColors.textHint))),
              const SizedBox(height: 16),

              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  suffixText: ' gm',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '0',
                ),
              ),
              
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Minimum sell quantity is 0.0001 gm',
                  style: TextStyle(color: AppColors.warning),
                ),
              ),

              const Spacer(),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Amount to Wallet'),
                    Text('₹ 0.00', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Swipe to Sell',
                onPressed: () {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sale successful. Wallet updated.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    if (context.mounted) context.go('/home');
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
