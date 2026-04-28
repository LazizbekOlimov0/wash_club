import 'package:flutter/material.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🚧', style: TextStyle(fontSize: 72)),
              SizedBox(height: 24),
              Text(
                "Bron qilish vaqtincha to'xtatilgan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Hozirda bron qilish imkoniyati mavjud emas. Tez orada qayta ishga tushiriladi!',
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