import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/translations.g.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  String _selectedLang = 'uz';
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  final List<_LangItem> _languages = [
    _LangItem(code: 'uz', flag: '🇺🇿', name: "O'zbek", native: "O'zbekcha"),
    _LangItem(code: 'ru', flag: '🇷🇺', name: 'Русский', native: 'Русский язык'),
    _LangItem(code: 'en', flag: '🇬🇧', name: 'English', native: 'English'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideAnim = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue() {
    LocaleSettings.setLocaleRaw(_selectedLang);
    context.go(UserRoutePath.login);
  }

  String get _continueLabel {
    if (_selectedLang == 'uz') return 'Davom etish';
    if (_selectedLang == 'ru') return 'Продолжить';
    return 'Continue';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A1A2E),
              Color(0xFF0D1525),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative circles ──────────────────────────────
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0D4D9EFF),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x082B5FAD),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: 60,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0D4D9EFF),
                ),
              ),
            ),

            // ── Main content ────────────────────────────────────
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: child,
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo box — SplashScreen dek
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2340),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFF2A3560),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4D9EFF)
                                      .withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🚿',
                                  style: TextStyle(fontSize: 32)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Wash Club',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tilni tanlang / Выберите язык / Choose language',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Section label ───────────────────────────
                    const Padding(
                      padding: EdgeInsets.only(left: 24, bottom: 12),
                      child: Text(
                        'Tilni tanlang',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // ── Language list ───────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: List.generate(_languages.length, (i) {
                            final lang = _languages[i];
                            final isSelected = _selectedLang == lang.code;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () => setState(
                                        () => _selectedLang = lang.code),
                                child: AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1E2E55)
                                        : const Color(0xFF1C2340),
                                    borderRadius:
                                    BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF4D9EFF)
                                          : const Color(0xFF2A3560),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: const Color(0xFF4D9EFF)
                                            .withValues(alpha: 0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      // Flag
                                      Text(lang.flag,
                                          style: const TextStyle(
                                              fontSize: 30)),
                                      const SizedBox(width: 14),
                                      // Names
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lang.name,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? const Color(0xFF4D9EFF)
                                                    : Colors.white,
                                                fontSize: 16,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              lang.native,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? const Color(0xFF4D9EFF)
                                                    .withValues(
                                                    alpha: 0.7)
                                                    : const Color(0xFF6B7280),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Radio circle
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        child: isSelected
                                            ? Container(
                                          key: ValueKey(lang.code),
                                          width: 24,
                                          height: 24,
                                          decoration:
                                          const BoxDecoration(
                                            color: Color(0xFF4D9EFF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        )
                                            : Container(
                                          key: ValueKey(
                                              'empty_${lang.code}'),
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(
                                                  0xFF2A3560),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    // ── Continue button ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D9EFF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: const Color(0xFF4D9EFF)
                                .withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _continueLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangItem {
  final String code;
  final String flag;
  final String name;
  final String native;

  const _LangItem({
    required this.code,
    required this.flag,
    required this.name,
    required this.native,
  });
}