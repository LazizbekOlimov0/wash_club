import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import 'package:wash_club/core/widgets/app_text_field.dart';
import '../../../../core/theme/colors.dart';
import '../../../../data/repositories/orders_repository.dart';
import '../../../../shared/services/client_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  bool _loading = false;
  bool _googleDone = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  bool get _formValid =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().length >= 9;

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
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();

    final session = ClientSession.instance;
    if (session.name != null) {
      _nameController.text = session.name!;
      _phoneController.text = session.phone ?? '';
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  static const _googleServerClientId =
      '565322626454-ikd1isvlucko712vr7bcp01lo1kvlh1d.apps.googleusercontent.com';
  static const _googleIOSClientId =
      '565322626454-lhdd6lu93ufa430qqi33i23bjfj2ijv7.apps.googleusercontent.com';

  Future<void> _signInWithGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final googleUser = await GoogleSignIn(
        serverClientId: _googleServerClientId,
        clientId: Platform.isIOS ? _googleIOSClientId : null,
      ).signIn();

      if (googleUser == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final auth = await googleUser.authentication;
      if (auth.idToken == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: auth.idToken!,
        accessToken: auth.accessToken!,
      );

      final displayName = googleUser.displayName ?? '';
      if (displayName.isNotEmpty && _nameController.text.trim().isEmpty) {
        _nameController.text = displayName;
        setState(() {});
      }

      _googleDone = true;
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      log(e.toString(), name: 'LoginScreen._signInWithGoogle');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google orqali kirishda xatolik'), backgroundColor: _c.error),
        );
      }
    }
  }

  Future<void> _onContinue() async {
    if (!_formValid || _loading) return;
    setState(() => _loading = true);

    try {
      await ClientSession.instance.saveProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      OrdersRepository.instance.invalidate();

      if (mounted) context.go(UserRoutePath.home);
    } catch (e) {
      log(e.toString(), name: 'LoginScreen._onContinue');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e'), backgroundColor: _c.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = _c;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.background,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildHero(t, colors),
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: _buildForm(t, colors),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(dynamic t, ApparenceKitColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(t.login.name, colors),
        const SizedBox(height: 10),
        AppTextField(
          title: '',
          hintText: 'Jon Doe',
          controller: _nameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _sectionLabel(t.login.phone, colors),
        const SizedBox(height: 10),
        AppTextField.phone(
          title: '',
          controller: _phoneController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: colors.grey3.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 5),
              Text(
                "Ma'lumotlaringiz xavfsiz saqlanadi",
                style: TextStyle(
                  color: colors.grey3.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        ScaleTransition(
          scale: _scaleAnim,
          child: _buildContinueButton(colors),
        ),
        const SizedBox(height: 24),
        _buildDivider(colors),
        const SizedBox(height: 20),
        _buildGoogleButton(colors),
        const SizedBox(height: 24),
        _buildFeatures(colors),
      ],
    );
  }

  Widget _buildContinueButton(ApparenceKitColors colors) {
    final isActive = _formValid && !_loading;
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
          onPressed: isActive ? _onContinue : null,
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
          child: _loading && !_googleDone
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
                    Text(
                      'Davom etish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isActive ? colors.onPrimary : colors.grey3,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isActive
                            ? colors.onPrimary.withValues(alpha: 0.2)
                            : colors.grey1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: isActive ? colors.onPrimary : colors.grey3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(ApparenceKitColors colors) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _signInWithGoogle,
        icon: _loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(colors.grey2),
                ),
              )
            : Image.asset(
                'assets/image/car_img.png', // placeholder, Google icon would be better
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.login_rounded, color: colors.grey2, size: 20),
              ),
        label: Text(
          'Google orqali kirish',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.onBackground,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.surface,
          side: BorderSide(color: colors.divider),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildHero(dynamic t, ApparenceKitColors colors) {
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
            t.login.subtitle,
            style: TextStyle(
              color: colors.grey3,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statBadge('500+', 'Mijozlar', colors),
              const SizedBox(width: 10),
              _statBadge('4.9 ★', 'Reyting', colors),
              const SizedBox(width: 10),
              _statBadge('24/7', 'Xizmat', colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String value, String label, ApparenceKitColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.grey1),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: colors.info,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 1),
          Text(label,
              style: TextStyle(color: colors.grey3, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ApparenceKitColors colors) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: colors.grey3,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDivider(ApparenceKitColors colors) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('yoki', style: TextStyle(color: colors.grey2, fontSize: 12)),
        ),
        Expanded(child: Divider(color: colors.divider)),
      ],
    );
  }

  Widget _buildFeatures(ApparenceKitColors colors) {
    return Column(
      children: [
        _featureRow(Icons.speed_rounded, 'Tezkor bron qilish', colors),
        const SizedBox(height: 12),
        _featureRow(Icons.history_rounded, 'Buyurtmalar tarixi', colors),
        const SizedBox(height: 12),
        _featureRow(Icons.local_offer_rounded, 'Chegirmalar va bonuslar', colors),
      ],
    );
  }

  Widget _featureRow(IconData icon, String text, ApparenceKitColors colors) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: colors.grey3, fontSize: 13)),
      ],
    );
  }
}
