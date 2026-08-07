import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

import '../../../../../config/router/router.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../shared/services/client_session.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPending());
  }

  void _checkPending() {
    final pending = PendingDestination.consume();
    if (pending == null || !mounted) return;
    final shellIdx = pending == '/orders' ? 2 : 3;
    widget.navigationShell.goBranch(shellIdx);
  }

  void _onTabTap(int uiIdx) {
    // uiIdx mapping: 0=home, 1=booking, 2=map(sep), 3=orders, 4=profile
    if (uiIdx == 2) {
      context.push(UserRoutePath.map);
      return;
    }
    final shellIdx = uiIdx > 2 ? uiIdx - 1 : uiIdx;
    // Auth check for orders (shell 2) and profile (shell 3)
    if (shellIdx == 2 || shellIdx == 3) {
      if (!ClientSession.instance.isOnboarded) {
        PendingDestination.set(shellIdx == 2 ? '/orders' : '/profile');
        context.push(UserRoutePath.otpLogin);
        return;
      }
    }
    widget.navigationShell.goBranch(
      shellIdx,
      initialLocation: shellIdx == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = Theme.of(context).extension<ApparenceKitColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    final shellIdx = widget.navigationShell.currentIndex;
    final uiIdx = shellIdx >= 2 ? shellIdx + 1 : shellIdx;

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.62)
                    : Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.45)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navTab(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: t.nav.home,
                        isSelected: uiIdx == 0,
                        colors: colors,
                        onTap: () => _onTabTap(0),
                      ),
                      _navTab(
                        icon: Icons.calendar_today_outlined,
                        activeIcon: Icons.calendar_today,
                        label: t.nav.booking,
                        isSelected: uiIdx == 1,
                        colors: colors,
                        onTap: () => _onTabTap(1),
                      ),
                      _mapTab(
                        icon: Icons.map_outlined,
                        activeIcon: Icons.map,
                        label: t.nav.map,
                        isSelected: uiIdx == 2,
                        colors: colors,
                        onTap: () => _onTabTap(2),
                      ),
                      _navTab(
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long,
                        label: t.nav.orders,
                        isSelected: uiIdx == 3,
                        colors: colors,
                        onTap: () => _onTabTap(3),
                      ),
                      _navTab(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: t.nav.profile,
                        isSelected: uiIdx == 4,
                        colors: colors,
                        onTap: () => _onTabTap(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navTab({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required ApparenceKitColors colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey('${isSelected}_$label'),
                size: 24,
                color: isSelected ? colors.primary : colors.grey3,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'SF Pro Rounded',
                color: isSelected ? colors.primary : colors.grey3,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapTab({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required ApparenceKitColors colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey('map_$isSelected'),
                size: 28,
                color: isSelected ? colors.primary : colors.grey3,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'SF Pro Rounded',
                color: isSelected ? colors.primary : colors.grey3,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
