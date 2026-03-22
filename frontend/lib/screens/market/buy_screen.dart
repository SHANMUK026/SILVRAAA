import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';

class BuyScreen extends StatefulWidget {
  final bool isGold;
  const BuyScreen({super.key, required this.isGold});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  bool isSIPMode = true;
  String selectedFrequency = 'Monthly';
  double investmentAmount = 500;
  double quantityInGrams = 2.0;
  bool isStepUpEnabled = true;

  final Color _bgColor = const Color(0xFF0D0D12);
  final Color _cardBgColor = const Color(0xFF16161E);
  final Color _goldPrimary = const Color(0xFFECB613);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 24),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Need Help?', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProjectedHeader(),
                  const SizedBox(height: 32),
                  _buildModeToggle(),
                  const SizedBox(height: 40),
                  if (isSIPMode) _buildSIPSection() else _buildOneTimeSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProjectedHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Text(
            'Projected returns in 5 years',
            style: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            isSIPMode ? '₹3,54,367' : '₹50,315',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Earnings: ',
                style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
              ),
              Text(
                isSIPMode ? '₹80,617 🎉' : '₹20,455 🎉',
                style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildAssetMiniature(),
        ],
      ),
    );
  }

  Widget _buildAssetMiniature() {
    return Container(
      height: 60,
      width: 120,
      child: CustomPaint(
        painter: AssetStackPainter(widget.isGold),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          _modeBtn('Setup SIP', isSIPMode),
          _modeBtn('One Time', !isSIPMode),
        ],
      ),
    );
  }

  Widget _modeBtn(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isSIPMode = label == 'Setup SIP'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: active ? _goldPrimary : Colors.transparent, borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: active ? Colors.black : Colors.white38, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSIPSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequency', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Daily', 'Weekly', 'Monthly'].map((f) => _choiceChip(f, selectedFrequency == f, (v) {
            setState(() => selectedFrequency = f);
          })).toList(),
        ),
        const SizedBox(height: 40),
        _buildAmountInput('Investment Amount', '₹${investmentAmount.toInt()}', (v) {
          setState(() => investmentAmount = v);
        }, 100, 5000),
        const SizedBox(height: 32),
        _buildStepUpCard(),
      ],
    );
  }

  Widget _buildOneTimeSection() {
    return Column(
      children: [
        _buildPriceIndicator(),
        const SizedBox(height: 40),
        _buildAmountInput('Investment Quantity', '${quantityInGrams}gm', (v) {
          setState(() => quantityInGrams = (v * 2).round() / 2.0);
        }, 0.5, 50),
      ],
    );
  }

  Widget _buildPriceIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _goldPrimary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('Market Price (24k)', style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            '₹ ${widget.isGold ? '6,429.77' : '84.49'}',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text('per 1 gram', style: TextStyle(color: Colors.white24, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAmountInput(String title, String valStr, Function(double) onVal, double min, double max) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 16),
        Text(valStr, style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _goldPrimary,
            inactiveTrackColor: Colors.white.withOpacity(0.05),
            thumbColor: Colors.white,
            overlayColor: _goldPrimary.withOpacity(0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: title.contains('Quantity') ? quantityInGrams : investmentAmount,
            min: min,
            max: max,
            onChanged: onVal,
          ),
        ),
      ],
    );
  }

  Widget _choiceChip(String label, bool active, Function(bool) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(true),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? _goldPrimary.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: active ? _goldPrimary : Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: active ? _goldPrimary : Colors.white24, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildStepUpCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Checkbox(
            value: isStepUpEnabled,
            activeColor: _goldPrimary,
            checkColor: Colors.black,
            onChanged: (v) => setState(() => isStepUpEnabled = v!),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Annual Step-up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Increase SIP by 10% every year', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: _bgColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, -10))],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _goldPrimary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(
          isSIPMode ? 'Proceed to Setup' : 'View Summary',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class AssetStackPainter extends CustomPainter {
  final bool isGold;
  AssetStackPainter(this.isGold);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: isGold 
            ? [const Color(0xFFFFD700), const Color(0xFFDAA520)]
            : [const Color(0xFFE5E7EB), const Color(0xFF9CA3AF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    double w = 60, h = 18;
    for (int i = 0; i < 3; i++) {
      double offset = i * 8.0;
      canvas.drawRRect(RRect.fromLTRBR(size.width/2 - w/2 + offset/2, size.height - h - offset, size.width/2 + w/2 + offset/2, size.height - offset, const Radius.circular(4)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
