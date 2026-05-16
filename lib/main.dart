import 'package:flutter/material.dart';
import 'package:wash_club/core/i18n/translations.g.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.setLocaleRaw('uz');
  runApp(const MyApp());
}
