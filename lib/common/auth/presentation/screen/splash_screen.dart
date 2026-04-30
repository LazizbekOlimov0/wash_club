import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

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
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go(UserRoutePath.login);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A3A7A), Color(0xFF2B5FAD), Color(0xFF1E2D5A)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -60, right: -60,
                child: Container(width: 220, height: 220,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x0DFFFFFF)))),
            Positioned(bottom: 80, left: -80,
                child: Container(width: 280, height: 280,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x0AFFFFFF)))),
            Positioned(bottom: -40, right: 40,
                child: Container(width: 160, height: 160,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x0FFFFFFF)))),

            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: Transform.scale(scale: _scaleAnim.value, child: child),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0x1FFFFFFF),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0x33FFFFFF), width: 1.5),
                      ),
                      child: const Center(child: Text('🚿', style: TextStyle(fontSize: 52))),
                    ),
                    const SizedBox(height: 28),
                    const Text('Wash Club',
                        style: TextStyle(color: Colors.white, fontSize: 36,
                            fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 16),
                    Text(t.splash.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 14, height: 1.5)),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 60, left: 0, right: 0,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Opacity(
                  opacity: _fadeAnim.value,
                  child: Column(children: [
                    const SizedBox(
                      width: 28, height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0x80FFFFFF)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(t.splash.loading,
                        style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 12)),
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