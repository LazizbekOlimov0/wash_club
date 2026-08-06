import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wash_club/core/i18n/translations.g.dart';
import 'package:wash_club/config/router/router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/services/client_session.dart';
import '../../../../shared/services/otp_service.dart';
import '../../../../shared/services/orders_repository.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _phoneController = TextEditingController();

  bool _loading = false;
  bool _botOpened = false;
  bool _checkingRegistration = false;
  String _errorText = '';
  String? _loginToken;
  Timer? _pollTimer;

  // --- Test mode state ---
  bool _testMode = false;
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _verifyingOtp = false;
  String _otpError = '';

  void _goToPendingOrHome() {
    if (mounted) {
      if (Navigator.of(context).canPop()) {
        context.pop();
        return;
      }
      context.go(UserRoutePath.home);
    }
  }

  ApparenceKitColors get _c => Theme.of(context).extension<ApparenceKitColors>()!;

  bool get _phoneValid => _phoneController.text.trim().length >= 9;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.8, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();

    final prevPhone = ClientSession.instance.phone;
    if (prevPhone != null) _phoneController.text = prevPhone;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _animController.dispose();
    _phoneController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneSubmit() async {
    if (!_phoneValid || _loading) return;

    final rawPhone = _phoneController.text.trim();
    final phone = rawPhone.startsWith('+') ? rawPhone : '+998$rawPhone';

    setState(() { _loading = true; _errorText = ''; });

    try {
      // Try OTP request (test mode only)
      final result = await OtpService.instance.requestOtp(phone);
      if (!mounted) return;

      if (result.testMode) {
        setState(() { _loading = false; _testMode = true; });
        return;
      }

      // Codeless login: otp-request already created the login_requests row,
      // use the token from the edge function response.
      final token = result.token;
      if (token == null || token.isEmpty) {
        if (mounted) setState(() { _loading = false; _errorText = context.t.login.networkError; });
        return;
      }
      _loginToken = token;
      debugPrint('[OtpLogin] Token from otp-request: $token');

      final botUrl = OtpService.instance.botLoginUrl(token);
      debugPrint('[OtpLogin] Opening Telegram deeplink: $botUrl');
      final launched = await launchUrl(Uri.parse(botUrl), mode: LaunchMode.externalApplication);
      debugPrint('[OtpLogin] launchUrl result: $launched');
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (launched) { _botOpened = true; _startPolling(); }
        else { _errorText = context.t.login.telegramNotOpened; }
      });
    } catch (e, st) {
      debugPrint('[OtpLogin] _handlePhoneSubmit error: $e');
      debugPrint('[OtpLogin] stack: $st');
      if (mounted) setState(() { _loading = false; _errorText = context.t.login.networkError; });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkLogin());
  }

  Future<void> _checkLogin() async {
    if (_loginToken == null) return;
    final result = await OtpService.instance.checkLoginStatus(_loginToken!);
    if (!mounted) return;

    if (result.ok && result.customerId != null) {
      _pollTimer?.cancel();
      await ClientSession.instance.saveFromOtp(
        customerId: result.customerId!,
        phone: result.phone!,
        name: result.fullName!,
      );
      OrdersRepository.instance.invalidate();
      if (mounted) _goToPendingOrHome();
    } else if (result.error != null) {
      _pollTimer?.cancel();
      setState(() { _errorText = result.error!; _loading = false; _botOpened = false; });
    }
  }

  // Test mode OTP
  String get _enteredOtp => _otpControllers.map((c) => c.text).join();
  bool get _otpComplete => _enteredOtp.length == 6;

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      final pasted = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (pasted.length == 6) {
        for (int i = 0; i < 6; i++) _otpControllers[i].text = pasted[i];
        _otpFocusNodes.last.requestFocus();
        setState(() {});
        return;
      }
    }
    if (value.length == 1 && index < 5) _otpFocusNodes[index + 1].requestFocus();
    setState(() {});
  }

  void _onOtpBackspace(int index, String value) {
    if (value.isEmpty && index > 0) _otpFocusNodes[index - 1].requestFocus();
  }

  Future<void> _verifyTestOtp() async {
    if (!_otpComplete || _verifyingOtp) return;
    final rawPhone = _phoneController.text.trim();
    final phone = rawPhone.startsWith('+') ? rawPhone : '+998$rawPhone';

    setState(() { _verifyingOtp = true; _otpError = ''; });

    try {
      final result = await OtpService.instance.verifyOtp(phone: phone, code: _enteredOtp);
      if (!mounted) return;

      if (result.ok) {
        await ClientSession.instance.saveFromOtp(customerId: result.customerId!, phone: result.phone!, name: result.fullName!);
        OrdersRepository.instance.invalidate();
        if (mounted) _goToPendingOrHome();
      } else {
        setState(() {
          _verifyingOtp = false;
          _otpError = result.error ?? context.t.login.wrongCode;
          for (final c in _otpControllers) c.clear();
          _otpFocusNodes.first.requestFocus();
        });
      }
    } catch (e) {
      if (mounted) setState(() { _verifyingOtp = false; _otpError = 'Tarmoq xatosi.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _c.background,
      body: Stack(
        children: [
          // Animated water bubbles background
          const _WaterBackground(),
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _testMode ? _buildOtpStep() : _buildPhoneStep(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            // App icon
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _c.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text('🚗', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 24),
            Text(context.t.login.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _c.onBackground)),
            const SizedBox(height: 8),
            Text(context.t.login.subtitle, style: TextStyle(fontSize: 14, color: _c.grey2)),
            const SizedBox(height: 32),
            // Phone input
            Container(
              decoration: BoxDecoration(
                color: _c.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _c.primary.withValues(alpha: 0.2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('+998', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _c.onBackground)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _c.onBackground),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'XX XXX XX XX',
                        hintStyle: TextStyle(color: _c.grey2.withValues(alpha: 0.5), fontSize: 16),
                      ),
                      onChanged: (_) => setState(() => _errorText = ''),
                    ),
                  ),
                ],
              ),
            ),
            if (_errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_errorText, style: TextStyle(color: _c.error, fontSize: 13)),
              ),
            const SizedBox(height: 24),
            // Submit button
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _handlePhoneSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _c.primary,
                  disabledBackgroundColor: _c.primary.withValues(alpha: 0.5),
                  foregroundColor: _c.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(context.t.login.button, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ),
            if (_botOpened) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _c.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: const Color(0xFF229ED9), borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Telegram', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _c.onBackground)),
                          const SizedBox(height: 2),
                          Text(context.t.login.telegramSecure, style: TextStyle(fontSize: 13, color: _c.grey2)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOtpStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            Text(context.t.login.verifyCode, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _c.onBackground)),
            const SizedBox(height: 8),
            Text('+998 ${_phoneController.text.trim()}', style: TextStyle(fontSize: 14, color: _c.grey2)),
            const SizedBox(height: 28),
            Builder(builder: (context) {
              final screenW = MediaQuery.of(context).size.width;
              final totalPadding = 48.0; // 24 on each side
              final totalMargins = 8.0 * 6; // 4px horizontal margin per cell
              final cellW = ((screenW - totalPadding - totalMargins) / 6).clamp(40.0, 52.0);
              final cellH = cellW * 1.15;
              final fontSize = cellW * 0.48;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Container(
                    width: cellW, height: cellH,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _otpControllers[i],
                      focusNode: _otpFocusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      showCursor: false,
                      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: _c.onBackground),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: _c.surface,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _c.primary.withValues(alpha: 0.3))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _c.primary, width: 2)),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) => _onOtpChanged(i, v),
                    ),
                  );
                }),
              );
            }),
            if (_otpError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_otpError, style: TextStyle(color: _c.error, fontSize: 13)),
              ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _otpComplete && !_verifyingOtp ? _verifyTestOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _c.primary,
                  foregroundColor: _c.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _verifyingOtp
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(context.t.login.verifying, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated water bubbles background ──
class _WaterBackground extends StatefulWidget {
  const _WaterBackground();
  @override
  State<_WaterBackground> createState() => _WaterBackgroundState();
}

class _WaterBackgroundState extends State<_WaterBackground> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<ApparenceKitColors>()!;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return CustomPaint(
          size: Size.infinite,
          painter: _BubblePainter(c.primary.withValues(alpha: 0.06), _ctrl.value),
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final double t;

  _BubblePainter(this.color, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final rng = _hash(t);

    for (int i = 0; i < 8; i++) {
      final x = size.width * (0.1 + (rng[i % rng.length] / 100) * 0.8);
      final y = size.height * (0.3 - (t + i * 0.13) % 1.3);
      final r = 20.0 + (rng[(i + 3) % rng.length] % 40).toDouble();
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  List<int> _hash(double v) {
    final h = (v * 100000).toInt();
    return List.generate(12, (i) => ((h >> (i * 2)) & 0xFF));
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => old.t != t;
}
