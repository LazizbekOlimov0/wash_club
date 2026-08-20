import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import 'supabase_service.dart';

/// Foydalanuvchi sessiyasini boshqaruvchi servis.
/// 
/// Ilova login talab qilmaydi — foydalanuvchi nomi va telefoni kiritilgach,
/// ular SharedPreferences'ga saqlanadi va barcha so'rovlarda ishlatiladi.
/// car_number buyurtmalar uchun asosiy identifikator hisoblanadi.
class ClientSession {
  ClientSession._();
  static final ClientSession instance = ClientSession._();

  // in-memory cache
  String? _userId;   // local UUID (anon identifier)
  String? _customerId; // server-side customer UUID (OTP login)
  String? _name;
  String? _phone;
  String? _password;
  String? _profileImage; // base64 encoded
  String? _telegramChatId; // Telegram chat_id for QR notifications
  List<SavedCar> _cars = [];

  bool get isOnboarded =>
      _name != null && _phone != null && (_password != null || _customerId != null);
  String? get profileImage => _profileImage;
  bool get isRegistered => _phone != null && (_password != null || _customerId != null);
  String? get customerId => _customerId;

  String get userId {
    assert(_userId != null, 'Session not initialised');
    return _userId!;
  }

  String? get name  => _name;
  String? get phone => _phone;
  String? get telegramChatId => _telegramChatId;
  List<SavedCar> get cars => List.unmodifiable(_cars);

  SavedCar? get primaryCar => _cars.isEmpty ? null : _cars.first;

  // ── Init ──────────────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Ensure a stable local user ID
    _userId = prefs.getString(AppConstants.kClientUserId);
    if (_userId == null) {
      _userId = const Uuid().v4();
      await prefs.setString(AppConstants.kClientUserId, _userId!);
    }

    _customerId = prefs.getString(AppConstants.kClientCustomerId);
    _name     = prefs.getString(AppConstants.kClientName);
    _phone    = prefs.getString(AppConstants.kClientPhone);
    _password     = prefs.getString(AppConstants.kClientPassword);
    _profileImage = prefs.getString(AppConstants.kClientProfileImage);
    _telegramChatId = prefs.getString(AppConstants.kClientTelegramChatId);

    final carsJson = prefs.getString(AppConstants.kClientCars);
    if (carsJson != null) {
      final list = jsonDecode(carsJson) as List<dynamic>;
      _cars = list.map((e) => SavedCar.fromJson(e as Map<String, dynamic>)).toList();
    }

    // Login qilingan bo'lsa — mashinalar backend'dan yuklanadi
    if (_customerId != null) {
      await loadCars();
    }
  }

  // ── Save profile from OTP (Telegram login) ────────────
  Future<void> saveFromOtp({
    required String customerId,
    required String phone,
    required String name,
  }) async {
    _customerId = customerId;
    _name  = name;
    _phone = phone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kClientCustomerId, customerId);
    await prefs.setString(AppConstants.kClientName,       name);
    await prefs.setString(AppConstants.kClientPhone,      phone);
    await loadCars();
  }

  // ── Save profile (register) ──────────────────────────────
  Future<void> saveProfile({
    required String name,
    required String phone,
    String? password,
  }) async {
    _name  = name;
    _phone = phone;
    if (password != null) _password = password;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kClientName,     name);
    await prefs.setString(AppConstants.kClientPhone,    phone);
    if (password != null) {
      await prefs.setString(AppConstants.kClientPassword, password);
    }
  }

  bool verifyPassword(String phone, String password) {
    return _phone == phone && _password == password;
  }

  Future<void> saveProfileImage(String base64Image) async {
    _profileImage = base64Image;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kClientProfileImage, base64Image);
  }

  Future<void> saveTelegramChatId(String chatId) async {
    _telegramChatId = chatId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kClientTelegramChatId, chatId);
  }

  Future<void> removeProfileImage() async {
    _profileImage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.kClientProfileImage);
  }

  // ── Cars ──────────────────────────────────────────────────
  /// Mashinalarni backend'dan yuklash (login qilingan foydalanuvchi uchun).
  Future<void> loadCars() async {
    if (_customerId == null && _phone == null) {
      _cars = [];
      return;
    }
    try {
      final list = await SupabaseService.instance.getMyCars(
        customerId: _customerId,
        phone: _phone,
      );
      _cars = list.map(_carModelToSaved).toList();
    } catch (_) {
      // Offline yoki xatolik — lokal cache qoladi
    }
  }

  SavedCar _carModelToSaved(CarModel c) => SavedCar(
        id: c.id,
        plate: c.plate,
        brand: c.brand,
        model: c.model,
        bodyType: c.category,
        color: c.color,
      );

  Future<void> addCar(SavedCar car) async {
    final customerId = _customerId;
    if (customerId == null) {
      // Guest mode — lokal saqlash
      _cars.removeWhere((c) => c.plate == car.plate);
      _cars.insert(0, car);
      await _persistCars();
      return;
    }

    final created = await SupabaseService.instance.addCar(
      customerId: customerId,
      phone: _phone,
      brand: car.brand,
      model: car.model,
      plate: car.plate,
      color: car.color,
      category: car.vehicleCategory,
    );
    if (created == null) {
      throw Exception('Car save failed');
    }
    final saved = _carModelToSaved(created);
    _cars.removeWhere((c) => c.plate == saved.plate);
    _cars.insert(0, saved);
  }

  Future<void> removeCar(SavedCar car) async {
    if (_customerId != null && car.id.isNotEmpty) {
      await SupabaseService.instance.removeCar(car.id);
    }
    _cars.removeWhere(
        (c) => c.id == car.id || (c.id.isEmpty && c.plate == car.plate));
    if (_customerId == null) {
      await _persistCars();
    }
  }

  Future<void> _persistCars() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.kClientCars,
      jsonEncode(_cars.map((c) => c.toJson()).toList()),
    );
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> clear() async {
    _customerId = null;
    _name     = null;
    _phone    = null;
    _password     = null;
    _profileImage = null;
    _telegramChatId = null;
    _cars         = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.kClientCustomerId);
    await prefs.remove(AppConstants.kClientName);
    await prefs.remove(AppConstants.kClientPhone);
    await prefs.remove(AppConstants.kClientPassword);
    await prefs.remove(AppConstants.kClientProfileImage);
    await prefs.remove(AppConstants.kClientTelegramChatId);
    await prefs.remove(AppConstants.kClientCars);
    // userId ni saqlaymiz — bu device identifier
  }
}

/// ── Saved Car model ────────────────────────────────────────
class SavedCar {
  final String id;        // backend UUID ('' = lokal/guest)
  final String plate;
  final String brand;
  final String model;
  final String bodyType;   // sedan | suv | minivan | others
  final String color;

  const SavedCar({
    this.id = '',
    required this.plate,
    required this.brand,
    required this.model,
    required this.bodyType,
    this.color = '',
  });

  /// vehicle_category: supabase faqat sedan|suv|minivan biladi
  String get vehicleCategory {
    switch (bodyType.toLowerCase()) {
      case 'suv':     return 'suv';
      case 'minivan': return 'minivan';
      default:        return 'sedan';
    }
  }

  String get displayName {
    final parts = [brand, model].where((s) => s.isNotEmpty).join(' ');
    return parts.isEmpty ? plate : parts;
  }

  Map<String, dynamic> toJson() => {
    'id':        id,
    'plate':     plate,
    'brand':     brand,
    'model':     model,
    'bodyType':  bodyType,
    'color':     color,
  };

  factory SavedCar.fromJson(Map<String, dynamic> j) => SavedCar(
    id:       j['id'] as String? ?? '',
    plate:    j['plate'] as String,
    brand:    j['brand'] as String? ?? '',
    model:    j['model'] as String? ?? '',
    bodyType: j['bodyType'] as String? ?? 'sedan',
    color:    j['color'] as String? ?? '',
  );

  @override
  String toString() => 'SavedCar($plate, $brand $model)';
}
