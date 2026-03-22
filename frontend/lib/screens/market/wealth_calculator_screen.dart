import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../services/api_service.dart';

class WealthCalculatorScreen extends StatefulWidget {
  const WealthCalculatorScreen({super.key});

  @override
  State<WealthCalculatorScreen> createState() => _WealthCalculatorScreenState();
}

class _WealthCalculatorScreenState extends State<WealthCalculatorScreen> {
  final TextEditingController _amountController = TextEditingController(text: '2000');
  bool isGold = true;
  double amount = 2000.0;
  double tenureMonths = 12.0;
  bool isMonthlyTenure = true;
  bool isLoading = true;
  double goldPrice = 6429.77;
  double silverPrice = 84.49;

  final Color _bgColor = const Color(0xFF0D0D12);
  final Color _cardBgColor = const Color(0xFF16161E);
  final Color _goldPrimary = const Color(0xFFECB613);

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    try {
      final prices = await ApiService.fetchMarketPrices();
      if (mounted) {
        setState(() {
          goldPrice = (prices['gold'] ?? 6429.77).toDouble();
          silverPrice = (prices['silver'] ?? 84.49).toDouble();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _goldPrimary)),
      );
    }

    // ROI Logic: 14% p.a.
    const double annualRate = 0.14;
    double estimatedProfit = 0;
    if (isMonthlyTenure) {
      estimatedProfit = amount * (annualRate / 12) * tenureMonths;
    } else {
      estimatedProfit = amount * annualRate * tenureMonths;
    }
    final maturityValue = amount + estimatedProfit;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 24),
          onPressed: () => context.pop(),
        ),
        title: const Text('Wealth Planner', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAssetToggle(),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildProfitSection(estimatedProfit),
                    const SizedBox(height: 16),
                    _buildMaturityCard(amount, maturityValue),
                    const SizedBox(height: 48),
                    _buildInputCard(),
                    const SizedBox(height: 24),
                    _buildTenureSection(),
                    const SizedBox(height: 40),
                    _buildActionButtons(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetToggle() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _toggleBtn('Gold', isGold),
          _toggleBtn('Silver', !isGold),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isGold = label == 'Gold'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: active ? _goldPrimary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(label, style: TextStyle(color: active ? Colors.black : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildProfitSection(double profit) {
    return Column(
      children: [
        const Text('ESTIMATED PROFIT', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Text(
          '+₹${profit.toStringAsFixed(0)}',
          style: const TextStyle(color: Color(0xFF10B981), fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: -2),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(
            'YOU EARN ₹${profit.toStringAsFixed(0)} EXTRA',
            style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildMaturityCard(double invested, double maturity) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _statCol('TOTAL INVESTED', '₹${invested.toStringAsFixed(0)}'),
          Container(height: 32, width: 1, color: Colors.white.withValues(alpha: 0.05), margin: const EdgeInsets.symmetric(horizontal: 40)),
          _statCol('MATURITY VALUE', '₹${maturity.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _statCol(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INVESTMENT AMOUNT', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('₹', style: TextStyle(color: Colors.white24, fontSize: 32, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -2),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.white10)),
                  onChanged: (v) => setState(() => amount = double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTenureSection() {
    final maxVal = isMonthlyTenure ? 12.0 : 10.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white.withValues(alpha: 0.03))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SELECT TENURE', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
              _tenureToggle(),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            '${tenureMonths.toInt()} ${isMonthlyTenure ? "Months" : "Years"}',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _goldPrimary,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.05),
              thumbColor: Colors.white,
              overlayColor: _goldPrimary.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: tenureMonths.clamp(1, maxVal),
              min: 1,
              max: maxVal,
              onChanged: (v) => setState(() => tenureMonths = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tenureToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _tItem('Mo', isMonthlyTenure),
          _tItem('Yr', !isMonthlyTenure),
        ],
      ),
    );
  }

  Widget _tItem(String l, bool active) {
    return GestureDetector(
      onTap: () => setState(() {
        isMonthlyTenure = l == 'Mo';
        tenureMonths = isMonthlyTenure ? 12 : 5;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(l, style: TextStyle(color: active ? Colors.black : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _btn('Start Investing', _goldPrimary, Colors.black, () => context.push('/buy', extra: {'isGold': isGold})),
        const SizedBox(height: 16),
        _btn('View Saving Plans', Colors.white.withValues(alpha: 0.05), Colors.white, () => context.push('/savings')),
      ],
    );
  }

  Widget _btn(String label, Color bg, Color text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
