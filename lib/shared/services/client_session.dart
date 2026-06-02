import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';

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
  String? _name;
  String? _phone;
  String? _password;
  String? _profileImage; // base64 encoded
  List<SavedCar> _cars = [];

  bool get isOnboarded => _name != null && _phone != null && _password != null;
  String? get profileImage => _profileImage;
  bool get isRegistered => _phone != null && _password != null;

  String get userId {
    assert(_userId != null, 'Session not initialised');
    return _userId!;
  }

  String? get name  => _name;
  String? get phone => _phone;
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

    _name     = prefs.getString(AppConstants.kClientName);
    _phone    = prefs.getString(AppConstants.kClientPhone);
    _password     = prefs.getString(AppConstants.kClientPassword);
    _profileImage = prefs.getString(AppConstants.kClientProfileImage);

    final carsJson = prefs.getString(AppConstants.kClientCars);
    if (carsJson != null) {
      final list = jsonDecode(carsJson) as List<dynamic>;
      _cars = list.map((e) => SavedCar.fromJson(e as Map<String, dynamic>)).toList();
    }
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

  Future<void> removeProfileImage() async {
    _profileImage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.kClientProfileImage);
  }

  // ── Cars ──────────────────────────────────────────────────
  Future<void> addCar(SavedCar car) async {
    // Duplicate plate check
    _cars.removeWhere((c) => c.plate == car.plate);
    _cars.insert(0, car);
    await _persistCars();
  }

  Future<void> removeCar(String plate) async {
    _cars.removeWhere((c) => c.plate == plate);
    await _persistCars();
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
    _name     = null;
    _phone    = null;
    _password     = null;
    _profileImage = null;
    _cars         = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.kClientName);
    await prefs.remove(AppConstants.kClientPhone);
    await prefs.remove(AppConstants.kClientPassword);
    await prefs.remove(AppConstants.kClientProfileImage);
    await prefs.remove(AppConstants.kClientCars);
    // userId ni saqlaymiz — bu device identifier
  }
}

/// ── Saved Car model ────────────────────────────────────────
class SavedCar {
  final String plate;
  final String brand;
  final String model;
  final String bodyType;   // sedan | suv | minivan | others
  final String color;

  const SavedCar({
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

  String get displayName => '$brand $model'.trim().isEmpty ? plate : '$brand $model';

  Map<String, dynamic> toJson() => {
    'plate':     plate,
    'brand':     brand,
    'model':     model,
    'bodyType':  bodyType,
    'color':     color,
  };

  factory SavedCar.fromJson(Map<String, dynamic> j) => SavedCar(
    plate:    j['plate'] as String,
    brand:    j['brand'] as String? ?? '',
    model:    j['model'] as String? ?? '',
    bodyType: j['bodyType'] as String? ?? 'sedan',
    color:    j['color'] as String? ?? '',
  );

  @override
  String toString() => 'SavedCar($plate, $brand $model)';
}
