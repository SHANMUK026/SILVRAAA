import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../widgets/custom_app_bar.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool isGold = true;
  double amount = 10000;
  
  @override
  Widget build(BuildContext context) {
    double pricePerGram = isGold ? 6450.0 : 85.5;
    double gm = amount / pricePerGram;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Metal Calculator'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Toggle Metal
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isGold ? AppColors.goldPrimary.withValues(alpha: 0.1) : Colors.transparent,
                        side: BorderSide(color: isGold ? AppColors.goldPrimary : AppColors.border),
                      ),
                      onPressed: () => setState(() => isGold = true),
                      child: Text('24K Gold', style: TextStyle(color: isGold ? AppColors.goldPrimary : AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: !isGold ? AppColors.silverPrimary.withValues(alpha: 0.1) : Colors.transparent,
                        side: BorderSide(color: !isGold ? AppColors.silverPrimary : AppColors.border),
                      ),
                      onPressed: () => setState(() => isGold = false),
                      child: Text('99.9% Silver', style: TextStyle(color: !isGold ? AppColors.silverPrimary : AppColors.textPrimary)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              const Text('Enter Rupee Amount', style: TextStyle(color: AppColors.textHint)),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: '10000',
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                onChanged: (val) {
                  setState(() {
                    amount = double.tryParse(val) ?? 0.0;
                  });
                },
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),

              const SizedBox(height: 48),
              
              const Icon(Icons.swap_vert, size: 40, color: AppColors.textSecondary),
              const SizedBox(height: 48),

              const Text('You will get approx', style: TextStyle(color: AppColors.textHint)),
              const SizedBox(height: 16),
              Text(
                '${gm.toStringAsFixed(4)} gm',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: isGold ? AppColors.goldPrimary : AppColors.silverPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text('At ₹$pricePerGram / gm', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
