import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/core/i18n/translations.g.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/common/auth/presentation/widgets/water_background.dart';
import 'package:wash_club/common/auth/presentation/screen/telegram_waiting_screen.dart';
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
  String _errorText = '';

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
    if (prevPhone != null) {
      _phoneController.text = prevPhone.startsWith('+998') ? prevPhone.substring(4) : prevPhone;
    }
  }

  @override
  void dispose() {
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
      debugPrint('[OtpLogin] Token from otp-request: $token');
      setState(() { _loading = false; });
      if (!mounted) return;
      _navigateToWaiting(token);
    } catch (e, st) {
      debugPrint('[OtpLogin] _handlePhoneSubmit error: $e');
      debugPrint('[OtpLogin] stack: $st');
      if (mounted) setState(() { _loading = false; _errorText = context.t.login.networkError; });
    }
  }

  void _navigateToWaiting(String token) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TelegramWaitingScreen(loginToken: token),
      ),
    );
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
          const WaterBackground(),
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
            const SizedBox(height: 48),
            Text(context.t.login.title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _c.onBackground)),
            const SizedBox(height: 6),
            Text(context.t.login.subtitle, style: TextStyle(fontSize: 14, color: _c.grey2)),
            const SizedBox(height: 28),
            // Phone input — two separate blocks
            Row(
              children: [
                // Country code block
                SizedBox(
                  width: 112,
                  height: 56,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _c.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _c.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇺🇿', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text('+998', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _c.onBackground)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Number input block
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: _c.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _c.primary.withValues(alpha: 0.2)),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _c.onBackground),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '90 123 45 67',
                        hintStyle: TextStyle(color: _c.grey2, fontSize: 16),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (_) => setState(() => _errorText = ''),
                    ),
                  ),
                ),
              ],
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
            const SizedBox(height: 16),
            Text(
              'Davom etish orqali siz xizmat shartlariga rozilik bildirasiz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _c.grey2, fontSize: 12),
            ),
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
