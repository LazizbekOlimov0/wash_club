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
import '../../../../shared/services/orders_repository.dart';
import '../../../../shared/services/client_session.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int _step = 0;
  bool _loading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  bool get _step1Valid =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().length >= 9;

  bool get _step2Valid =>
      _passwordController.text.trim().length >= 4 &&
      _confirmPasswordController.text.trim() ==
          _passwordController.text.trim();

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
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      final email = googleUser.email ?? '';

      final session = ClientSession.instance;
      if (!session.isOnboarded) {
        final name = displayName.isNotEmpty ? displayName : email;
        await session.saveProfile(
          name: name,
          phone: 'google_${DateTime.now().millisecondsSinceEpoch}',
          password: 'google_auth',
        );
      }

      OrdersRepository.instance.invalidate();
      if (mounted) {
        setState(() => _loading = false);
        context.go(UserRoutePath.home);
      }
    } catch (e) {
      log(e.toString(), name: 'RegisterScreen._signInWithGoogle');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Google orqali ro\'yxatdan o\'tishda xatolik'),
              backgroundColor: _c.error),
        );
      }
    }
  }

  void _goToStep2() {
    if (!_step1Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t.register.fillAllFields),
          backgroundColor: _c.error,
        ),
      );
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _onRegister() async {
    if (!_step2Valid || _loading) return;

    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t.register.passwordsNotMatch),
          backgroundColor: _c.error,
        ),
      );
      return;
    }

    if (password.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t.register.passwordTooShort),
          backgroundColor: _c.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ClientSession.instance.saveProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: password,
      );

      OrdersRepository.instance.invalidate();
      if (mounted) context.go(UserRoutePath.home);
    } catch (e) {
      log(e.toString(), name: 'RegisterScreen._onRegister');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Xatolik: $e'), backgroundColor: _c.error),
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
                    child: _step == 0
                        ? _buildStep1(t, colors)
                        : _buildStep2(t, colors),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(dynamic t, ApparenceKitColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(t.register.name, colors),
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
        _sectionLabel(t.register.phone, colors),
        const SizedBox(height: 10),
        AppTextField.phone(
          title: '',
          controller: _phoneController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 36),
        _buildContinueButton(colors),
        const SizedBox(height: 24),
        _buildDivider(colors),
        const SizedBox(height: 20),
        _buildGoogleButton(colors),
        const SizedBox(height: 24),
        _buildLoginLink(colors),
      ],
    );
  }

  Widget _buildStep2(dynamic t, ApparenceKitColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(t.register.password, colors),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: '••••••',
            hintStyle: TextStyle(color: colors.grey3, fontSize: 14),
            filled: true,
            fillColor: colors.surface,
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
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colors.grey2,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionLabel(t.register.confirmPassword, colors),
        const SizedBox(height: 10),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: '••••••',
            hintStyle: TextStyle(color: colors.grey3, fontSize: 14),
            filled: true,
            fillColor: colors.surface,
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
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colors.grey2,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        const SizedBox(height: 36),
        _buildRegisterButton(colors),
        const SizedBox(height: 24),
        _buildDivider(colors),
        const SizedBox(height: 20),
        _buildGoogleButton(colors),
        const SizedBox(height: 24),
        _buildLoginLink(colors),
      ],
    );
  }

  Widget _buildContinueButton(ApparenceKitColors colors) {
    final isActive = _step1Valid && !_loading;
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
          onPressed: isActive ? _goToStep2 : null,
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
          child: Row(
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

  Widget _buildRegisterButton(ApparenceKitColors colors) {
    final isActive = _step2Valid && !_loading;
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
          onPressed: isActive ? _onRegister : null,
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
          child: _loading
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
                      "Ro'yxatdan o'tish",
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
            : Icon(Icons.login_rounded, color: colors.grey2, size: 20),
        label: Text(
          "Google orqali ro'yxatdan o'tish",
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

  Widget _buildLoginLink(ApparenceKitColors colors) {
    final t = context.t;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.register.haveAccount,
            style: TextStyle(color: colors.grey2, fontSize: 14),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => context.pop(),
            child: Text(
              t.register.login,
              style: TextStyle(
                color: colors.info,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
          Row(
            children: [
              GestureDetector(
                onTap: _step > 0 ? () => setState(() => _step = 0) : null,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _step > 0 ? colors.surface : Colors.transparent,
                    shape: BoxShape.circle,
                    border: _step > 0
                        ? Border.all(color: colors.divider)
                        : null,
                  ),
                  child: _step > 0
                      ? Icon(Icons.arrow_back,
                          color: colors.onSurface, size: 18)
                      : null,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
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
            _step == 0 ? t.register.subtitle : t.register.stepPassword,
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

  Widget _buildDivider(ApparenceKitColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(child: Divider(color: colors.divider)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'yoki',
              style: TextStyle(color: colors.grey3, fontSize: 13),
            ),
          ),
          Expanded(child: Divider(color: colors.divider)),
        ],
      ),
    );
  }
}
