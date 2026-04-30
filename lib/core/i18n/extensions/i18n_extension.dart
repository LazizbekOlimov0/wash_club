import 'package:flutter/material.dart';
import 'package:wash_club/core/i18n/translations.g.dart';

extension I18NThemeExt on BuildContext {
  Translations get t => Translations.of(this);
}