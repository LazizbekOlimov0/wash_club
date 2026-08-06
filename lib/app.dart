import 'package:flutter/material.dart';
import 'package:wash_club/core/i18n/translations.g.dart';
import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/theme/providers/theme_provider.dart';
import 'package:wash_club/core/theme/texts.dart';
import 'package:wash_club/core/theme/universal_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/router/router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppTheme _appTheme;

  @override
  void initState() {
    super.initState();
    const factory = UniversalThemeFactory();
    final textTheme = ApparenceKitTextTheme.build();

    _appTheme = AppTheme.uniform(
      defaultMode: ThemeMode.light,
      textTheme: textTheme,
      themeFactory: factory,
      lightColors: ApparenceKitColors.light(),
      darkColors: ApparenceKitColors.dark(),
    );

    _appTheme.init();
  }

  @override
  void dispose() {
    _appTheme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      notifier: _appTheme,
      child: TranslationProvider(
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = ThemeProvider.of(context);
    return AnimatedBuilder(
      animation: appTheme,
      builder: (context, _) {
        return MaterialApp.router(
          theme: appTheme.light,
          darkTheme: appTheme.dark,
          themeMode: appTheme.mode,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: generateRouter,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}