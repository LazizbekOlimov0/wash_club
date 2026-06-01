import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

import '../../../../../config/router/router.dart';
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
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    // UI index mapping: [0=home, 1=booking, 2=map, 3=orders, 4=profile]
    // Shell index mapping: [0=home, 1=booking, 2=orders, 3=profile]
    final shellIdx = navigationShell.currentIndex;
    final uiIdx = shellIdx >= 2 ? shellIdx + 1 : shellIdx;

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
            top: BorderSide(color: colors.divider, width: 1),
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
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: uiIdx,
              onTap: (idx) {
                if (idx == 2) {
                  context.push(UserRoutePath.map);
                  return;
                }
                final shellI = idx > 2 ? idx - 1 : idx;
                navigationShell.goBranch(
                  shellI,
                  initialLocation: shellI == navigationShell.currentIndex,
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              enableFeedback: false,
              selectedItemColor: colors.primary,
              unselectedItemColor: colors.grey3,
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
              items: [
                _barItem(Icons.home_outlined, Icons.home, t.nav.home, uiIdx == 0, colors),
                _barItem(Icons.calendar_today_outlined, Icons.calendar_today, t.nav.booking, uiIdx == 1, colors),
                // Map — markaziy, kattaroq, gradientli
                BottomNavigationBarItem(
                  label: '',
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 2),
                      Container(
                        width: 46,
                        height: 46,
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B72D9), Color(0xFF4E85F0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B72D9).withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.map_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Xarita',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                          fontFamily: 'SF Pro Rounded',
                        ),
                      ),
                    ],
                  ),
                  activeIcon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 2),
                      Container(
                        width: 46,
                        height: 46,
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B72D9), Color(0xFF4E85F0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B72D9).withValues(alpha: 0.5),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.map,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Xarita',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                          fontFamily: 'SF Pro Rounded',
                        ),
                      ),
                    ],
                  ),
                ),
                _barItem(Icons.receipt_long_outlined, Icons.receipt_long, t.nav.orders, uiIdx == 3, colors),
                _barItem(Icons.person_outline, Icons.person, t.nav.profile, uiIdx == 4, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _barItem(
    IconData icon,
    IconData activeIcon,
    String label,
    bool isSelected,
    ApparenceKitColors colors,
  ) {
    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 23),
      ),
      activeIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(activeIcon, size: 23),
      ),
    );
  }
}
