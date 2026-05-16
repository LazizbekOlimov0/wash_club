import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/theme/texts.dart';
import 'package:wash_club/core/theme/theme_data/theme_data.dart';

abstract class ApparenceKitThemeDataFactory {
  const ApparenceKitThemeDataFactory();

  ApparenceKitThemeData build({
    required ApparenceKitColors colors,
    required ApparenceKitTextTheme defaultTextStyle,
  });
}