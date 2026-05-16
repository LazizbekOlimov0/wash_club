import 'dart:io' show Platform;
import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/theme/texts.dart';
import 'package:wash_club/core/theme/theme_data/theme_data.dart';

sealed class AppearanceKitTheme {
  const AppearanceKitTheme();

  ApparenceKitColors get colors;
  ApparenceKitTextTheme get textTheme;
  ApparenceKitThemeData get data;
}

class AppearanceKitThemeUniform extends AppearanceKitTheme {
  const AppearanceKitThemeUniform(this.data);

  @override
  final ApparenceKitThemeData data;

  @override
  ApparenceKitColors get colors => data.colors;

  @override
  ApparenceKitTextTheme get textTheme => data.defaultTextTheme;
}

class AppearanceKitThemeAdaptive extends AppearanceKitTheme {
  final ApparenceKitThemeData? ios;
  final ApparenceKitThemeData? android;
  final ApparenceKitThemeData? web;

  const AppearanceKitThemeAdaptive({this.ios, this.android, this.web});

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