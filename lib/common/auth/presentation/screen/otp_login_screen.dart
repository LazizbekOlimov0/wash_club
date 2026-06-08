import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  bool _loading = false;
  bool _codeSent = false;
  bool _needsName = false;
  String _errorText = '';

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
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final phone = _phoneController.text.trim();
    if (!_phoneValid || _loading) return;

    setState(() {
      _loading = true;
      _errorText = '';
    });

    try {
      final result = await OtpService.instance.requestOtp(phone);

      if (!mounted) return;

      if (result.ok) {
        setState(() {
          _codeSent = true;
          _loading = false;
        });

        final botUrl = OtpService.botVerifyUrl(phone);
        try {
          await launchUrl(Uri.parse(botUrl), mode: LaunchMode.externalApplication);
        } catch (_) {
          // URL ochib bo'lmadi — foydalanuvchi qo'lda @washclub_bot ga kirishi kerak
        }
      } else if (result.error == 'rate_limited') {
        setState(() {
          _loading = false;
          _errorText = 'Juda tez-tez so\'rayapsiz. Biroz kuting.';
        });
      } else if (result.error == 'hourly_limit_exceeded') {
        setState(() {
          _loading = false;
          _errorText = 'Soatlik limit oshib ketdi. Keyinroq urinib ko\'ring.';
        });
      } else {
        setState(() {
          _loading = false;
          _errorText = result.error ?? 'Xatolik yuz berdi. Qayta urinib ko\'ring.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorText = 'Tarmoq xatosi. Internetingizni tekshiring.';
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    final code = _codeController.text.trim();
    if (code.length != 6 || _loading) return;

    setState(() {
      _loading = true;
      _errorText = '';
    });

    try {
      final phone = _phoneController.text.trim();
      final result = await OtpService.instance.verifyOtp(
        phone: phone,
        code: code,
      );

      if (!mounted) return;

      if (result.ok) {
        if (result.fullName == 'Mehmon') {
          setState(() {
            _loading = false;
            _needsName = true;
          });
        } else {
          await _finishLogin(result.customerId!, result.phone!, result.fullName!);
        }
      } else {
        setState(() {
          _loading = false;
          _errorText = result.message ?? result.error ?? 'Kod noto\'g\'ri';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorText = 'Tarmoq xatosi. Internetingizni tekshiring.';
        });
      }
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _loading) return;

    setState(() {
      _loading = true;
      _errorText = '';
    });

    try {
      final phone = _phoneController.text.trim();
      final code = _codeController.text.trim();
      final result = await OtpService.instance.verifyOtp(
        phone: phone,
        code: code,
        name: name,
      );

      if (!mounted) return;

      if (result.ok) {
        await _finishLogin(result.customerId!, result.phone!, result.fullName!);
      } else {
        setState(() {
          _loading = false;
          _errorText = result.message ?? 'Xatolik yuz berdi';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorText = 'Tarmoq xatosi';
        });
      }
    }
  }

  Future<void> _finishLogin(
      String customerId, String phone, String name) async {
    await ClientSession.instance.saveFromOtp(
      customerId: customerId,
      phone: phone,
      name: name,
    );
    OrdersRepository.instance.invalidate();
    if (mounted) {
      context.go(UserRoutePath.home);
    }
  }

  void _goBack() {
    if (_needsName) {
      setState(() => _needsName = false);
    } else if (_codeSent) {
      setState(() {
        _codeSent = false;
        _errorText = '';
        _codeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _c;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.background,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildHero(colors),
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: _needsName
                        ? _buildNameForm(colors)
                        : _codeSent
                            ? _buildOtpForm(colors)
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

  Widget _buildHero(ApparenceKitColors colors) {
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
          if (!_codeSent && !_needsName) ...[
            const SizedBox(height: 8),
            Text(
              'Telegram bot orqali xavfsiz kirish',
              style: TextStyle(
                color: colors.grey3,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          if (_codeSent && !_needsName) ...[
            const SizedBox(height: 8),
            Text(
              'Telegram\'ga yuborilgan 6 raqamli kodni kiriting',
              style: TextStyle(
                color: colors.grey3,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          if (_needsName) ...[
            const SizedBox(height: 8),
            Text(
              'Ismingizni kiriting',
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

  Widget _buildPhoneForm(ApparenceKitColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Telefon raqam', colors),
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
          onPressed: _requestOtp,
          isActive: _phoneValid && !_loading,
          isLoading: _loading,
          label: 'Telegram orqali kirish',
          icon: Icons.telegram,
        ),
        const SizedBox(height: 20),
        _buildTelegramInfo(colors),
      ],
    );
  }

  Widget _buildOtpForm(ApparenceKitColors colors) {
    final codeComplete = _codeController.text.trim().length == 6;

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
        _sectionLabel('Tasdiqlash kodi', colors),
        const SizedBox(height: 10),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          onChanged: (_) => setState(() {}),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: colors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          onPressed: _verifyOtp,
          isActive: codeComplete && !_loading,
          isLoading: _loading,
          label: 'Tasdiqlash',
          icon: Icons.check_rounded,
        ),
        const SizedBox(height: 24),
        _buildResendCode(colors),
      ],
    );
  }

  Widget _buildNameForm(ApparenceKitColors colors) {
    final nameValid = _nameController.text.trim().isNotEmpty;

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
              'Ismingiz',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _sectionLabel('Ism va familiya', colors),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          onSubmitted: nameValid ? (_) => _saveName() : null,
          style: TextStyle(color: colors.onSurface, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surface,
            hintText: 'Ism Familiya',
            hintStyle: TextStyle(color: colors.grey2, fontSize: 15),
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
          onPressed: _saveName,
          isActive: nameValid && !_loading,
          isLoading: _loading,
          label: 'Davom etish',
          icon: Icons.arrow_forward_rounded,
        ),
      ],
    );
  }

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isActive ? colors.primary : colors.surface,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isActive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: colors.onPrimary,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: colors.grey3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isActive ? colors.onPrimary : colors.grey3,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTelegramInfo(ApparenceKitColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.info.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.info_outline, color: colors.info, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '@washclub_bot Telegram botiga o\'tib, '
              '"Share Phone Number" tugmasini bosasiz. '
              'Bot sizga 6 raqamli kod yuboradi.',
              style: TextStyle(
                color: colors.grey3,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendCode(ApparenceKitColors colors) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Kod kelmadimi? ',
            style: TextStyle(color: colors.grey2, fontSize: 14),
          ),
          GestureDetector(
            onTap: _loading ? null : _requestOtp,
            child: Text(
              'Qayta yuborish',
              style: TextStyle(
                color: _loading ? colors.grey3 : colors.info,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ApparenceKitColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: colors.grey3,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
