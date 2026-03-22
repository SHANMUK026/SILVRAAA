import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../services/api_service.dart';
import 'package:go_router/go_router.dart';

class SavingPlansScreen extends StatefulWidget {
  const SavingPlansScreen({super.key});

  @override
  State<SavingPlansScreen> createState() => _SavingPlansScreenState();
}

class _SavingPlansScreenState extends State<SavingPlansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFrequency = 'Daily';
  String _selectedAsset = 'gold';
  final _amountController = TextEditingController(text: '1000');
  double _dipThreshold = 5.0;
  bool _isSubmitting = false;

  final Color _bgColor = const Color(0xFF0D0D12);
  final Color _cardBgColor = const Color(0xFF16161E);
  final Color _goldPrimary = const Color(0xFFECB613);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleActivate() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 100) {
      _showError('Minimum is ₹100');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      dynamic result;
      if (_tabController.index == 0) {
        result = await ApiService.setupSip(assetType: _selectedAsset, amount: amount, frequency: _selectedFrequency.toLowerCase());
      } else {
        result = await ApiService.setupAutoInvest(assetType: _selectedAsset, amount: amount, threshold: _dipThreshold);
      }
      
      setState(() => _isSubmitting = false);
      if (result['error'] != null) {
        _showError(result['error']);
      } else {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showError('Connection error. Try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rocket_launch_rounded, color: AppColors.success, size: 80),
              const SizedBox(height: 24),
              const Text('SIP ACTIVATED!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              const Text('Your automated wealth building journey has begun.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(backgroundColor: _goldPrimary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('EXPLORE DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900)),
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
                  _buildHeaderCard(),
                  const SizedBox(height: 32),
                  _buildTabToggle(),
                  const SizedBox(height: 40),
                  _buildAssetSelection(),
                  const SizedBox(height: 40),
                  _buildConfigurator(),
                  const SizedBox(height: 40),
                  _buildInvestmentInput(),
                  const SizedBox(height: 40),
                  _buildForecastCard(),
                  const SizedBox(height: 60),
                  _buildActionButton(),
                  const SizedBox(height: 40),
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
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => context.pop()),
      title: const Text('GOLD SAVING PLANS', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
      centerTitle: true,
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF231F14), Color(0xFF0D0D12)]),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _goldPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: _goldPrimary, size: 24),
              const SizedBox(width: 12),
              Text('WEALTH MULTIPLIER', style: TextStyle(color: _goldPrimary, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Compound Your Savings\nAutomatically.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.2)),
          const SizedBox(height: 12),
          const Text('14.2% projected annual growth based on historical data.', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(color: _goldPrimary, borderRadius: BorderRadius.circular(12)),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white60,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(child: Text('Fixed SIP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
          Tab(child: Text('Buy the Dip', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildAssetSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CHOOSE ASSET', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Row(
          children: [
            _assetTile('gold', '24K Gold', Icons.stars_rounded),
            const SizedBox(width: 16),
            _assetTile('silver', '99% Silver', Icons.blur_on_rounded),
          ],
        ),
      ],
    );
  }

  Widget _assetTile(String val, String label, IconData icon) {
    bool active = _selectedAsset == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedAsset = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(color: active ? _goldPrimary.withOpacity(0.1) : _cardBgColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: active ? _goldPrimary : Colors.white.withOpacity(0.05))),
          child: Column(
            children: [
              Icon(icon, color: active ? _goldPrimary : Colors.white38, size: 28),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: active ? _goldPrimary : Colors.white54, fontWeight: FontWeight.w900, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurator() {
    if (_tabController.index == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FREQUENCY', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Daily', 'Weekly', 'Monthly'].map((f) => _frequencyChip(f)).toList(),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('DIP THRESHOLD', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Text('${_dipThreshold.toInt()}%', style: TextStyle(color: _goldPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(activeTrackColor: _goldPrimary, inactiveTrackColor: Colors.white12, thumbColor: _goldPrimary),
            child: Slider(value: _dipThreshold, min: 1, max: 15, divisions: 14, onChanged: (v) => setState(() => _dipThreshold = v)),
          ),
          const Text('We detect price drops and buy for you automatically.', style: TextStyle(color: Colors.white24, fontSize: 11)),
        ],
      );
    }
  }

  Widget _frequencyChip(String f) {
    bool active = _selectedFrequency == f;
    return GestureDetector(
      onTap: () => setState(() => _selectedFrequency = f),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: active ? _goldPrimary : _cardBgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? _goldPrimary : Colors.white.withOpacity(0.05))),
        child: Center(child: Text(f, style: TextStyle(color: active ? Colors.black : Colors.white, fontWeight: FontWeight.w900, fontSize: 12))),
      ),
    );
  }

  Widget _buildInvestmentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('INVESTMENT AMOUNT', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
          child: Row(
            children: [
              Text('₹', style: TextStyle(color: _goldPrimary, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.white24)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EST. MATURITY (3Y)', style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              SizedBox(height: 4),
              Text('₹48,240', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          Icon(Icons.auto_graph_rounded, color: AppColors.success, size: 24),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return _isSubmitting 
      ? const Center(child: CircularProgressIndicator(color: Color(0xFFECB613)))
      : SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: _handleActivate,
            style: ElevatedButton.styleFrom(backgroundColor: _goldPrimary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 12, shadowColor: _goldPrimary.withOpacity(0.3)),
            child: Text(_tabController.index == 0 ? 'ACTIVATE SIP' : 'ACTIVATE AUTOBOT', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        );
  }
}

class _FrequencyCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _FrequencyCard({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldPrimary.withValues(alpha: 0.1) : AppColors.surface,
          border: Border.all(color: isSelected ? AppColors.goldPrimary : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.goldPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
