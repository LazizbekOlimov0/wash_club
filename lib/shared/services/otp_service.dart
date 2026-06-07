import 'package:supabase_flutter/supabase_flutter.dart';

/// Telegram bot orqali OTP autentifikatsiya servisi.
///
/// Supabase edge function'larni chaqiradi:
/// - `otp-request`  → kod generatsiya qilish va Telegram'ga yuborish
/// - `otp-verify`   → kiritilgan kodni tekshirish va customer yaratish/topish
class OtpService {
  OtpService._();
  static final OtpService instance = OtpService._();

  SupabaseClient get _client => Supabase.instance.client;

  static const _botUsername = 'washclub_bot';

  /// Telegram bot linkini ochish uchun URL.
  static String botVerifyUrl(String phone) =>
      'https://t.me/$_botUsername?start=verify_${Uri.encodeComponent(phone)}';

  /// Telefon raqamga OTP kod so'rash.
  ///
  /// Agar foydalanuvchi Telegram botga kirib raqamini jo'natgan bo'lsa,
  /// kod to'g'ridan-to'g'ri Telegram'ga yuboriladi.
  /// Aks holda `needs_bot_link: true` va `bot_url` qaytariladi.
  Future<OtpRequestResult> requestOtp(String phone) async {
    final response = await _client.functions.invoke(
      'otp-request',
      body: {'phone': phone, 'channel': 'telegram'},
    );

    final data = response.data;
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
}

class OtpRequestResult {
  final bool ok;
  final bool needsBotLink;
  final String? botUrl;
  final String? error;

  const OtpRequestResult({
    required this.ok,
    this.needsBotLink = false,
    this.botUrl,
    this.error,
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
