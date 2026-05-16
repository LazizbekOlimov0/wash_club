import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

import '../../../../../core/theme/colors.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = Theme.of(context).extension<ApparenceKitColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );

    final items = [
      {
        'label': t.nav.home,
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
      },
      {
        'label': t.nav.booking,
        'icon': Icons.calendar_today_outlined,
        'activeIcon': Icons.calendar_today,
      },
      {
        'label': t.nav.orders,
        'icon': Icons.receipt_long_outlined,
        'activeIcon': Icons.receipt_long,
      },
      {
        'label': t.nav.profile,
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
      },
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(
              color: colors.divider,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(
                alpha: isDark ? 0.25 : 0.06,
              ),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 4,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation:
                    index == navigationShell.currentIndex,
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                enableFeedback: false,

                // colors
                selectedItemColor: colors.primary,
                unselectedItemColor: colors.grey3,

                // labels
                selectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro Rounded',
                  letterSpacing: -0.1,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SF Pro Rounded',
                  letterSpacing: -0.1,
                ),

                items: List.generate(items.length, (i) {
                  final isSelected =
                      navigationShell.currentIndex == i;

                  return BottomNavigationBarItem(
                    label: items[i]['label'] as String,

                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        items[i]['icon'] as IconData,
                        size: 23,
                      ),
                    ),

                    activeIcon: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        items[i]['activeIcon'] as IconData,
                        size: 23,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}