import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/theme/texts.dart';
import 'package:wash_club/core/theme/theme_data/theme_data.dart';

sealed class ApparenceKitTheme {
  const ApparenceKitTheme();

  ApparenceKitColors get colors;
  ApparenceKitTextTheme get textTheme;
  ApparenceKitThemeData get data;
}

class ApparenceKitThemeUniform extends ApparenceKitTheme {
  const ApparenceKitThemeUniform(this.data);

  @override
  final ApparenceKitThemeData data;

  @override
  ApparenceKitColors get colors => data.colors;

  @override
  ApparenceKitTextTheme get textTheme => data.defaultTextTheme;
}

class ApparenceKitThemeAdaptive extends ApparenceKitTheme {
  final ApparenceKitThemeData? ios;
  final ApparenceKitThemeData? android;
  final ApparenceKitThemeData? web;

  const ApparenceKitThemeAdaptive({this.ios, this.android, this.web});

  @override
  ApparenceKitColors get colors {
    if (Platform.isIOS) return ios!.colors;
    if (Platform.isAndroid) return android!.colors;
    return web!.colors;
  }

  @override
  ApparenceKitTextTheme get textTheme {
    if (Platform.isIOS) return ios!.defaultTextTheme;
    if (Platform.isAndroid) return android!.defaultTextTheme;
    return web!.defaultTextTheme;
  }

  @override
  ApparenceKitThemeData get data {
    if (Platform.isIOS) return ios!;
    if (Platform.isAndroid) return android!;
    return web!;
  }
}