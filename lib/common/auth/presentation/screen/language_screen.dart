import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/translations.g.dart';

import '../../../../core/theme/colors.dart';

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
    context.go(UserRoutePath.otpLogin);
  }

  String get _continueLabel {
    if (_selectedLang == 'uz') return 'Davom etish';
    if (_selectedLang == 'ru') return 'Продолжить';
    return 'Continue';
  }

  // initState, dispose, _onContinue, _continueLabel — o'zgarishsiz

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ApparenceKitColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: colors.background,
        child: Stack(
          children: [
            // Decorative circles
            Positioned(top: -80, right: -80, child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: colors.info.withValues(alpha: 0.05)),
            )),
            Positioned(bottom: 120, left: -100, child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.03)),
            )),
            Positioned(bottom: -60, right: 60, child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: colors.info.withValues(alpha: 0.05)),
            )),

            // Main content
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                    offset: Offset(0, _slideAnim.value), child: child),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: colors.onPrimaryContainer,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: colors.grey1, width: 1.5),
                              boxShadow: [BoxShadow(
                                color: colors.info.withValues(alpha: 0.15),
                                blurRadius: 20, spreadRadius: 1,
                              )],
                            ),
                            child: const Center(
                              child: Text('🚿', style: TextStyle(fontSize: 32)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('Wash Club', style: TextStyle(
                            color: colors.onBackground, fontSize: 32,
                            fontWeight: FontWeight.bold, letterSpacing: 0.3,
                          )),
                          const SizedBox(height: 6),
                          Text(
                            'Tilni tanlang / Выберите язык / Choose language',
                            style: TextStyle(color: colors.grey3, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 12),
                      child: Text('Tilni tanlang', style: TextStyle(
                        color: colors.grey3, fontSize: 11,
                        fontWeight: FontWeight.w600, letterSpacing: 0.8,
                      )),
                    ),

                    // Language list
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
                                onTap: () => setState(() => _selectedLang = lang.code),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colors.primary.withValues(alpha: 0.15)
                                        : colors.onPrimaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? colors.info : colors.grey1,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [BoxShadow(
                                      color: colors.info.withValues(alpha: 0.15),
                                      blurRadius: 12, offset: const Offset(0, 4),
                                    )]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Text(lang.flag, style: const TextStyle(fontSize: 30)),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(lang.name, style: TextStyle(
                                              color: isSelected ? colors.info : colors.onBackground,
                                              fontSize: 16,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700 : FontWeight.w500,
                                            )),
                                            const SizedBox(height: 2),
                                            Text(lang.native, style: TextStyle(
                                              color: isSelected
                                                  ? colors.info.withValues(alpha: 0.7)
                                                  : colors.grey3,
                                              fontSize: 13,
                                            )),
                                          ],
                                        ),
                                      ),
                                      // Radio circle
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: isSelected
                                            ? Container(
                                          key: ValueKey(lang.code),
                                          width: 24, height: 24,
                                          decoration: BoxDecoration(
                                            color: colors.info,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check,
                                              color: Colors.white, size: 14),
                                        )
                                            : Container(
                                          key: ValueKey('empty_${lang.code}'),
                                          width: 24, height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: colors.grey1, width: 1.5),
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

                    // Continue button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                      child: SizedBox(
                        width: double.infinity, height: 56,
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.info,
                            foregroundColor: colors.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_continueLabel, style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              )),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios, size: 16),
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