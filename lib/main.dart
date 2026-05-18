import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wash_club/core/i18n/translations.g.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Saved language
  final savedLocale = prefs.getString('locale');

  if (savedLocale != null) {
    await LocaleSettings.setLocaleRaw(savedLocale);
  } else {
    await LocaleSettings.setLocaleRaw('uz');
  }

  runApp(const MyApp());
}