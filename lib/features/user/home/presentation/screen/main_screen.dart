import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final items = [
      {'label': t.nav.home,    'icon': Icons.home_outlined,          'activeIcon': Icons.home},
      {'label': t.nav.booking, 'icon': Icons.calendar_today_outlined, 'activeIcon': Icons.calendar_today},
      {'label': t.nav.orders,  'icon': Icons.receipt_long_outlined,   'activeIcon': Icons.receipt_long},
      {'label': t.nav.profile, 'icon': Icons.person_outline,          'activeIcon': Icons.person},
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final selected = navigationShell.currentIndex == i;
                return GestureDetector(
                  onTap: () => navigationShell.goBranch(i,
                      initialLocation: i == navigationShell.currentIndex),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected
                            ? items[i]['activeIcon'] as IconData
                            : items[i]['icon'] as IconData,
                        color: selected
                            ? const Color(0xFF2B5FAD)
                            : const Color(0xFF9EA3AE),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? const Color(0xFF2B5FAD)
                              : const Color(0xFF9EA3AE),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 4, height: 4,
                          decoration: const BoxDecoration(
                              color: Color(0xFF2B5FAD), shape: BoxShape.circle),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}