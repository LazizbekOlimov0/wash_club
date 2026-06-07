/// Supabase va app uchun barcha konstantalar
class AppConstants {
  AppConstants._();

  // ── Supabase ──────────────────────────────────────────────
  static const String supabaseUrl =
      'https://sfjaahjvyikoesaruavl.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNmamFhaGp2eWlrb2VzYXJ1YXZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg3NDE0NTksImV4cCI6MjA4NDMxNzQ1OX0'
      '.QJdnkO5V0-0dc9gBoTl1wckbt6ykKIYwrOuWb5deBi0';

  // ── Google OAuth ──────────────────────────────────────────
  static const String googleServerClientId =
      '565322626454-ikd1isvlucko712vr7bcp01lo1kvlh1d.apps.googleusercontent.com';
  static const String googleIOSClientId =
      '565322626454-lhdd6lu93ufa430qqi33i23bjfj2ijv7.apps.googleusercontent.com';

  // ── SharedPreferences keys ────────────────────────────────
  static const String kLocale        = 'locale';
  static const String kOnboardingDone = 'onboarding_done';
  static const String kClientUserId  = 'client_user_id';   // local UUID for anon user
  static const String kClientCustomerId = 'client_customer_id'; // server-side customer UUID
  static const String kClientPhone   = 'client_phone';
  static const String kClientName    = 'client_name';
  static const String kClientCars    = 'client_cars';       // JSON list
  static const String kClientPassword = 'client_password';
  static const String kClientProfileImage = 'client_profile_image';

  // ── Order source ──────────────────────────────────────────
  static const String orderSourceClientApp = 'by_client_app';
  static const String orderSourceByPlace   = 'by_place';

  // ── Order statuses ────────────────────────────────────────
  static const String statusPending   = 'pending';
  static const String statusWashing   = 'washing';
  static const String statusReady     = 'ready';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // ── Payment methods ───────────────────────────────────────
  static const String paymentCash  = 'cash';
  static const String paymentCard  = 'card';
  static const String paymentClick = 'click';
  static const String paymentPayme = 'payme';

  // ── Vehicle categories ────────────────────────────────────
  static const String vehicleSedan   = 'sedan';
  static const String vehicleSuv     = 'suv';
  static const String vehicleMinivan = 'minivan';
}