import 'package:flutter/material.dart';
import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/theme/texts.dart';
import 'package:wash_club/core/theme/theme_data/theme_data.dart';
import 'package:wash_club/core/theme/theme_data/theme_data_factory.dart';

class UniversalThemeFactory extends ApparenceKitThemeDataFactory {
  const UniversalThemeFactory();

  @override
  ApparenceKitThemeData build({
    required ApparenceKitColors colors,
    required ApparenceKitTextTheme defaultTextStyle,
  }) {
    return ApparenceKitThemeData(
      colors: colors,
      defaultTextTheme: defaultTextStyle,
      materialTheme: ThemeData(
        scaffoldBackgroundColor: colors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: colors.background == const Color(0xFF0F1B35)
              ? Brightness.dark
              : Brightness.light,
        ).copyWith(
          surface: colors.surface,
          onSurface: colors.onSurface,
          primary: colors.primary,
          onPrimary: colors.onPrimary,
          error: colors.error,
        ),
        extensions: const [],
        appBarTheme: AppBarTheme(
          backgroundColor: colors.background,
          foregroundColor: colors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        elevatedButtonTheme: _elevatedButtonTheme(colors, defaultTextStyle),
        inputDecorationTheme: _inputDecorationTheme(colors, defaultTextStyle),
        textTheme: _textTheme(colors, defaultTextStyle),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: colors.surface,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.grey2,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: colors.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: colors.divider,
          thickness: 1,
          space: 1,
        ),
        cardTheme: CardTheme(
          color: colors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.grey1),
          ),
        ),
      ),
    );
  }

  ElevatedButtonThemeData _elevatedButtonTheme(
      ApparenceKitColors colors,
      ApparenceKitTextTheme textTheme,
      ) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          foregroundColor: colors.onPrimary,
          backgroundColor: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.primary.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      );

  InputDecorationTheme _inputDecorationTheme(
      ApparenceKitColors colors,
      ApparenceKitTextTheme textTheme,
      ) =>
      InputDecorationTheme(
        fillColor: colors.surface,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.grey1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        hintStyle: textTheme.primary.copyWith(
          color: colors.grey2,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: textTheme.primary.copyWith(color: colors.grey2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      );

  TextTheme _textTheme(
      ApparenceKitColors colors,
      ApparenceKitTextTheme t,
      ) =>
      TextTheme(
        displayLarge: t.displayLarge.copyWith(color: colors.onBackground),
        displayMedium: t.displayMedium.copyWith(color: colors.onBackground),
        displaySmall: t.displaySmall.copyWith(color: colors.onBackground),
        headlineLarge: t.headlineLarge.copyWith(color: colors.onBackground),
        headlineMedium: t.headlineMedium.copyWith(color: colors.onBackground),
        headlineSmall: t.headlineSmall.copyWith(color: colors.onBackground),
        titleLarge: t.titleLarge.copyWith(color: colors.onBackground),
        titleMedium: t.titleMedium.copyWith(color: colors.onBackground),
        titleSmall: t.titleSmall.copyWith(color: colors.grey3),
        bodyLarge: t.bodyLarge.copyWith(color: colors.onBackground),
        bodyMedium: t.bodyMedium.copyWith(color: colors.onBackground),
        bodySmall: t.bodySmall.copyWith(color: colors.grey3),
        labelLarge: t.labelLarge.copyWith(color: colors.onBackground),
        labelMedium: t.labelMedium.copyWith(color: colors.grey3),
        labelSmall: t.labelSmall.copyWith(color: colors.grey2),
      );
}