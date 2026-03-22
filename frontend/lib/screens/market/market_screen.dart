import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/theme/colors.dart';
import '../../services/api_service.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  bool isGoldSelected = true;
  String selectedRange = 'All';
  double goldPrice = 6429.77;
  double silverPrice = 84.49;
  bool isAlertEnabled = false;
  bool isLoading = true;

  List<double> goldHistory = [6300, 6350, 6320, 6380, 6410, 6390, 6429.77];
  List<double> silverHistory = [80, 82, 81, 83, 84, 83, 84.49];
  Timer? _simulationTimer;

  final Color _bgColor = const Color(0xFF0D0D12);
  final Color _cardBgColor = const Color(0xFF16161E);
  final Color _goldPrimary = const Color(0xFFECB613);

  @override
  void initState() {
    super.initState();
    _fetchPrices();
    _startSimulation();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrices() async {
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

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      setState(() {
        double gChange = goldPrice * (0.0003 * (0.5 - (DateTime.now().second % 10) / 10));
        double sChange = silverPrice * (0.0005 * (0.5 - (DateTime.now().second % 8) / 8));
        goldPrice += gChange;
        silverPrice += sChange;
        goldHistory.add(goldPrice);
        silverHistory.add(silverPrice);
        if (goldHistory.length > 25) goldHistory.removeAt(0);
        if (silverHistory.length > 25) silverHistory.removeAt(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _goldPrimary)),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Live Trends', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
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
                    _buildPriceHeader(),
                    const SizedBox(height: 40),
                    _buildChartSection(),
                    const SizedBox(height: 32),
                    _buildTimeSelectors(),
                    const SizedBox(height: 48),
                    _buildAlertCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomCTA(),
    );
  }

  Widget _buildAssetToggle() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _toggleItem('Gold', isGoldSelected),
          _toggleItem('Silver', !isGoldSelected),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isGoldSelected = label == 'Gold'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: active ? _goldPrimary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: active ? Colors.black : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceHeader() {
    final price = isGoldSelected ? goldPrice : silverPrice;
    return Column(
      children: [
        Text(
          'Current ${isGoldSelected ? "Gold" : "Silver"} Price',
          style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          '₹${price.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 16),
            const SizedBox(width: 4),
            const Text('+₹124.50 (1.2%)', style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            const Text('vs yesterday', style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    final history = isGoldSelected ? goldHistory : silverHistory;
    return Container(
      height: 220,
      width: double.infinity,
      child: CustomPaint(
        painter: GlowChartPainter(
          isGoldSelected ? _goldPrimary : Colors.white60,
          history,
        ),
      ),
    );
  }

  Widget _buildTimeSelectors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['1D', '1W', '1M', '1Y', 'All'].map((t) => _timeBtn(t)).toList(),
    );
  }

  Widget _timeBtn(String t) {
    final active = selectedRange == t;
    return GestureDetector(
      onTap: () => setState(() => selectedRange = t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _goldPrimary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          t,
          style: TextStyle(color: active ? Colors.black : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _goldPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.notifications_active_rounded, color: _goldPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                const Text('Notify me when price drops', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: isAlertEnabled,
            onChanged: (v) => setState(() => isAlertEnabled = v),
            activeColor: _goldPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA() {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Row(
        children: [
          Expanded(
            child: _footerBtn('Sell', false),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _footerBtn('Buy Now', true),
          ),
        ],
      ),
    );
  }

  Widget _footerBtn(String label, bool primary) {
    return GestureDetector(
      onTap: () => context.push(label == 'Sell' ? '/sell' : '/buy', extra: {'isGold': isGoldSelected}),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: primary ? _goldPrimary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(color: primary ? Colors.black : Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class GlowChartPainter extends CustomPainter {
  final Color color;
  final List<double> data;
  GlowChartPainter(this.color, this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    double minVal = data.reduce((a, b) => a < b ? a : b);
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    double range = maxVal - minVal;
    if (range == 0) range = 1;

    double xStep = size.width / (data.length - 1);
    
    for (int i = 0; i < data.length; i++) {
      double x = i * xStep;
      double y = size.height - ((data[i] - minVal) / range * size.height * 0.8) - (size.height * 0.1);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Area Gradient
    final areaPath = Path.from(path);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.15), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
