import 'package:flutter/material.dart';
import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/theme/texts.dart';

class ApparenceKitThemeData {
  final ApparenceKitColors colors;
  final ApparenceKitTextTheme defaultTextTheme;
  final ThemeData materialTheme;

  const ApparenceKitThemeData({
    required this.colors,
    required this.defaultTextTheme,
    required this.materialTheme,
  });
}