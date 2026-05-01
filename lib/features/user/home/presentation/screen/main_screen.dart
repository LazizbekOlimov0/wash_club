import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      // ── Body with FadeThroughTransition ───────────────────────
      body: Stack(
        children: [
          PageTransitionSwitcher(
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                fillColor: Colors.transparent,
                child: child,
              );
            },
            child: Container(
              key: ValueKey(navigationShell.currentIndex),
              child: navigationShell,
            ),
          ),
        ],
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────
      bottomNavigationBar: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
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
                onTap: (index) => navigationShell.goBranch(index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: const Color(0xFF2B5FAD),
                unselectedItemColor: const Color(0xFF9EA3AE),
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
                items: [
                  // 0 — Home
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, color: Colors.grey),
                    activeIcon: Icon(Icons.home, color: Colors.blueAccent),
                    label: t.nav.home,
                  ),

                  // 1 — Booking
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_outlined, color: Colors.grey),
                    activeIcon: Icon(Icons.calendar_today_outlined, color: Colors.blueAccent),
                    label: t.nav.booking,
                  ),

                  // 2 — Orders
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined, color: Colors.grey),
                    activeIcon: Icon(Icons.receipt_long_outlined, color: Colors.blueAccent),
                    label: t.nav.orders,
                  ),

                  // 3 — Profile
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person, color: Colors.grey),
                    activeIcon: Icon(Icons.person, color: Colors.blueAccent),
                    label: t.nav.profile,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}