import 'package:flutter/material.dart';

import '../../../core/i18n/translations.g.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🚧', style: TextStyle(fontSize: 72)),
              SizedBox(height: 24),
              Text(
                t.booking.disabledTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 12),
              Text(
                t.booking.disabledSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9EA3AE),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}