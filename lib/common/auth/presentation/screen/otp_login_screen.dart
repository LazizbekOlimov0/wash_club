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

  bool _loading = false;
  bool _botOpened = false;
  bool _checkingRegistration = false;
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
    super.dispose();
  }

  Future<void> _openBotAndRegister() async {
    if (!_phoneValid || _loading) return;

    setState(() {
      _loading = true;
      _errorText = '';
    });

    try {
      final launched = await launchUrl(
        Uri.parse(OtpService.botUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;

      if (launched) {
        setState(() {
          _botOpened = true;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _errorText =
              'Telegram ilovasi ochilmadi. @washclub_bot ga qo\'lda kiring.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorText =
              'Telegram ochishda xatolik. @washclub_bot ga qo\'lda kiring.';
        });
      }
    }
  }

  Future<void> _checkRegistration() async {
    final rawPhone = _phoneController.text.trim();
    if (_checkingRegistration) return;

    final phone = rawPhone.startsWith('+')
        ? rawPhone
        : '+998$rawPhone';

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
          context.go(UserRoutePath.home);
        }
      } else {
        setState(() {
          _checkingRegistration = false;
          _errorText = 'Ro\'yxatdan o\'tilmagan. Botda /start ni bosib, '
              'telefon raqamingizni "📱 Telefon raqamni ulashish" tugmasi orqali yuboring.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkingRegistration = false;
          _errorText = 'Tarmoq xatosi. Internetingizni tekshiring.';
        });
      }
    }
  }

  void _goBack() {
    setState(() {
      _botOpened = false;
      _errorText = '';
    });
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
                    child: _botOpened
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
          const SizedBox(height: 8),
          Text(
            _botOpened
                ? 'Botda ro\'yxatdan o\'ting'
                : 'Telegram bot orqali xavfsiz kirish',
            style: TextStyle(
              color: colors.grey3,
              fontSize: 14,
              height: 1.4,
            ),
          ),
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
          onPressed: _openBotAndRegister,
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

        // Instruction card
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
                'Telegram bot ochildi',
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Botda /start tugmasini bosing\n'
                '2. "📱 Telefon raqamni ulashish" tugmasini bosing\n'
                '3. Ro\'yxatdan o\'tgach, pastdagi tugmani bosing',
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
              border: Border.all(color: colors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: colors.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorText,
                    style: TextStyle(
                        color: colors.error, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Check registration button
        _buildButton(
          colors: colors,
          onPressed: _checkRegistration,
          isActive: !_checkingRegistration,
          isLoading: _checkingRegistration,
          label:
              _checkingRegistration ? 'Tekshirilmoqda...' : 'Ro\'yxatdan o\'tdim',
          icon: Icons.check_circle_outline,
        ),

        const SizedBox(height: 20),

        // Open bot again
        Center(
          child: TextButton.icon(
            onPressed: _openBotAndRegister,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Botni qayta ochish'),
            style: TextButton.styleFrom(foregroundColor: colors.info),
          ),
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
              'Davom etish uchun Telegram botga o\'tasiz. '
              'Botda /start ni bosib, telefon raqamingizni ulashing.',
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
