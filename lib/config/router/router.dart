import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/common/auth/presentation/screen/splash_screen.dart';
import 'package:wash_club/common/auth/presentation/screen/language_screen.dart';
import 'package:wash_club/features/user/home/presentation/screen/user_home_screen.dart';
import 'package:wash_club/features/user/home/presentation/screen/add_car/add_car_screen.dart';

import '../../common/auth/presentation/screen/login.dart';
import '../../features/user/booking/booking_screen.dart';
import '../../features/user/home/presentation/screen/main_screen.dart';
import '../../features/user/home/presentation/screen/notification/notification_screen.dart';
import '../../features/user/orders/orders_screen.dart';
import '../../features/user/profile/settings_screen.dart';
import '../../features/user/profile/user_profile_screen.dart';
import '../../features/user/map/map_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final GoRouter generateRouter = GoRouter(
  initialLocation: UserRoutePath.splash,
  navigatorKey: navigatorKey,
  debugLogDiagnostics: true,

  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found'))),

  routes: [
    GoRoute(
      path: UserRoutePath.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: UserRoutePath.language,
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: UserRoutePath.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: UserRoutePath.addCar,
      builder: (context, state) {
        final onCarAdded = state.extra as VoidCallback?;
        return AddCarScreen(onCarAdded: onCarAdded);
      },
    ),
    GoRoute(
      path: UserRoutePath.notifications,
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: UserRoutePath.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: UserRoutePath.map,
      builder: (context, state) => const MapScreen(),
    ),
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
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return BookingScreen(presetBranchId: extra?['branchId'] as String?);
              },
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

class UserRoutePath {
  static const splash = '/splash';
  static const language = '/language';
  static const login = '/login';
  static const home = '/home';
  static const booking = '/booking';
  static const orders = '/orders';
  static const profile = '/profile';
  static const addCar = '/add-car';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const map = '/map';
}
