import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import 'package:wash_club/core/widgets/app_text_field.dart';

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

  // App color palette
  static const Color _bg = Color(0xFF0F1B35);
  static const Color _card = Color(0xFF1A2B4A);
  static const Color _accent = Color(0xFF3B72D9);
  static const Color _accentLight = Color(0xFF4E85F0);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8B9FC4);
  static const Color _border = Color(0xFF253552);
  static const Color _inputFill = Color(0xFF162035);

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── Hero header ──────────────────────────────────────
              _buildHero(t),

              // ── Form ─────────────────────────────────────────────
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel(t.login.name),
                        const SizedBox(height: 10),
                        _styledField(
                          child: AppTextField(
                            title: '',
                            hintText: 'Jon Doe',
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) => setState(() {}),
                          ),
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 20),
                        _sectionLabel(t.login.phone),
                        const SizedBox(height: 10),
                        _styledField(
                          child: AppTextField.phone(
                            title: '',
                            controller: _phoneController,
                            onChanged: (_) => setState(() {}),
                          ),
                          icon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 12,
                                color: _textSecondary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Ma\'lumotlaringiz xavfsiz saqlanadi',
                                style: TextStyle(
                                  color: _textSecondary.withValues(alpha: 0.6),
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Continue button
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: _buildButton(t),
                        ),

                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 20),
                        _buildFeatures(),
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

  Widget _buildHero(dynamic t) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 28,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3366), Color(0xFF0F1B35)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo badge
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _accent.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Text('🚿', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Wash Club',
            style: TextStyle(
              color: _textPrimary,
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
              color: _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _statBadge('500+', 'Mijozlar'),
              const SizedBox(width: 10),
              _statBadge('4.9 ★', 'Reyting'),
              const SizedBox(width: 10),
              _statBadge('24/7', 'Xizmat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _card.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _accentLight,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _styledField({required Widget child, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: _inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Icon(icon, color: _textSecondary, size: 18),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildButton(dynamic t) {
    final isActive = _isValid;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isActive
              ? const LinearGradient(
            colors: [Color(0xFF3B72D9), Color(0xFF2B5FAD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isActive ? null : const Color(0xFF1A2B4A),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: _accent.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isActive ? _onContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: _textSecondary,
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
                  color: isActive ? Colors.white : _textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : _border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: isActive ? Colors.white : _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: _border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Nima uchun biz?',
            style: TextStyle(
              color: _textSecondary.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: _border, thickness: 1)),
      ],
    );
  }

  Widget _buildFeatures() {
    final features = [
      (Icons.bolt_rounded, 'Tez xizmat', 'Eng tez avtoyuv'),
      (Icons.verified_rounded, 'Sertifikatlangan', 'Ishonchli xizmat'),
      (Icons.wallet_rounded, 'Qulay to\'lov', 'Karta va naqd'),
    ];
    return Row(
      children: features.map((f) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: f == features.last ? 0 : 10,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(f.$1, color: _accentLight, size: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  f.$2,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  f.$3,
                  style: TextStyle(
                    color: _textSecondary,
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