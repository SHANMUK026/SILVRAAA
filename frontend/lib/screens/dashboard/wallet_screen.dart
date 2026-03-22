import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../services/api_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _inrBalance = 0.0;
  bool _isLoading = true;
  final TextEditingController _amountController = TextEditingController();

  final Color _bgColor = const Color(0xFF0D0D12);
  final Color _cardBgColor = const Color(0xFF16161E);
  final Color _goldPrimary = const Color(0xFFECB613);

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final data = await ApiService.fetchBalance();
      if (mounted) {
        setState(() {
          _inrBalance = (data['inr_wallet'] ?? 0.0).toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAddMoney() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount'), behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // In a real app we'd use Razorpay. Let's mock the success flow.
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _inrBalance += amount;
          _isLoading = false;
          _amountController.clear();
        });
        _showSuccessDialog(amount);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(double amount) {
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
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 80),
              const SizedBox(height: 24),
              const Text('LOADED!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Text('₹$amount added to your secure wallet.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: _goldPrimary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('PROCEED', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 40),
                  _buildAddMoneyCard(),
                  const SizedBox(height: 40),
                  _buildQuickActionSection(),
                  const SizedBox(height: 40),
                  _buildTransactionHistory(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: _bgColor,
      expandedHeight: 60,
      title: const Text('SECURE WALLET', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, color: _goldPrimary, size: 14),
              const SizedBox(width: 8),
              const Text('PROTECTED VAULT', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '₹${_inrBalance.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(Icons.south_west_rounded, 'INFLOW', '₹45,000'),
              Container(width: 1, height: 20, color: Colors.white10),
              _statItem(Icons.north_east_rounded, 'SPENT', '₹12,240'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String val) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white24, size: 12),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildAddMoneyCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('LOAD FUNDS', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Column(
            children: [
              Row(
                children: [
                  Text('₹', style: TextStyle(color: _goldPrimary, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter Amount', hintStyle: TextStyle(color: Colors.white12, fontSize: 18)),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white10, height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [500, 1000, 2000, 5000].map((a) => _quickPill(a)).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleAddMoney,
                  style: ElevatedButton.styleFrom(backgroundColor: _goldPrimary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('ADD TO WALLET', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickPill(int a) {
    return GestureDetector(
      onTap: () => setState(() => _amountController.text = a.toString()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Text('+₹$a', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildQuickActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('FAST BUY', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Row(
          children: [
            _actionTile('BUY GOLD', Icons.stars_rounded, () => context.go('/buy', extra: true)),
            const SizedBox(width: 16),
            _actionTile('BUY SILVER', Icons.blur_on_rounded, () => context.go('/buy', extra: false)),
          ],
        ),
      ],
    );
  }

  Widget _actionTile(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Column(
            children: [
              Icon(icon, color: _goldPrimary, size: 28),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('HISTORY', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            TextButton(onPressed: () => context.go('/history'), child: Text('VIEW ALL', style: TextStyle(color: _goldPrimary, fontSize: 10, fontWeight: FontWeight.w900))),
          ],
        ),
        _historyItem('Wallet Top-up', 'Instant UPI • 3h ago', '₹1,000.00', true),
        _historyItem('Gold Purchase', '24K Mint • Yesterday', '-₹5,240.00', false),
        _historyItem('Refund', 'Referral Credit • 2d ago', '₹150.00', true),
      ],
    );
  }

  Widget _historyItem(String title, String sub, String amt, bool isDebit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.03))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (isDebit ? AppColors.success : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(isDebit ? Icons.add_rounded : Icons.remove_rounded, color: isDebit ? AppColors.success : Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                Text(sub, style: const TextStyle(color: Colors.white24, fontSize: 10)),
              ],
            ),
          ),
          Text(amt, style: TextStyle(color: isDebit ? AppColors.success : Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
