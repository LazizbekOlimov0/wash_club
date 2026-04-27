import 'package:flutter/material.dart';
import 'package:wash_club/common/auth/presentation/screen/auth_screen.dart';
import 'package:wash_club/common/auth/presentation/screen/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}
