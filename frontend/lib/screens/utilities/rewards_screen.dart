import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/api_service.dart';
import '../../core/theme/colors.dart';
import 'package:go_router/go_router.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  int _auraCoins = 1250;
  String _tier = 'Gold Member';
  bool _isLoading = true;
  late AnimationController _spinController;
  final math.Random _random = math.Random();

  final Color _bgColor = const Color(0xFF0D0D12);
  final Color _cardBgColor = const Color(0xFF16161E);
  final Color _goldPrimary = const Color(0xFFECB613);

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _loadRewards();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _loadRewards() async {
    try {
      final data = await ApiService.fetchRewards();
      if (mounted) {
        setState(() {
          _auraCoins = data['aura_coins'] ?? 1250;
          _tier = data['tier']?.toString() ?? 'Gold Member';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSpin() {
    if (_spinController.isAnimating) return;
    
    final prizes = ['50 Aura Coins', 'Gold Voucher', 'Silver Bar', '10 Aura Coins', 'Aura NFT', '24K Gold (0.1g)'];
    final prize = prizes[_random.nextInt(prizes.length)];

    _spinController.forward(from: 0).then((_) {
      _spinController.reset();
      _showPrizeModal(prize);
      _loadRewards();
    });
  }

  void _showPrizeModal(String prize) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _cardBgColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: _goldPrimary.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: _goldPrimary.withOpacity(0.2), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSuccessIcon(),
              const SizedBox(height: 24),
              const Text('CONGRATULATIONS!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 12),
              Text('You won $prize!', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: _goldPrimary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('REDEEM NOW', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(color: _goldPrimary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: _goldPrimary.withOpacity(0.5), blurRadius: 20)]),
      child: const Icon(Icons.emoji_events_rounded, color: Colors.black, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: _bgColor, body: Center(child: CircularProgressIndicator(color: _goldPrimary)));
    }

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeroStats(),
                const SizedBox(height: 40),
                _buildLuckWheelSection(),
                const SizedBox(height: 60),
                _buildMarketSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: _bgColor,
      floating: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => context.pop()),
      title: const Text('LOYALTY REWARDS', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.info_outline_rounded, color: Colors.white60), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AURA CREDITS', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Text('$_auraCoins', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: _goldPrimary, borderRadius: BorderRadius.circular(12)),
                child: Text(_tier.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: _goldPrimary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bronze', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('250 till Platinum ✨', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Gold', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuckWheelSection() {
    return Column(
      children: [
        const Text('WIN EXCLUSIVE REWARDS', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 48),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildWheelGlow(),
            AnimatedBuilder(
              animation: _spinController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spinController.value * 2 * math.pi * 10,
                  child: Container(
                    width: 320,
                    height: 320,
                    child: CustomPaint(painter: LuxuryWheelPainter(_goldPrimary)),
                  ),
                );
              },
            ),
            _buildWheelCenter(),
            Positioned(top: -10, child: Icon(Icons.arrow_drop_down_rounded, color: _goldPrimary, size: 70)),
          ],
        ),
        const SizedBox(height: 60),
        GestureDetector(
          onTap: _handleSpin,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            decoration: BoxDecoration(
              color: _goldPrimary,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: _goldPrimary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: const Text('SPIN NOW (FREE)', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildWheelGlow() {
    return Container(
      width: 340,
      height: 340,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: _goldPrimary.withOpacity(0.08), blurRadius: 80, spreadRadius: 20)],
      ),
    );
  }

  Widget _buildWheelCenter() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15)]),
      child: Center(child: Icon(Icons.auto_awesome_rounded, color: _goldPrimary, size: 30)),
    );
  }

  Widget _buildMarketSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('REDEEM STORE', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              Text('View More', style: TextStyle(color: _goldPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _rewardCard('Digital Gold (0.1g)', '2000 Aura', 'https://img.freepik.com/premium-photo/gold-coin-isolated-black-background_825501-155.jpg'),
          const SizedBox(height: 16),
          _rewardCard('Zomato Voucher', '500 Aura', 'https://img.freepik.com/free-vector/discount-voucher-template-with-golden-details_23-2148386470.jpg'),
        ],
      ),
    );
  }

  Widget _rewardCard(String title, String cost, String img) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(cost, style: TextStyle(color: _goldPrimary, fontSize: 12, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: const Text('Redeem', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class LuxuryWheelPainter extends CustomPainter {
  final Color primary;
  LuxuryWheelPainter(this.primary);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = primary.withOpacity(0.3);

    const int segments = 8;
    const double sweepAngle = 2 * math.pi / segments;

    for (int i = 0; i < segments; i++) {
      paint.color = i % 2 == 0 ? const Color(0xFF16161E) : const Color(0xFF231F14);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i * sweepAngle, sweepAngle, true, paint);
      
      // Outer border for each segment
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i * sweepAngle, sweepAngle, true, borderPaint);

      // Add small circles at the perimeter
      final orbitPaint = Paint()..color = primary.withOpacity(0.5)..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(center.dx + radius * math.cos(i * sweepAngle), center.dy + radius * math.sin(i * sweepAngle)), 3, orbitPaint);
    }

    // Outer ring
    canvas.drawCircle(center, radius, borderPaint..strokeWidth = 8..color = primary);
    canvas.drawCircle(center, radius - 4, borderPaint..strokeWidth = 1..color = Colors.black.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
