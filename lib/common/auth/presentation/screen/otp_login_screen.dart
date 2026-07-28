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

  // --- Test mode state ---
  bool _testMode = false;
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
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

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  bool get _phoneValid => _phoneController.text.trim().length >= 9;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();

    final prevPhone = ClientSession.instance.phone;
    if (prevPhone != null) {
      _phoneController.text = prevPhone;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // --------------- Phone submit (branch: test mode vs Telegram) ---------------

  Future<void> _handlePhoneSubmit() async {
    if (!_phoneValid || _loading) return;

    final rawPhone = _phoneController.text.trim();
    final phone = rawPhone.startsWith('+') ? rawPhone : '+998$rawPhone';

    setState(() {
      _loading = true;
      _errorText = '';
    });

    try {
      final result = await OtpService.instance.requestOtp(phone);

      if (!mounted) return;

      if (!result.ok) {
        setState(() {
          _loading = false;
          _errorText = result.error ?? context.t.login.errorOccurred;
        });
        return;
      }

      if (result.testMode) {
        setState(() {
          _loading = false;
          _testMode = true;
        });
      } else {
        final launched = await launchUrl(
          Uri.parse(OtpService.botUrl),
          mode: LaunchMode.externalApplication,
        );

        if (!mounted) return;

        setState(() {
          _loading = false;
          if (launched) {
            _botOpened = true;
          } else {
            _errorText =
                context.t.login.telegramNotOpened;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorText = context.t.login.networkError;
        });
      }
    }
  }

  // --------------- Test mode OTP verify ---------------

  String get _enteredOtp =>
      _otpControllers.map((c) => c.text).join();

  bool get _otpComplete => _enteredOtp.length == 6;

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      final pasted = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (pasted.length == 6) {
        for (int i = 0; i < 6; i++) {
          _otpControllers[i].text = pasted[i];
        }
        _otpFocusNodes.last.requestFocus();
        setState(() {});
        return;
      }
    }

    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onOtpBackspace(int index, String value) {
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyTestOtp() async {
    if (!_otpComplete || _verifyingOtp) return;

    final rawPhone = _phoneController.text.trim();
    final phone = rawPhone.startsWith('+') ? rawPhone : '+998$rawPhone';

    setState(() {
      _verifyingOtp = true;
      _otpError = '';
    });

    try {
      final result = await OtpService.instance.verifyOtp(
        phone: phone,
        code: _enteredOtp,
      );

      if (!mounted) return;

      if (result.ok) {
        await ClientSession.instance.saveFromOtp(
          customerId: result.customerId!,
          phone: result.phone!,
          name: result.fullName!,
        );
        OrdersRepository.instance.invalidate();
        if (mounted) {
          _goToPendingOrHome();
        }
      } else {
        setState(() {
          _verifyingOtp = false;
          _otpError = result.error ?? context.t.login.wrongCode;
          for (final c in _otpControllers) {
            c.clear();
          }
          _otpFocusNodes.first.requestFocus();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verifyingOtp = false;
          _otpError = 'Tarmoq xatosi. Internetingizni tekshiring.';
        });
      }
    }
  }

  // --------------- Telegram bot flow ---------------

  Future<void> _checkRegistration() async {
    final rawPhone = _phoneController.text.trim();
    if (_checkingRegistration) return;

    final phone =
        rawPhone.startsWith('+') ? rawPhone : '+998$rawPhone';

    setState(() {
      _checkingRegistration = true;
      _errorText = '';
    });

    try {
      final result = await OtpService.instance.checkCustomer(phone);

      if (!mounted) return;

      if (result.found) {
        await ClientSession.instance.saveFromOtp(
          customerId: result.customerId!,
          phone: result.phone!,
          name: result.fullName!,
        );
        if (result.telegramChatId != null) {
          await ClientSession.instance
              .saveTelegramChatId(result.telegramChatId!);
        }
        OrdersRepository.instance.invalidate();
        if (mounted) {
          _goToPendingOrHome();
        }
      } else {
        setState(() {
          _checkingRegistration = false;
          _errorText = context.t.login.notRegistered;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkingRegistration = false;
          _errorText = context.t.login.networkError;
        });
      }
    }
  }

  void _goBack() {
    setState(() {
      _testMode = false;
      _botOpened = false;
      _errorText = '';
      _otpError = '';
      for (final c in _otpControllers) {
        c.clear();
      }
    });
  }

  // --------------- Build ---------------

  @override
  Widget build(BuildContext context) {
    final colors = _c;

    String? subtitleText;
    if (_testMode) {
      subtitleText = context.t.login.testMode;
    } else if (_botOpened) {
      subtitleText = context.t.login.botRegister;
    } else {
      subtitleText = context.t.login.telegramSecure;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.background,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildHero(colors, subtitleText),
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: _testMode
                        ? _buildTestOtpForm(colors)
                        : _botOpened
                            ? _buildBotInstructions(colors)
                            : _buildPhoneForm(colors),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(ApparenceKitColors colors, String? subtitle) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 28,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Text('🚿', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Wash Club',
            style: TextStyle(
              color: colors.onBackground,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              height: 1.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: colors.grey3,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --------------- Phone form ---------------

  Widget _buildPhoneForm(ApparenceKitColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(context.t.login.phone, colors),
        const SizedBox(height: 10),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: colors.onSurface, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surface,
            hintText: '90 123 45 67',
            hintStyle: TextStyle(color: colors.grey2, fontSize: 15),
            prefixText: '+998 ',
            prefixStyle: TextStyle(
              color: colors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
        ),
        if (_errorText.isNotEmpty) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _errorText,
              style: TextStyle(color: colors.error, fontSize: 13),
            ),
          ),
        ],
        const SizedBox(height: 36),
        _buildButton(
          colors: colors,
          onPressed: _handlePhoneSubmit,
          isActive: _phoneValid && !_loading,
          isLoading: _loading,
          label: context.t.login.telegramLogin,
          icon: Icons.telegram,
        ),
        const SizedBox(height: 20),
        _buildTelegramInfo(colors),
      ],
    );
  }

  // --------------- Test mode OTP form ---------------

  Widget _buildTestOtpForm(ApparenceKitColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _goBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.divider),
                ),
                child: Icon(Icons.arrow_back_rounded,
                    color: colors.grey2, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '+998 ${_phoneController.text.trim()}',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Test mode info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.info.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.bug_report, size: 18, color: colors.info),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.t.login.testCode,
                  style: TextStyle(
                    color: colors.grey3,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _sectionLabel('Tasdiqlash kodini kiriting', colors),
        const SizedBox(height: 12),

        // OTP input row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 50,
              height: 56,
              child: TextField(
                controller: _otpControllers[i],
                focusNode: _otpFocusNodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: colors.surface,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: colors.primary, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: colors.error, width: 1.5),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  _onOtpChanged(i, value);
                  if (value.isEmpty) {
                    _onOtpBackspace(i, value);
                  }
                },
              ),
            );
          }),
        ),
        if (_otpError.isNotEmpty) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _otpError,
              style: TextStyle(color: colors.error, fontSize: 13),
            ),
          ),
        ],
        const SizedBox(height: 28),

        _buildButton(
          colors: colors,
          onPressed: _verifyTestOtp,
          isActive: _otpComplete && !_verifyingOtp,
          isLoading: _verifyingOtp,
          label: _verifyingOtp ? context.t.login.verifying : context.t.login.verifyCode,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --------------- Bot instructions ---------------

  Widget _buildBotInstructions(ApparenceKitColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _goBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.divider),
                ),
                child: Icon(Icons.arrow_back_rounded,
                    color: colors.grey2, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '+998 ${_phoneController.text.trim()}',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.info.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                context.t.login.telegramOpened,
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.t.login.stepInstruction,
                style: TextStyle(
                  color: colors.grey3,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        if (_errorText.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: colors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    color: colors.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorText,
                    style: TextStyle(
                        color: colors.error,
                        fontSize: 12,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        _buildButton(
          colors: colors,
          onPressed: _checkRegistration,
          isActive: !_checkingRegistration,
          isLoading: _checkingRegistration,
          label: _checkingRegistration
              ? context.t.login.verifying
              : context.t.login.iRegistered,
          icon: Icons.check_circle_outline,
        ),

        const SizedBox(height: 20),

        Center(
          child: TextButton.icon(
            onPressed: () async {
              await launchUrl(
                Uri.parse(OtpService.botUrl),
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(context.t.login.reopenBot),
            style: TextButton.styleFrom(foregroundColor: colors.info),
          ),
        ),
      ],
    );
  }

  // --------------- Shared widgets ---------------

  Widget _buildButton({
    required ApparenceKitColors colors,
    required VoidCallback onPressed,
    required bool isActive,
    required bool isLoading,
    required String label,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isActive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? colors.primary : colors.grey2.withValues(alpha: 0.3),
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.grey2.withValues(alpha: 0.3),
          disabledForegroundColor: colors.grey3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                ),
              )
            else ...[
              Icon(icon, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              isLoading ? '' : label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, ApparenceKitColors colors) {
    return Text(
      text,
      style: TextStyle(
        color: colors.grey3,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTelegramInfo(ApparenceKitColors colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.info.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: colors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.t.settings.otpTelegram,
              style: TextStyle(
                color: colors.grey3,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
