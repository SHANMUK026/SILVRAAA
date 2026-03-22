import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
        automaticallyImplyLeading: false, // Root Level
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 15,
        separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 24),
        itemBuilder: (context, index) {
          final isBuy = index % 3 == 0;
          final isSell = index % 3 == 1;
          
          String title = isBuy ? 'Bought 24K Gold' : (isSell ? 'Sold 99.9% Silver' : 'Withdrawal to Bank');
          String amount = isBuy ? '+0.500 gm' : (isSell ? '-2.000 gm' : '₹ 5,000');
          String sub = isBuy ? '₹ 3,225.00' : (isSell ? '₹ 171.00' : 'HDFC Bank ending 1234');
          Color iconColor = isBuy ? AppColors.goldPrimary : (isSell ? AppColors.silverPrimary : AppColors.accentBlue);
          IconData icon = isBuy ? Icons.add_circle_outline : (isSell ? Icons.remove_circle_outline : Icons.account_balance);

          return Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withValues(alpha: 0.1),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Oct 12, 2025 • 14:32 PM', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount, style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: isBuy ? AppColors.success : AppColors.textPrimary,
                  )),
                  Text(sub, style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
