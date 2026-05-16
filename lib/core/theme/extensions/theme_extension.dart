import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/theme/providers/theme_provider.dart';
import 'package:wash_club/core/theme/theme_data/theme_data.dart';
import 'package:flutter/material.dart';

extension ApparenceKitThemeExt on BuildContext {
  ApparenceKitColors get colors =>
      Theme.of(this).extension<ApparenceKitColors>()!;

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  ThemeData get theme => Theme.of(this);

  Brightness get brightness => Theme.of(this).brightness;

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;

  ApparenceKitThemeData get kitTheme => ThemeProvider.of(this).current.data;
}