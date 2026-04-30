import 'package:flutter/material.dart';
import 'package:wash_club/core/i18n/translations.g.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/router/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.setLocaleRaw('uz'); // default locale
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: generateRouter,
    );
  }
}