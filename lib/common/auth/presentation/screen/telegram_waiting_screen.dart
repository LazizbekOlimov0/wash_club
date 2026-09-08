import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wash_club/core/i18n/translations.g.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/common/auth/presentation/widgets/water_background.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/services/client_session.dart';
import '../../../../shared/services/otp_service.dart';
import '../../../../shared/services/orders_repository.dart';

class TelegramWaitingScreen extends StatefulWidget {
  final String loginToken;

  const TelegramWaitingScreen({super.key, required this.loginToken});

  @override
  State<TelegramWaitingScreen> createState() => _TelegramWaitingScreenState();
}

class _TelegramWaitingScreenState extends State<TelegramWaitingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  Timer? _pollTimer;
  String? _errorText;

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkLogin());
  }

  Future<void> _checkLogin() async {
    try {
      final result =
          await OtpService.instance.checkLoginStatus(widget.loginToken);
      if (!mounted) return;

      if (result.ok && result.customerId != null) {
        _pollTimer?.cancel();
        await ClientSession.instance.saveFromOtp(
          customerId: result.customerId!,
          phone: result.phone!,
          name: result.fullName!,
        );
        OrdersRepository.instance.invalidate();
        if (mounted) {
          context.go(UserRoutePath.home);
        }
      } else if (result.error != null) {
        _pollTimer?.cancel();
        if (mounted) {
          setState(() {
            _errorText = result.error!;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _reopenTelegram() async {
    final t = context.t;
    final shouldOpen = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(t.login.openTelegramTitle),
        content: Text(t.login.openTelegramBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.login.openTelegramCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.login.openTelegramOpen),
          ),
        ],
      ),
    );
    if (shouldOpen != true) return;

    final token = widget.loginToken;
    final tgUri = Uri.parse(
        'tg://resolve?domain=washclub_bot&start=login_$token');
    final canTg = await canLaunchUrl(tgUri);
    if (canTg) {
      await launchUrl(tgUri, mode: LaunchMode.externalApplication);
      return;
    }
    final httpsUri = Uri.parse(OtpService.instance.botLoginUrl(token));
    await launchUrl(httpsUri, mode: LaunchMode.externalApplication);
  }

  void _goBack() {
    _pollTimer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      backgroundColor: _c.background,
      body: Stack(
        children: [
          const WaterBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _goBack,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _c.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _c.divider,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: _c.onSurface,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      SvgPicture.asset(
                        'assets/image/group2.svg',
                        width: 240,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        t.login.telegramWaitTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _c.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t.login.telegramWaitDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: _c.grey2,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _c.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            t.login.telegramWaitPending,
                            style: TextStyle(
                              fontSize: 13,
                              color: _c.grey2,
                            ),
                          ),
                        ],
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorText!,
                          style: TextStyle(
                            color: _c.error,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const Spacer(flex: 2),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _reopenTelegram,
                          icon: const Icon(Icons.send, size: 18),
                          label: Text(
                            t.login.telegramWaitOpen,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _c.primary,
                            foregroundColor: _c.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _goBack,
                        child: Text(
                          t.login.telegramWaitCantLogin,
                          style: TextStyle(
                            fontSize: 13,
                            color: _c.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: _c.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
