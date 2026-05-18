import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/theme/providers/apparencekit_theme.dart';
import 'package:wash_club/core/theme/texts.dart';
import 'package:wash_club/core/theme/theme_data/theme_data_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends InheritedNotifier<AppTheme> {
  const ThemeProvider({super.key, super.notifier, required super.child});

  @override
  bool updateShouldNotify(covariant ThemeProvider oldWidget) {
    return oldWidget.notifier != notifier;
  }

  static AppTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!.notifier!;
}

class AppTheme with ChangeNotifier {
  final AppearanceKitTheme? lightTheme;
  final AppearanceKitTheme? darkTheme;
  late SharedPreferences _prefs;
  ThemeMode mode;

  AppTheme({
    required this.mode,
    this.lightTheme,
    this.darkTheme,
  });

  /// Call this after construction to load saved theme
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    mode = _loadFromPrefs();
    setSystemBarColor();
    notifyListeners();
  }

  factory AppTheme.uniform({
    ApparenceKitColors? lightColors,
    ApparenceKitColors? darkColors,
    required ApparenceKitTextTheme textTheme,
    required ApparenceKitThemeDataFactory themeFactory,
    required ThemeMode defaultMode,
  }) {
    return AppTheme(
      mode: defaultMode,
      lightTheme: lightColors != null
          ? AppearanceKitThemeUniform(
        themeFactory.build(
          colors: lightColors,
          defaultTextStyle: textTheme,
        ),
      )
          : null,
      darkTheme: darkColors != null
          ? AppearanceKitThemeUniform(
        themeFactory.build(
          colors: darkColors,
          defaultTextStyle: textTheme,
        ),
      )
          : null,
    );
  }

  factory AppTheme.adaptive({
    required ApparenceKitTextTheme defaultTextTheme,
    required ThemeMode mode,
    ApparenceKitColors? lightColors,
    ApparenceKitColors? darkColors,
    ApparenceKitThemeDataFactory? ios,
    ApparenceKitThemeDataFactory? android,
    ApparenceKitThemeDataFactory? web,
  }) {
    return AppTheme(
      mode: mode,
      lightTheme: lightColors != null
          ? AppearanceKitThemeAdaptive(
        ios: ios?.build(
          colors: lightColors,
          defaultTextStyle: defaultTextTheme,
        ),
        android: android?.build(
          colors: lightColors,
          defaultTextStyle: defaultTextTheme,
        ),
        web: web?.build(
          colors: lightColors,
          defaultTextStyle: defaultTextTheme,
        ),
      )
          : null,
      darkTheme: darkColors != null
          ? AppearanceKitThemeAdaptive(
        ios: ios?.build(
          colors: darkColors,
          defaultTextStyle: defaultTextTheme,
        ),
        android: android?.build(
          colors: darkColors,
          defaultTextStyle: defaultTextTheme,
        ),
        web: web?.build(
          colors: darkColors,
          defaultTextStyle: defaultTextTheme,
        ),
      )
          : null,
    );
  }

  void toggle() {
    mode = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveInPrefs(mode);
    notifyListeners();
    setSystemBarColor();
  }

  void setMode(ThemeMode newMode) {
    mode = newMode;
    _saveInPrefs(mode);
    notifyListeners();
    setSystemBarColor();
  }

  void setSystemBarColor() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    final isDark = mode == ThemeMode.system
        ? brightness == Brightness.dark
        : mode == ThemeMode.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness:
        isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  ThemeData get dark {
    if (darkTheme == null) throw Exception('Dark theme is not defined');
    return darkThemeData.copyWith(
      brightness: Brightness.dark,
      extensions: [darkTheme!.colors, darkTheme!.textTheme],
    );
  }

  ThemeData get light {
    if (lightTheme == null) throw Exception('Light theme is not defined');
    return lightThemeData.copyWith(
      brightness: Brightness.light,
      extensions: [lightTheme!.colors, lightTheme!.textTheme],
    );
  }

  ThemeData get lightThemeData => lightTheme!.data.materialTheme;
  ThemeData get darkThemeData => darkTheme!.data.materialTheme;

  AppearanceKitTheme get current {
    if (mode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;

      return brightness == Brightness.dark
          ? darkTheme!
          : lightTheme!;
    }

    return mode == ThemeMode.light
        ? lightTheme!
        : darkTheme!;
  }

  ThemeMode _loadFromPrefs() {
    final saved = _prefs.getString('themeMode');

    switch (saved) {
      case 'light':
        return ThemeMode.light;

      case 'dark':
        return ThemeMode.dark;

      case 'system':
        return ThemeMode.system;

      default:
        return mode;
    }
  }

  void _saveInPrefs(ThemeMode themeMode) {
    _prefs.setString('themeMode', themeMode.name);
  }
}