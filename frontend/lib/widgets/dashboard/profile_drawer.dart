import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../services/api_service.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  String userName = 'User';
  String userEmail = 'user@silvra.app';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.fetchProfile();
      if (mounted) {
        setState(() {
          userName = profile['full_name'] ?? 'User';
          userEmail = profile['email'] ?? 'user@silvra.app';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF0D0D12);
    final Color cardBgColor = const Color(0xFF16161E);
    final Color goldPrimary = const Color(0xFFECB613);

    return Drawer(
      backgroundColor: bgColor,
      width: MediaQuery.of(context).size.width * 0.85,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(goldPrimary, cardBgColor),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _drawerItem(Icons.person_outline_rounded, 'My Profile', '/profile', context),
                  _drawerItem(Icons.security_rounded, 'Security & PIN', null, context),
                  _drawerItem(Icons.notifications_none_rounded, 'Notifications', null, context),
                  _drawerItem(Icons.account_balance_rounded, 'Bank Accounts', null, context),
                  const Divider(color: Colors.white10, height: 40),
                  _drawerItem(Icons.help_outline_rounded, 'Help & Support', null, context),
                  _drawerItem(Icons.info_outline_rounded, 'Terms & Privacy', null, context),
                  _drawerItem(Icons.share_rounded, 'Refer a Friend', null, context),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color gold, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        border: const Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [gold, const Color(0xFFFFD700)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.3), blurRadius: 10)],
            ),
            child: const Center(child: Icon(Icons.person_rounded, color: Colors.black, size: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(userEmail, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white60, size: 20),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String? route, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFECB613), size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 18),
      onTap: () {
        if (route != null) {
          context.pop(); // Close drawer
          context.push(route);
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
            label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 8),
          const Text('Version 2.4.0 (Build 52)', style: TextStyle(color: Colors.white10, fontSize: 10)),
        ],
      ),
    );
  }
}
