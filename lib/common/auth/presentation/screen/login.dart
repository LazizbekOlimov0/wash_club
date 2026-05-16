import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import 'package:wash_club/core/widgets/app_text_field.dart';
import '../../../../core/theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  bool get _isValid =>
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
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_isValid) return;
    context.go(UserRoutePath.home);
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel(t.login.name, colors),
                        const SizedBox(height: 10),
                        _styledField(
                          colors: colors,
                          icon: Icons.person_outline_rounded,
                          child: AppTextField(
                            title: '',
                            hintText: 'Jon Doe',
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _sectionLabel(t.login.phone, colors),
                        const SizedBox(height: 10),
                        _styledField(
                          colors: colors,
                          icon: Icons.phone_outlined,
                          child: AppTextField.phone(
                            title: '',
                            controller: _phoneController,
                            onChanged: (_) => setState(() {}),
                          ),
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
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: _buildButton(t, colors),
                        ),
                        const SizedBox(height: 24),
                        _buildDivider(colors),
                        const SizedBox(height: 20),
                        _buildFeatures(colors),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          Text(
            value,
            style: TextStyle(
              color: colors.info,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: colors.grey3,
              fontSize: 11,
            ),
          ),
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

  Widget _styledField({
    required Widget child,
    required IconData icon,
    required ApparenceKitColors colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.onCenterBG,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.grey1),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Icon(icon, color: colors.grey3, size: 18),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildButton(dynamic t, ApparenceKitColors colors) {
    final isActive = _isValid;
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
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.login.button,
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

  Widget _buildDivider(ApparenceKitColors colors) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.grey1, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Nima uchun biz?',
            style: TextStyle(
              color: colors.grey3.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.grey1, thickness: 1)),
      ],
    );
  }

  Widget _buildFeatures(ApparenceKitColors colors) {
    final features = [
      (Icons.bolt_rounded, 'Tez xizmat', 'Eng tez avtoyuv'),
      (Icons.verified_rounded, 'Sertifikatlangan', 'Ishonchli xizmat'),
      (Icons.wallet_rounded, "Qulay to'lov", 'Karta va naqd'),
    ];
    return Row(
      children: features.mapIndexed((i, f) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < features.length - 1 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.grey1),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(f.$1, color: colors.info, size: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  f.$2,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  f.$3,
                  style: TextStyle(
                    color: colors.grey3,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Extension for mapIndexed (agar loyihada yo'q bo'lsa)
extension _IndexedIterable<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T item) f) sync* {
    var index = 0;
    for (final item in this) {
      yield f(index++, item);
    }
  }
}