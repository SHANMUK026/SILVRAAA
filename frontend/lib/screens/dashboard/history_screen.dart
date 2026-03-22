import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'type': 'Gold Purchase',
      'category': 'gold',
      'time': '14:20 PM',
      'amount': '₹9,990.00',
      'status': 'Completed',
      'isPositive': false,
      'date': 'TODAY',
      'icon': Icons.shopping_bag_rounded,
    },
    {
      'type': 'Wallet Loaded',
      'category': 'withdraw',
      'time': '09:00 AM',
      'amount': '₹4,500.00',
      'status': 'Success',
      'isPositive': true,
      'date': 'TODAY',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'type': 'Gold SIP',
      'category': 'gold',
      'time': '08:15 AM',
      'amount': '₹500.00',
      'status': 'Completed',
      'isPositive': false,
      'date': 'TODAY',
      'icon': Icons.history_edu_rounded,
    },
    {
      'type': 'Silver Purchase',
      'category': 'silver',
      'time': '22:45 PM',
      'amount': '₹2,480.00',
      'status': 'Completed',
      'isPositive': false,
      'date': 'YESTERDAY',
      'icon': Icons.stars_rounded,
    },
    {
      'type': 'Referral Reward',
      'category': 'withdraw',
      'time': '15:30 PM',
      'amount': '₹150.00',
      'status': 'Credit',
      'isPositive': true,
      'date': 'YESTERDAY',
      'icon': Icons.card_giftcard_rounded,
    },
  ];

  List<Map<String, dynamic>> _filteredTransactions = [];
  String _searchQuery = '';

  final Color _bgColor = const Color(0xFF0D0D12);
  final Color _cardBgColor = const Color(0xFF16161E);
  final Color _goldPrimary = const Color(0xFFECB613);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _filteredTransactions = _allTransactions;
    _tabController.addListener(_applyFilters);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
      _applyFilters();
    });
  }

  void _applyFilters() {
    String category = '';
    switch (_tabController.index) {
      case 1: category = 'gold'; break;
      case 2: category = 'silver'; break;
      case 3: category = 'withdraw'; break;
    }

    setState(() {
      _filteredTransactions = _allTransactions.where((t) {
        final matchesCategory = category.isEmpty || t['category'] == category;
        final matchesSearch = t['type'].toString().toLowerCase().contains(_searchQuery) || 
                             t['amount'].toString().toLowerCase().contains(_searchQuery);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_applyFilters);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = _filteredTransactions.where((t) => t['date'] == 'TODAY').toList();
    final yesterday = _filteredTransactions.where((t) => t['date'] == 'YESTERDAY').toList();

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildTabs(),
                ],
              ),
            ),
          ),
          if (_filteredTransactions.isEmpty)
            _buildEmptyState()
          else
            SliverList(
              delegate: SliverChildListDelegate([
                if (today.isNotEmpty) ...[
                  _buildDateHeader('TODAY'),
                  ...today.map((t) => _buildTransactionCard(t)),
                ],
                if (yesterday.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildDateHeader('YESTERDAY'),
                  ...yesterday.map((t) => _buildTransactionCard(t)),
                ],
                const SizedBox(height: 100),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: _bgColor,
      expandedHeight: 60,
      elevation: 0,
      centerTitle: true,
      title: const Text('Transactions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by asset or amount...',
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: _goldPrimary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      dividerColor: Colors.transparent,
      indicatorColor: _goldPrimary,
      labelColor: _goldPrimary,
      unselectedLabelColor: Colors.white38,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      indicatorSize: TabBarIndicatorSize.label,
      tabs: const [
        Tab(text: 'ALL'),
        Tab(text: 'GOLD'),
        Tab(text: 'SILVER'),
        Tab(text: 'WALLET'),
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(date, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle),
            child: Icon(t['icon'], color: _goldPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['type'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(t['time'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(t['amount'], style: TextStyle(color: t['isPositive'] ? Colors.green : Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 4),
              Text(t['status'], style: TextStyle(color: t['isPositive'] ? Colors.green.withOpacity(0.7) : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 16),
            const Text('No transactions found', style: TextStyle(color: Colors.white24, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
