import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF0D0D12);
    final Color cardBgColor = const Color(0xFF16161E);
    final Color goldPrimary = const Color(0xFFECB613);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [goldPrimary, const Color(0xFFFFD700)]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: goldPrimary.withValues(alpha: 0.3), blurRadius: 15)],
                    ),
                    child: const Center(child: Icon(Icons.person, color: Colors.black, size: 35)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Aryan Kumar', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        const Text('aryan.k@silvra.app', style: TextStyle(color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_rounded, color: AppColors.success, size: 12),
                              SizedBox(width: 4),
                              Text('KYC Verified', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_note_rounded, color: goldPrimary, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings Sections
            _buildSectionHeader('ACCOUNT & SECURITY'),
            _buildMenuCard([
              _ProfileMenuItem(icon: Icons.security_rounded, title: 'Auth Settings', sub: 'Biometrics, PIN, Password', onTap: () {}),
              _ProfileMenuItem(icon: Icons.notifications_rounded, title: 'Push Notifications', sub: 'Price alerts, trade updates', onTap: () {}),
              _ProfileMenuItem(icon: Icons.badge_rounded, title: 'KYC Documents', sub: 'View verification status', onTap: () {}),
            ], cardBgColor, goldPrimary),

            const SizedBox(height: 24),
            _buildSectionHeader('PREFERENCES'),
            _buildMenuCard([
              _ProfileMenuItem(icon: Icons.language_rounded, title: 'Language', sub: 'English (US)', onTap: () {}),
              _ProfileMenuItem(icon: Icons.contact_support_rounded, title: 'Help & Support', sub: '24/7 dedicated assistance', onTap: () {}),
              _ProfileMenuItem(icon: Icons.info_outline_rounded, title: 'About Silvra', sub: 'Version 2.4.0', onTap: () {}),
            ], cardBgColor, goldPrimary),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                label: const Text('Log Out of Silvra', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items, Color cardBg, Color gold) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(children: items),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.icon, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFFECB613), size: 18),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
    );
  }
}
