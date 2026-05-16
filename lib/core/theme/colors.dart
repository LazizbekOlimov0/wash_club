import 'package:flutter/material.dart';

class ApparenceKitColors extends ThemeExtension<ApparenceKitColors> {
  final Color primary;
  final Color onPrimary;
  final Color onPrimaryContainer;

  final Color background;
  final Color onBackground;
  final Color onCenterBG;

  final Color surface;
  final Color onSurface;

  // Semantic colors
  final Color success;
  final Color warning;
  final Color info;
  final Color error;
  final Color disabled;
  final Color disabledContent;

  // Grey shades
  final Color grey1;
  final Color grey2;
  final Color grey3;

  // Additional
  final Color divider;
  final Color shadow;

  const ApparenceKitColors({
    required this.primary,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.background,
    required this.onBackground,
    required this.onCenterBG,
    required this.surface,
    required this.onSurface,
    required this.success,
    required this.warning,
    required this.info,
    required this.error,
    required this.disabled,
    required this.disabledContent,
    required this.grey1,
    required this.grey2,
    required this.grey3,
    required this.divider,
    required this.shadow,
  });

  // ── DARK (navy blue — asosiy tema) ────────────────────────────────
  factory ApparenceKitColors.dark() => ApparenceKitColors(
    primary: const Color(0xFF3B72D9),
    onPrimary: const Color(0xFFFFFFFF),
    onPrimaryContainer: const Color(0xFF1A2B4A),
    background: const Color(0xFF0F1B35),
    onBackground: const Color(0xFFFFFFFF),
    onCenterBG: const Color(0xFF0F1B35),
    surface: const Color(0xFF1A2B4A),
    onSurface: const Color(0xFFFFFFFF),
    success: const Color(0xFF4CD97B),
    warning: const Color(0xFFFFB547),
    info: const Color(0xFF4E85F0),
    error: const Color(0xFFFF5C6A),
    disabled: const Color(0xFF253552),
    disabledContent: const Color(0xFF4A5E80),
    grey1: const Color(0xFF253552),
    grey2: const Color(0xFF4A5E80),
    grey3: const Color(0xFF8B9FC4),
    divider: const Color(0xFF1E2F50),
    shadow: const Color(0xFF000000),
  );

  // ── LIGHT ─────────────────────────────────────────────────────────
  factory ApparenceKitColors.light() => const ApparenceKitColors(
    primary: Color(0xFF2B5FAD),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryContainer: Color(0xFFF2F4F7),
    background: Color(0xFFF2F4F7),
    onBackground: Color(0xFF0F1B35),
    onCenterBG: Color(0xFF0F1B35),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0F1B35),
    success: Color(0xFF27AE60),
    warning: Color(0xFFF39C12),
    info: Color(0xFF2980B9),
    error: Color(0xFFE74C3C),
    disabled: Color(0xFFE2E6EF),
    disabledContent: Color(0xFFBCC0CC),
    grey1: Color(0xFFE2E6EF),
    grey2: Color(0xFF8B9FC4),
    grey3: Color(0xFF5A6B8A),
    divider: Color(0xFFEAEDF3),
    shadow: Color(0xFF000000),
  );

  // ── Helpers ───────────────────────────────────────────────────────
  Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);

  Color get successSurface => success.withValues(alpha: 0.15);
  Color get errorSurface => error.withValues(alpha: 0.15);
  Color get warningSurface => warning.withValues(alpha: 0.15);
  Color get infoSurface => info.withValues(alpha: 0.15);

  @override
  ApparenceKitColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? onPrimaryContainer,
    Color? background,
    Color? onBackground,
    Color? onCenterBG,
    Color? surface,
    Color? onSurface,
    Color? success,
    Color? warning,
    Color? info,
    Color? error,
    Color? disabled,
    Color? disabledContent,
    Color? grey1,
    Color? grey2,
    Color? grey3,
    Color? divider,
    Color? shadow,
  }) {
    return ApparenceKitColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      onCenterBG: onCenterBG ?? this.onCenterBG,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      error: error ?? this.error,
      disabled: disabled ?? this.disabled,
      disabledContent: disabledContent ?? this.disabledContent,
      grey1: grey1 ?? this.grey1,
      grey2: grey2 ?? this.grey2,
      grey3: grey3 ?? this.grey3,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ApparenceKitColors lerp(
      covariant ThemeExtension<ApparenceKitColors>? other,
      double t,
      ) {
    if (other == null || other is! ApparenceKitColors) return this;
    return ApparenceKitColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimaryContainer:
      Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      onCenterBG: Color.lerp(onCenterBG, other.onCenterBG, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      error: Color.lerp(error, other.error, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      disabledContent: Color.lerp(disabledContent, other.disabledContent, t)!,
      grey1: Color.lerp(grey1, other.grey1, t)!,
      grey2: Color.lerp(grey2, other.grey2, t)!,
      grey3: Color.lerp(grey3, other.grey3, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}