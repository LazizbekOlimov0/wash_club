import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/common/auth/presentation/screen/splash_screen.dart';
import 'package:wash_club/features/user/home/presentation/screen/user_home_screen.dart';
import 'package:wash_club/features/user/home/presentation/screen/add_car/add_car_screen.dart';

import '../../common/auth/presentation/screen/login.dart';
import '../../features/user/booking/booking_screen.dart';
import '../../features/user/home/presentation/screen/main_screen.dart';
import '../../features/user/orders/orders_screen.dart';
import '../../features/user/profile/user_profile_screen.dart';

// ── Navigator keys ─────────────────────────────────────────────────
final navigatorKey = GlobalKey<NavigatorState>();

// ── Router ─────────────────────────────────────────────────────────
final GoRouter generateRouter = GoRouter(
  initialLocation: UserRoutePath.splash,
  navigatorKey: navigatorKey,
  debugLogDiagnostics: true,

  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('Page Not Found')),
  ),

  routes: [
    // ── Splash ───────────────────────────────────────────────────
    GoRoute(
      path: UserRoutePath.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // ── Login ────────────────────────────────────────────────────
    GoRoute(
      path: UserRoutePath.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // ── Add Car ───────────────────────────────────────────────────
    GoRoute(
      path: UserRoutePath.addCar,
      builder: (context, state) {
        final onCarAdded = state.extra as VoidCallback?;
        return AddCarScreen(onCarAdded: onCarAdded);
      },
    ),

    // ── Main Shell (Bottom Nav) ───────────────────────────────────
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: navigatorKey,
      restorationScopeId: 'main-shell',
      builder: (context, state, navigationShell) =>
          MainScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: UserRoutePath.home,
              builder: (context, state) => const UserHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: UserRoutePath.booking,
              builder: (context, state) => const BookingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: UserRoutePath.orders,
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: UserRoutePath.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// ── Route paths ────────────────────────────────────────────────────
class UserRoutePath {
  static const splash  = '/splash';
  static const login   = '/login';
  static const home    = '/home';
  static const booking = '/booking';
  static const orders  = '/orders';
  static const profile = '/profile';
  static const addCar  = '/add-car';
}