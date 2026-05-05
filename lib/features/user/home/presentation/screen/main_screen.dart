import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    // Status bar dark icons → light (dark background uchun)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final items = [
      {'label': t.nav.home,    'icon': Icons.home_outlined,            'activeIcon': Icons.home},
      {'label': t.nav.booking, 'icon': Icons.calendar_today_outlined,   'activeIcon': Icons.calendar_today},
      {'label': t.nav.orders,  'icon': Icons.receipt_long_outlined,     'activeIcon': Icons.receipt_long},
      {'label': t.nav.profile, 'icon': Icons.person_outline,            'activeIcon': Icons.person},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: navigationShell,
      bottomNavigationBar: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(color: const Color(0xFF2A3560), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: const Color(0xFF4D9EFF),
                unselectedItemColor: const Color(0xFF6B7280),
                selectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Rounded',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'SF Pro Rounded',
                ),
                type: BottomNavigationBarType.fixed,
                items: List.generate(items.length, (i) {
                  return BottomNavigationBarItem(
                    icon: Icon(items[i]['icon'] as IconData),
                    activeIcon: Icon(items[i]['activeIcon'] as IconData),
                    label: items[i]['label'] as String,
                  );
                }),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}