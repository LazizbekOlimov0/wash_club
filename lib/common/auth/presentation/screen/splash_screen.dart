import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/services/client_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _scaleAnim;

  StreamSubscription? _authSub;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
    _initAndRoute();
  }

  Future<void> _initAndRoute() async {
    // Animatsiya tugagunicha kutish
    await Future.delayed(const Duration(milliseconds: 1600));

    // ClientSession'ni init qilish
    await ClientSession.instance.init();

    // Supabase session'ni tiklashni kutish (autoRefreshToken)
    final completer = Completer<void>();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (!completer.isCompleted && event.session != null) {
        completer.complete();
      }
    });

    try {
      await completer.future.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      // Session tiklanmadi — bu normal, foydalanuvchi birinchi marta kiryapti
    }

    _authSub?.cancel();
    if (!mounted) return;

    // Routing logic:
    // 1) Agar Supabase session bor va ClientSession ham bor → home
    // 2) Agar faqat Supabase session bor, lekin name/phone yo'q → login
    // 3) Agar oldin kirgan bo'lsa (local flag) lekin Supabase session yo'q → login
    // 4) Aks holda → language screen
    final hasSupabaseSession =
        Supabase.instance.client.auth.currentSession != null;
    final isOnboarded = ClientSession.instance.isOnboarded;

    if (isOnboarded) {
      // Foydalanuvchi oldin to'liq ro'yxatdan o'tgan → home
      context.go(UserRoutePath.home);
    } else if (hasSupabaseSession) {
      // Google auth qilingan, name/phone kiritilmagan → login
      context.go(UserRoutePath.login);
    } else {
      // Birinchi marta kirish → language
      context.go(UserRoutePath.language);
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = Theme.of(context).extension<ApparenceKitColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: colors.background,
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.info.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.03),
                ),
              ),
            ),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child:
                        Transform.scale(scale: _scaleAnim.value, child: child),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: colors.onPrimaryContainer,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: colors.grey1, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: colors.info.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🚿', style: TextStyle(fontSize: 52)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Wash Club',
                      style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.splash.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.grey3,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom loading
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Opacity(
                  opacity: _fadeAnim.value,
                  child: Column(children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.info),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      t.splash.loading,
                      style: TextStyle(color: colors.grey3, fontSize: 12),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
