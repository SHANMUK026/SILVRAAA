import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../services/api_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController(text: '2,000');
  bool isGold = true;
  double goldBalance = 0.0;
  double silverBalance = 0.0;
  double goldPrice = 0.0;
  double silverPrice = 0.0;
  bool isLoading = true;
  bool isSubmitting = false;
  Map<String, dynamic>? bankDetails;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final balances = await ApiService.fetchBalance();
      final prices = await ApiService.fetchMarketPrices();
      final bankData = await ApiService.fetchBankDetails();

      if (mounted) {
        setState(() {
          goldBalance = (balances['gold_grams'] ?? 0.0).toDouble();
          silverBalance = (balances['silver_grams'] ?? 0.0).toDouble();
          goldPrice = (prices['gold']?['sell'] ?? 6300.0).toDouble();
          silverPrice = (prices['silver']?['sell'] ?? 75.0).toDouble();
          bankDetails = bankData.isEmpty ? null : bankData;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _handleWithdrawal() async {
    final amountStr = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'), duration: Duration(seconds: 2)),
      );
      return;
    }

    final currentPrice = isGold ? goldPrice : silverPrice;
    final gramsToWithdraw = amount / (currentPrice > 0 ? currentPrice : 1.0);
    final availableGrams = isGold ? goldBalance : silverBalance;

    if (gramsToWithdraw > availableGrams) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient ${isGold ? "Gold" : "Silver"} balance'), duration: const Duration(seconds: 2)),
      );
      return;
    }

    setState(() => isSubmitting = true);
    final result = await ApiService.initiateWithdrawal(amount);
    setState(() => isSubmitting = false);

    if (result['error'] != null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error']), backgroundColor: Colors.redAccent, duration: const Duration(seconds: 2)),
      );
    } else {
      _showSuccessDialog(amount);
    }
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Withdrawal Initiated! 💸'),
        content: Text('Your request for ₹${amount.toStringAsFixed(0)} has been received. Funds will be credited to your HDFC bank account ending in 4821.'),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Great!', style: TextStyle(color: Color(0xFFECC813), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFECC813))),
      );
    }

    final currentBalance = isGold ? goldBalance : silverBalance;
    final currentValue = currentBalance * (isGold ? goldPrice : silverPrice);
    final assetLabel = isGold ? 'GOLD' : 'SILVER';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 40),
                decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
                child: Column(
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        spacing: 24,
                        children: [
                          _buildMetalToggle(),
                          _buildWithdrawableCard(currentValue, currentBalance, assetLabel),
                          _buildAmountInputCard(currentValue),
                          _buildBankCard(),
                          _buildInfoSection(),
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF735C00)),
          ),
          const SizedBox(width: 8),
          const Text(
            'Withdraw',
            style: TextStyle(
              color: Color(0xFF735C00),
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetalToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isGold = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: isGold
                    ? BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFECC813), Color(0xFFF7E37B)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                        ],
                      )
                    : null,
                child: Center(
                  child: Text(
                    'Gold',
                    style: TextStyle(
                      color: isGold ? const Color(0xFF241A00) : const Color(0xFF4D4635),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: isGold ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isGold = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: !isGold
                    ? BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF94A3B8), Color(0xFFCBD5E1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                        ],
                      )
                    : null,
                child: Center(
                  child: Text(
                    'Silver',
                    style: TextStyle(
                      color: !isGold ? Colors.white : const Color(0xFF4D4635),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: !isGold ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawableCard(double value, double grams, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD0C5AF)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24)],
      ),
      child: Column(
        children: [
          const Text(
            'WITHDRAWABLE AMOUNT',
            style: TextStyle(color: Color(0xFF4D4635), fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: const TextStyle(color: Color(0xFF1A1C1C), fontSize: 36, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: -0.9),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can withdraw up to this amount',
            style: TextStyle(color: Color(0xFF5D5E5F), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFFE088), borderRadius: BorderRadius.circular(999)),
                child: Text(
                  '${grams.toStringAsFixed(2)} GM $label',
                  style: const TextStyle(color: Color(0xFF574500), fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Live price applied',
                style: TextStyle(color: Color(0x994D4635), fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInputCard(double maxValue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD0C5AF)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ENTER AMOUNT',
            style: TextStyle(color: Color(0xFF4D4635), fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Text('₹', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1C1C))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1C1C)),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _amountController.text = maxValue.toStringAsFixed(0)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(color: const Color(0xFFE2E2E2), borderRadius: BorderRadius.circular(12)),
                  child: const Text('MAX', style: TextStyle(color: Color(0xFF735C00), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Min ₹100 • Available ₹${maxValue.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF5D5E5F), fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          _buildReceiveDetail(),
          const SizedBox(height: 16),
          _buildQuickChips(maxValue),
        ],
      ),
    );
  }

  Widget _buildReceiveDetail() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    final currentPrice = isGold ? goldPrice : silverPrice;
    final grams = amount / (currentPrice > 0 ? currentPrice : 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0x7FF3F3F3), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x19D0C5AF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('You will receive\n₹${amount.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF1A1C1C), fontSize: 14, fontWeight: FontWeight.w500)),
              Text('≈ ${grams.toStringAsFixed(3)} gm\n${isGold ? "Gold" : "Silver"}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF735C00), fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Based on live market price', style: TextStyle(color: Color(0x994D4635), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildQuickChips(double maxValue) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [500, 1000, 2000, 5000].map((amt) {
          bool isSelected = _amountController.text == amt.toString();
          return GestureDetector(
            onTap: () => setState(() => _amountController.text = amt.toString()),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: isSelected? BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFECC813), Color(0xFFF7E37B)]), borderRadius: BorderRadius.circular(12)) : BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(12)),
              child: Text('₹$amt', style: TextStyle(color: isSelected ? const Color(0xFF241A00) : const Color(0xFF1A1C1C), fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBankCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFD0C5AF)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE2E2E2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.account_balance, color: Color(0xFF735C00))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(bankDetails?['bank_name'] ?? 'HDFC Bank •••• 4821', style: const TextStyle(color: Color(0xFF1A1C1C), fontSize: 14, fontWeight: FontWeight.w700)), Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)), const SizedBox(width: 4), const Text('Instant transfer enabled', style: TextStyle(color: Color(0xFF4D4635), fontSize: 11))])])),
          const Text('Change', style: TextStyle(color: Color(0xFF735C00), fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(children: [_infoRow(Icons.info_outline, 'Minimum withdrawal: ₹100', const Color(0xFF45474C)), const SizedBox(height: 12), _infoRow(Icons.flash_on, 'Instant bank transfer supported', const Color(0xFF429F8E))]);
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 8), Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500))]);
  }

  Widget _buildActionButtons() {
    return Column(
      spacing: 16,
      children: [
        GestureDetector(
          onTap: isSubmitting ? null : _handleWithdrawal,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFECC813), Color(0xFFF7E37B)]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFFECC813).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))]),
            child: Center(child: isSubmitting? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Color(0xFF241A00), strokeWidth: 2)) : const Text('Withdraw Now', style: TextStyle(color: Color(0xFF241A00), fontSize: 18, fontWeight: FontWeight.bold))),
          ),
        ),
        GestureDetector(onTap: () => context.pop(), child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFD0C5AF))), child: const Center(child: Text('Cancel', style: TextStyle(color: Color(0xFF5D5E5F), fontSize: 14, fontWeight: FontWeight.w600))))),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', false, () => context.go('/home')),
          _navItem(Icons.trending_up, 'Market', false, () => context.go('/market')),
          _navItem(Icons.emoji_events_outlined, 'Rewards', false, () => context.go('/rewards')),
          _navItem(Icons.history, 'History', false, () => context.go('/transactions')),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: isActive ? const Color(0xFFECC813) : const Color(0xFF64748B), size: 24), const SizedBox(height: 4), Text(label, style: TextStyle(color: isActive ? const Color(0xFFECC813) : const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w700))]),
    );
  }
}
