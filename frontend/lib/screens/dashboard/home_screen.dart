import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/common/swipe_to_save.dart';
import '../../widgets/dashboard/profile_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String kycStatus = 'pending';
  String userName = 'User';
  double goldBalance = 0.0;
  double silverBalance = 0.0;
  double inrBalance = 0.0;
  bool isLoading = true;
  double goldPrice = 6245.0;
  double silverPrice = 80.0;
  bool isGoldSelected = true;
  double quickSaveAmount = 2000;
  Timer? _priceTimer;
  Timer? _scrollTimer;
  bool _showGoldInPill = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Color _bgColor = const Color(0xFF0D0D12);
  final Color _cardBgColor = const Color(0xFF16161E);
  final Color _goldPrimary = const Color(0xFFECB613);

  @override
  void initState() {
    super.initState();
    _fetchData();
    _priceTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchData();
    });
    
    _scrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() => _showGoldInPill = !_showGoldInPill);
      }
    });
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    _scrollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final status = await ApiService.checkKycStatus();
      final balances = await ApiService.fetchBalance();
      final prices = await ApiService.fetchMarketPrices();
      final profile = await ApiService.fetchProfile();
      
      if (mounted) {
        setState(() {
          kycStatus = status;
          if (profile['full_name'] != null) {
            userName = profile['full_name'].toString().split(' ')[0];
          }
          goldBalance = (balances['gold_grams'] ?? 0.0).toDouble();
          silverBalance = (balances['silver_grams'] ?? 0.0).toDouble();
          inrBalance = (balances['inr_wallet'] ?? 0.0).toDouble();
          goldPrice = (prices['gold'] ?? 6245.0).toDouble();
          silverPrice = (prices['silver'] ?? 80.0).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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

    return Scaffold(
      key: _scaffoldKey,
      drawer: const ProfileDrawer(),
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _buildLivePriceIndicator(),
        leading: IconButton(
          icon: const Icon(Icons.sort_rounded, color: Colors.white, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: _goldPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildWelcomeHeader(),
                const SizedBox(height: 24),
                _buildPortfolioCard(),
                const SizedBox(height: 32),
                _buildQuickActionsGrid(),
                const SizedBox(height: 32),
                _buildQuickSaveSection(),
                const SizedBox(height: 32),
                _buildSavingsPlansSection(),
                const SizedBox(height: 32),
                _buildRecommendedSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLivePriceIndicator() {
    return GestureDetector(
      onTap: () => context.push('/market'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _goldPrimary.withValues(alpha: 0.2)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Row(
            key: ValueKey<bool>(_showGoldInPill),
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _showGoldInPill ? _goldPrimary : Colors.white60,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_showGoldInPill ? "Gold" : "Silver"} ₹${(_showGoldInPill ? goldPrice : silverPrice).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $userName! ✨',
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        const Text(
          'Welcome to your digital vault',
          style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPortfolioCard() {
    final balance = isGoldSelected ? (goldBalance * goldPrice) : (silverBalance * silverPrice);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL BALANCE', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              _buildSmallToggle(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${balance.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _portfolioStat('GOLD', '$goldBalance g', _goldPrimary),
              const SizedBox(width: 32),
              _portfolioStat('SILVER', '$silverBalance g', Colors.white60),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _actionBtn('Deposit', Icons.add_rounded, false)),
              const SizedBox(width: 12),
              Expanded(child: _actionBtn('Buy Now', Icons.shopping_cart_rounded, true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          _miniToggleItem('Gold', isGoldSelected),
          _miniToggleItem('Silver', !isGoldSelected),
        ],
      ),
    );
  }

  Widget _miniToggleItem(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => isGoldSelected = label == 'Gold'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: active ? _goldPrimary : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(color: active ? Colors.black : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _portfolioStat(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _actionBtn(String label, IconData icon, bool primary) {
    return GestureDetector(
      onTap: () => context.push(primary ? '/buy' : '/wallet'),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: primary ? _goldPrimary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primary ? Colors.black : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: primary ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      children: [
        _quickActionIcon(Icons.savings_rounded, 'Buy Gold', '/buy', {'isGold': true}),
        _quickActionIcon(Icons.stars_rounded, 'Buy Silver', '/buy', {'isGold': false}),
        _quickActionIcon(Icons.calculate_rounded, 'Calculator', '/calculator', null),
        _quickActionIcon(Icons.local_shipping_rounded, 'Delivery', '/delivery', null),
      ],
    );
  }

  Widget _quickActionIcon(IconData icon, String label, String route, dynamic extra) {
    return GestureDetector(
      onTap: () => context.push(route, extra: extra),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _cardBgColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
            child: Icon(icon, color: _goldPrimary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickSaveSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SWIPE TO SAVE', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          SwipeToSave(
            amount: quickSaveAmount,
            onSwipeCompleted: _handleSwipeToSave,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [500, 1000, 2000, 5000].map((amt) => _amountChip(amt.toDouble())).toList(),
          ),
        ],
      ),
    );
  }

  Widget _amountChip(double amt) {
    final active = quickSaveAmount == amt;
    return GestureDetector(
      onTap: () => setState(() => quickSaveAmount = amt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _goldPrimary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('₹${amt.toInt()}', style: TextStyle(color: active ? Colors.black : Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSavingsPlansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SAVINGS PLANS', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _planItem('Daily Gold SIP', 'Save from ₹10/day', Icons.calendar_today_rounded, _goldPrimary),
        _planItem('Monthly Silver SIP', 'Save from ₹500/month', Icons.stars_rounded, Colors.white60),
      ],
    );
  }

  Widget _planItem(String title, String sub, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => context.push('/savings'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.03))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11))])),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white12, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECOMMENDED', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _promoCard('Refer & Earn Gold', 'Earn up to ₹500 gold for every friend.', Icons.people_rounded),
              _promoCard('Secure Vaulting', 'Your gold is insured by Brink\'s.', Icons.shield_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _promoCard(String title, String sub, IconData icon) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [_cardBgColor, _bgColor]), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _goldPrimary, size: 28),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Future<void> _handleSwipeToSave() async {
    final result = await ApiService.invest(
      amount: quickSaveAmount,
      assetType: isGoldSelected ? 'gold' : 'silver',
    );

    if (mounted) {
      if (result['success'] == true) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(32)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded, color: AppColors.goldPrimary, size: 80),
                  const SizedBox(height: 24),
                  const Text('Success!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('₹${quickSaveAmount.toInt()} invested successfully.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: _goldPrimary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('GREAT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
      }
    }
  }
}
