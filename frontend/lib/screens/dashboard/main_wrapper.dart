import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;
  const MainWrapper({super.key, required this.child});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/wealth')) return 1;
    if (location.startsWith('/wallet')) return 2;
    if (location.startsWith('/rewards')) return 3;
    if (location.startsWith('/history')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == 2) {
      context.go('/wallet');
      return;
    }
    
    final routes = {
      0: '/home',
      1: '/wealth',
      3: '/rewards',
      4: '/history',
    };

    if (routes.containsKey(index)) {
      context.go(routes[index]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: widget.child,
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B0F),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.5)),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            BottomNavigationBar(
              currentIndex: _getSelectedIndex(context),
              onTap: (index) => _onItemTapped(index, context),
              backgroundColor: const Color(0xFF0B0B0F),
              selectedItemColor: const Color(0xFFECB613),
              unselectedItemColor: const Color(0xFF64748B),
              selectedFontSize: 10,
              unselectedFontSize: 10,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_outlined),
                  activeIcon: Icon(Icons.account_balance),
                  label: 'Wealth',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(width: 40),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events),
                  label: 'Rewards',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'History',
                ),
              ],
            ),
            Positioned(
              top: -15,
              child: GestureDetector(
                onTap: () => context.go('/wallet'),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECB613),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFECB613).withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.account_balance_wallet, color: Colors.black, size: 28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
