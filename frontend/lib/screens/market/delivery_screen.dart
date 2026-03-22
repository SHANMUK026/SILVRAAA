.0+3import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../services/api_service.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  int _selectedGrams = 1;
  bool _isGold = true;
  double _goldBalance = 0.0;
  double _silverBalance = 0.0;
  double _inrBalance = 0.0;
  List<dynamic> _addresses = [];
  String? _selectedAddressId;
  bool _isLoading = true;
  bool _isPlacingOrder = false;

  final Color _bgColor = const Color(0xFF0D0D12);
  final Color _cardBgColor = const Color(0xFF16161E);
  final Color _goldPrimary = const Color(0xFFECB613);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final balances = await ApiService.fetchBalance();
      final addressList = await ApiService.fetchAddresses();
      
      if (mounted) {
        setState(() {
          _goldBalance = (balances['gold_grams'] ?? 0.0).toDouble();
          _silverBalance = (balances['silver_grams'] ?? 0.0).toDouble();
          _inrBalance = (balances['inr_wallet'] ?? 0.0).toDouble();
          _addresses = addressList;
          if (_addresses.isNotEmpty) {
            _selectedAddressId = _addresses[0]['id'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handlePlaceOrder() async {
    if (_selectedAddressId == null) {
      _showError('Please select a delivery address');
      return;
    }

    final double available = _isGold ? _goldBalance : _silverBalance;
    if (_selectedGrams > available) {
      _showError('Insufficient ${_isGold ? "Gold" : "Silver"} balance');
      return;
    }

    final double makingCharges = _selectedGrams * 200.0;
    const double deliveryFee = 150.0;
    final double totalPayable = makingCharges + deliveryFee;

    if (totalPayable > _inrBalance) {
      _showError('Insufficient INR wallet balance for charges');
      return;
    }

    setState(() => _isPlacingOrder = true);
    try {
      final result = await ApiService.placeDeliveryOrder(
        addressId: _selectedAddressId!,
        assetType: _isGold ? 'gold' : 'silver',
        grams: _selectedGrams.toDouble(),
        makingCharges: makingCharges,
        deliveryFee: deliveryFee,
      );
      setState(() => _isPlacingOrder = false);

      if (result['error'] != null) {
        _showError(result['error']);
      } else {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      _showError('Failed to place order. Try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
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
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 80),
              const SizedBox(height: 24),
              const Text('DISPATCHED!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              const Text('Your 24K pure metal is on its way to your doorstep.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/history'),
                  style: ElevatedButton.styleFrom(backgroundColor: _goldPrimary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('TRACK TRANSIT', style: TextStyle(fontWeight: FontWeight.w900)),
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
    if (_isLoading) {
      return Scaffold(backgroundColor: _bgColor, body: Center(child: CircularProgressIndicator(color: _goldPrimary)));
    }

    final double available = _isGold ? _goldBalance : _silverBalance;
    final double makingCharges = _selectedGrams * 200.0;
    const double deliveryFee = 150.0;
    final double totalPayable = makingCharges + deliveryFee;

    return Scaffold(
      backgroundColor: _bgColor,
      bottomNavigationBar: _buildStickyFooter(totalPayable),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetalSelector(),
                  const SizedBox(height: 32),
                  _buildAssetVisualizer(),
                  const SizedBox(height: 40),
                  _buildQuantityGrid(available),
                  const SizedBox(height: 40),
                  _buildAddressCard(),
                  const SizedBox(height: 40),
                  _buildPricingSummary(makingCharges, deliveryFee, totalPayable),
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
      title: const Text('PHYSICAL DELIVERY', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.help_outline_rounded, color: Colors.white60), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMetalSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          _selectorItem(true, '24K Gold'),
          _selectorItem(false, '99.9% Silver'),
        ],
      ),
    );
  }

  Widget _selectorItem(bool gold, String label) {
    bool active = _isGold == gold;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isGold = gold),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: active ? _goldPrimary : Colors.transparent, borderRadius: BorderRadius.circular(16)),
          child: Center(child: Text(label, style: TextStyle(color: active ? Colors.black : Colors.white60, fontWeight: FontWeight.w900, fontSize: 13))),
        ),
      ),
    );
  }

  Widget _buildAssetVisualizer() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
        image: DecorationImage(
          image: NetworkImage(_isGold 
            ? 'https://img.freepik.com/premium-photo/gold-coin-isolated-black-background_825501-155.jpg'
            : 'https://img.freepik.com/premium-photo/silver-bar-isolated-black-background_825501-160.jpg'
          ),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
          child: Text('${_selectedGrams}g ${_isGold ? "GOLD COIN" : "SILVER BAR"}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ),
    );
  }

  Widget _buildQuantityGrid(double available) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('SELECT QUANTITY', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            Text('AVAILABLE: ${available.toStringAsFixed(3)}g', style: TextStyle(color: _goldPrimary, fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [1, 5, 10, 20].map((g) => _quantityChip(g)).toList(),
        ),
      ],
    );
  }

  Widget _quantityChip(int g) {
    bool selected = _selectedGrams == g;
    return GestureDetector(
      onTap: () => setState(() => _selectedGrams = g),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? _goldPrimary.withOpacity(0.1) : _cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _goldPrimary : Colors.white10),
        ),
        child: Center(child: Text('${g}g', style: TextStyle(color: selected ? _goldPrimary : Colors.white, fontWeight: FontWeight.w900))),
      ),
    );
  }

  Widget _buildAddressCard() {
    final addr = _addresses.isNotEmpty ? _addresses.firstWhere((a) => a['id'] == _selectedAddressId, orElse: () => _addresses[0]) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DELIVERY DESTINATION', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: addr == null ? _emptyAddress() : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_rounded, color: _goldPrimary, size: 28),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(addr['full_name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text('${addr['address_line_1']}, ${addr['city']}\n${addr['state']} - ${addr['pincode']}', style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyAddress() {
    return Center(
      child: Column(
        children: [
          const Text('No address found', style: TextStyle(color: Colors.white24)),
          TextButton(onPressed: () {}, child: Text('ADD NEW ADDRESS', style: TextStyle(color: _goldPrimary, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  Widget _buildPricingSummary(double making, double fee, double total) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          _priceRow('MAKING CHARGES', '₹${making.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          _priceRow('INSURANCE & SHIPPING', '₹${fee.toStringAsFixed(0)}'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white10, height: 1)),
          _priceRow('TOTAL AMOUNT', '₹${total.toStringAsFixed(0)}', highlight: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String val, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: highlight ? Colors.white : Colors.white38, fontSize: highlight ? 14 : 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
        Text(val, style: TextStyle(color: highlight ? _goldPrimary : Colors.white, fontSize: highlight ? 20 : 14, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildStickyFooter(double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: _bgColor,
        border: const Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, color: Colors.white24, size: 14),
              SizedBox(width: 8),
              Text('SECURE VAULT DISPATCH', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 20),
          _isPlacingOrder 
            ? Center(child: CircularProgressIndicator(color: _goldPrimary))
            : SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handlePlaceOrder,
                  style: ElevatedButton.styleFrom(backgroundColor: _goldPrimary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 12, shadowColor: _goldPrimary.withOpacity(0.3)),
                  child: const Text('CONFIRM DELIVERY', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
        ],
      ),
    );
  }
}
