import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Telegram bot orqali autentifikatsiya servisi.
///
/// Supabase edge function'larni chaqiradi:
/// - `otp-request`  → kod generatsiya qilish va Telegram'ga yuborish
/// - `otp-verify`   → kiritilgan kodni tekshirish va customer yaratish/topish
/// - `customer-by-phone` → telefon raqam orqali customer ma'lumotlarini olish
class OtpService {
  OtpService._();
  static final OtpService instance = OtpService._();

  SupabaseClient get _client => Supabase.instance.client;

  static const _botUsername = 'washclub_bot';

  static String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('+')) return digits;
    if (digits.startsWith('998')) return '+$digits';
    if (digits.length == 9) return '+998$digits';
    return digits;
  }

  /// Telegram bot linki.
  static String get botUrl => 'https://t.me/$_botUsername';

  /// Yangi login token yaratish va Telegram bot linkini olish.
  Future<String> createLoginToken(String phone) async {
    final normalized = _normalizePhone(phone);
    final token = _generateToken();
    debugPrint('[OtpService] createLoginToken phone=$normalized token=$token');

    await _client.from('login_requests').insert({
      'phone': normalized,
      'token': token,
      'status': 'pending',
      'expires_at': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
    });

    return token;
  }

  /// Bot login linki (login_TOKEN).
  String botLoginUrl(String token) =>
      'https://t.me/$_botUsername?start=login_$token';

  String _generateToken() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rnd = (now * 1103515245 + 12345) & 0x7fffffff;
    return rnd.toRadixString(16).padLeft(8, '0');
  }

  /// Botda ro'yxatdan o'tgan customer'ni telefon raqam orqali qidirish.
  /// Agar customer topilsa, uning ma'lumotlarini qaytaradi.
  Future<CustomerCheckResult> checkCustomer(String rawPhone) async {
    final phone = _normalizePhone(rawPhone);
    try {
      final response = await _client
          .from('customers')
          .select('id, full_name, phone, car_number, car_model, telegram_chat_id, language')
          .eq('phone', phone)
          .limit(10);

      final customers = (response as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      if (customers.isEmpty) {
        return const CustomerCheckResult(found: false);
      }

      final customer = customers.firstWhere(
        (c) => c['branch_id'] != null,
        orElse: () => customers.first,
      );

      return CustomerCheckResult(
        found: true,
        customerId: customer['id'] as String? ?? '',
        phone: customer['phone'] as String? ?? phone,
        fullName: customer['full_name'] as String? ?? 'Mehmon',
        telegramChatId: customer['telegram_chat_id']?.toString(),
      );
    } catch (e) {
      // RLS bloklasa yoki boshqa xatolik bo'lsa edge function orqali qayta urinish
      try {
        final response = await _client.functions.invoke(
          'customer-by-phone',
          body: {'phone': phone},
        );

        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['found'] == true) {
            return CustomerCheckResult(
              found: true,
              customerId: data['customer_id'] as String,
              phone: data['phone'] as String,
              fullName: data['full_name'] as String? ?? 'Mehmon',
              telegramChatId: data['telegram_chat_id']?.toString(),
            );
          }
          return CustomerCheckResult(
            found: false,
            error: data['error'] as String?,
          );
        }
      } catch (_) {}

      return const CustomerCheckResult(found: false, error: 'unknown_error');
    }
  }

  /// Telefon raqamga OTP kod so'rash.
  ///
  /// Agar foydalanuvchi Telegram botga kirib raqamini jo'natgan bo'lsa,
  /// kod to'g'ridan-to'g'ri Telegram'ga yuboriladi.
  /// Aks holda `needs_bot_link: true` va `bot_url` qaytariladi.
  Future<OtpRequestResult> requestOtp(String phone) async {
    debugPrint('[OtpService] requestOtp invoked for phone: $phone');
    final response = await _client.functions.invoke(
      'otp-request',
      body: {'phone': phone, 'channel': 'telegram'},
    );

    final data = response.data;
    debugPrint('[OtpService] requestOtp response data: $data');
    if (data is Map<String, dynamic>) {
      if (data['error'] != null) {
        return OtpRequestResult(
          ok: false,
          error: data['error'] as String,
        );
      }
      return OtpRequestResult(
        ok: data['ok'] == true,
        needsBotLink: data['needs_bot_link'] == true,
        botUrl: data['bot_url'] as String?,
        testMode: data['test_mode'] == true,
        token: data['token'] as String?,
      );
    }

    return const OtpRequestResult(ok: false, error: 'unknown_error');
  }

  /// OTP kodni tekshirish.
  ///
  /// Muvaffaqiyatli bo'lsa `OtpVerifyResult` qaytaradi
  /// (customer_id, phone, full_name).
  Future<OtpVerifyResult> verifyOtp({
    required String phone,
    required String code,
    String? name,
  }) async {
    final body = <String, dynamic>{
      'phone': phone,
      'code': code,
    };
    if (name != null && name.trim().isNotEmpty) {
      body['name'] = name.trim();
    }

    final response = await _client.functions.invoke(
      'otp-verify',
      body: body,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['ok'] == true) {
        return OtpVerifyResult(
          ok: true,
          customerId: data['customer_id'] as String,
          phone: data['phone'] as String,
          fullName: data['full_name'] as String? ?? 'Mehmon',
        );
      }
      return OtpVerifyResult(
        ok: false,
        error: data['error'] as String?,
        message: data['message'] as String?,
      );
    }

    return const OtpVerifyResult(ok: false, error: 'unknown_error');
  }

  /// Telegram login holatini tekshirish (polling).
  Future<OtpVerifyResult> checkLoginStatus(String token) async {
    try {
      final response = await _client.functions.invoke(
        'login-status',
        body: {'token': token},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final status = data['status'] as String? ?? 'pending';
        if (status == 'approved') {
          return OtpVerifyResult(
            ok: true,
            customerId: data['customer_id'] as String?,
            phone: data['phone'] as String?,
            fullName: data['full_name'] as String?,
          );
        }
        if (status == 'expired') {
          return const OtpVerifyResult(ok: false, error: 'Muddati o\'tgan. Qayta urinib ko\'ring.');
        }
        if (status == 'not_found') {
          return const OtpVerifyResult(ok: false, error: 'Login so\'rovi topilmadi.');
        }
        return const OtpVerifyResult(ok: false);
      }
    } catch (e, st) {
      debugPrint('[checkLoginStatus] error: $e\n$st');
    }

    return const OtpVerifyResult(ok: false);
  }
}

class OtpRequestResult {
  final bool ok;
  final bool needsBotLink;
  final String? botUrl;
  final String? error;
  final bool testMode;
  final String? token;

  const OtpRequestResult({
    required this.ok,
    this.needsBotLink = false,
    this.botUrl,
    this.error,
    this.testMode = false,
    this.token,
  });
}

class OtpVerifyResult {
  final bool ok;
  final String? customerId;
  final String? phone;
  final String? fullName;
  final String? error;
  final String? message;

  const OtpVerifyResult({
    required this.ok,
    this.customerId,
    this.phone,
    this.fullName,
    this.error,
    this.message,
  });
}

class CustomerCheckResult {
  final bool found;
  final String? customerId;
  final String? phone;
  final String? fullName;
  final String? telegramChatId;
  final String? error;

  const CustomerCheckResult({
    required this.found,
    this.customerId,
    this.phone,
    this.fullName,
    this.telegramChatId,
    this.error,
  });

  bool get ok => found;
}
