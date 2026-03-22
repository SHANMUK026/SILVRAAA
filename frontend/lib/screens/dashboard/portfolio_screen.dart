import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  double goldGrams = 0.0;
  double silverGrams = 0.0;
  double goldValue = 0.0;
  double silverValue = 0.0;
  List<dynamic> transactions = [];
  List<dynamic> sips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.fetchBalance(),
        ApiService.fetchTransactions(),
        ApiService.fetchSips(),
        ApiService.fetchMarketPrices(),
      ]);

      if (mounted) {
        setState(() {
          final balance = results[0] as Map<String, dynamic>;
          final prices = results[3] as Map<String, dynamic>;
          
          goldGrams = (balance['gold_grams'] ?? 0.0).toDouble();
          silverGrams = (balance['silver_grams'] ?? 0.0).toDouble();
          
          // Calculate values locally if backend doesn't provide them
          final double gPrice = (prices['gold'] ?? 6500.0).toDouble();
          final double sPrice = (prices['silver'] ?? 85.0).toDouble();
          
          goldValue = balance['gold_value_inr']?.toDouble() ?? (goldGrams * gPrice);
          silverValue = balance['silver_value_inr']?.toDouble() ?? (silverGrams * sPrice);
          
          transactions = results[1] as List<dynamic>;
          sips = results[2] as List<dynamic>;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading portfolio data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.goldPrimary)));
    }

    final double totalValue = goldValue + silverValue;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.goldPrimary,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header
                _buildPremiumHeader(totalValue),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      _buildSectionHeader('YOUR HOLDINGS'),
                      const SizedBox(height: 16),
                      _buildMetalCard('24K GOLD', goldGrams, goldValue, AppColors.goldPrimary, 'gm'),
                      const SizedBox(height: 16),
                      _buildMetalCard('99.9% SILVER', silverGrams, silverValue, const Color(0xFF475569), 'gm'),
                      
                      const SizedBox(height: 32),
                      if (sips.isNotEmpty) ...[
                        _buildSectionHeader('SAVINGS PLANS'),
                        const SizedBox(height: 16),
                        ...sips.map((sip) => _buildSipCard(sip)),
                        const SizedBox(height: 32),
                      ],

                      _buildSectionHeader('RECENT ACTIVITY'),
                      const SizedBox(height: 16),
                      if (transactions.isEmpty)
                        _buildEmptyTransactions()
                      else
                        ...transactions.take(5).map((txn) => _buildTransactionItem(txn)),
                      
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(double totalValue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL WEALTH VALUE',
            style: TextStyle(
              color: Color(0x99FFFFFF),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '₹ ${totalValue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFFECC813),
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildPnlBadge('+₹1,240 (12.4%)'),
        ],
      ),
    );
  }

  Widget _buildPnlBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x1A10B981),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x3310B981)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 14),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildMetalCard(String title, double qty, double value, Color color, String unit) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    qty.toStringAsFixed(3),
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.2),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(unit, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('VALUE TODAY', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                '₹ ${value.toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSipCard(dynamic sip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.sync_rounded, color: Color(0xFF0F172A), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${sip['asset_type'].toUpperCase()} PLAN', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Text('${sip['frequency'].toUpperCase()} - ₹ ${sip['amount']}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
              ],
            ),
          ),
          const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.history_rounded, color: Colors.grey.withValues(alpha: 0.3), size: 48),
          const SizedBox(height: 16),
          const Text('Your journey begins soon!', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(dynamic txn) {
    final isCredit = txn['type'] == 'invest' || txn['type'] == 'reward_convert';
    DateTime date;
    try {
      date = DateTime.parse(txn['created_at'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      date = DateTime.now();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isCredit ? const Color(0x1A10B981) : const Color(0x1AF1F5F9)),
              shape: BoxShape.circle
            ),
            child: Icon(
              isCredit ? Icons.add_rounded : Icons.remove_rounded, 
              color: isCredit ? const Color(0xFF10B981) : const Color(0xFF0F172A), 
              size: 20
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn['type'].toString().replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                Text(DateFormat('dd MMM, hh:mm a').format(date), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? "+" : "-"} ₹${txn['amount']}', 
                style: TextStyle(fontWeight: FontWeight.w800, color: isCredit ? const Color(0xFF10B981) : const Color(0xFF0F172A))
              ),
              if (txn['quantity_grams'] != null)
                Text('${txn['quantity_grams']}g', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}
