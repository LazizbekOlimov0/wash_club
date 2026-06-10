import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wash_club/shared/services/promo_service.dart';
import '../constants/app_constants.dart';

/// Supabase bilan barcha muloqot shu yerda.
/// 
/// Mobile app ANON key bilan ishlaydi — auth token shart emas.
/// `source = 'by_client_app'` — server RLS da tekshiriladi.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ─────────────────────────────────────────────────────────
  // BRANCHES
  // ─────────────────────────────────────────────────────────

  /// Faol filiallar ro'yxatini qaytaradi.
  /// Services bilan birga join qilib olamiz.
  Future<List<BranchModel>> getBranches() async {
    final response = await _client
        .from('branches')
        .select('id,name,address,is_active,created_at,latitude,longitude,services(id,name,description,is_active,is_addon,icon,sort_order,duration_minutes,service_prices(vehicle_category,price))')
        .eq('is_active', true)
        .order('name');

    return (response as List<dynamic>)
        .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Bitta filial ma'lumotlari
  Future<BranchModel?> getBranch(String branchId) async {
    final response = await _client
        .from('branches')
        .select('''
          id, name, address, is_active,
          services (
            id, name, description, is_active, is_addon, icon, sort_order, duration_minutes,
            service_prices ( vehicle_category, price )
          )
        ''')
        .eq('id', branchId)
        .maybeSingle();

    if (response == null) return null;
    return BranchModel.fromJson(response as Map<String, dynamic>);
  }

  // ─────────────────────────────────────────────────────────
  // SERVICES
  // ─────────────────────────────────────────────────────────

  /// Bitta filial xizmatlari (narxlari bilan)
  Future<List<ServiceModel>> getServices(String branchId) async {
    final response = await _client
        .from('services')
        .select('id, name, description, is_active, is_addon, icon, sort_order, duration_minutes, service_prices ( vehicle_category, price )')
        .eq('branch_id', branchId)
        .eq('is_active', true)
        .order('sort_order');

    return (response as List<dynamic>)
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────
  // CUSTOMERS  (har buyurtmada upsert qilamiz)
  // ─────────────────────────────────────────────────────────

  /// Telefon va filial bo'yicha customer topish yoki yaratish.
  /// Agar topilmasa — yangi customer yaratiladi.
  Future<CustomerModel> upsertCustomer({
    required String branchId,
    required String fullName,
    required String phone,
    required String carNumber,
    required String carModel,
    required String vehicleCategory,
  }) async {
    // 1) Avval qidirish
    final existing = await _client
        .from('customers')
        .select('id, full_name, phone, car_number, car_model, vehicle_category, total_visits, total_spent')
        .eq('branch_id', branchId)
        .eq('phone', phone)
        .maybeSingle();

    if (existing != null) {
      final id = existing['id'] as String;
      // car ma'lumotlarini yangilaymiz
      await _client.from('customers').update({
        'full_name': fullName,
        'car_number': carNumber,
        'car_model': carModel,
        'vehicle_category': vehicleCategory,
      }).eq('id', id);
      return CustomerModel.fromJson({...existing, 'car_number': carNumber, 'car_model': carModel});
    }

    // 2) Yangi customer
    final inserted = await _client
        .from('customers')
        .insert({
          'branch_id': branchId,
          'full_name': fullName,
          'phone': phone,
          'car_number': carNumber,
          'car_model': carModel,
          'vehicle_category': vehicleCategory,
        })
        .select()
        .single();

    return CustomerModel.fromJson(inserted as Map<String, dynamic>);
  }

  // ─────────────────────────────────────────────────────────
  // ORDERS
  // ─────────────────────────────────────────────────────────

  /// Yangi buyurtma yaratish (client app).
  /// source = 'by_client_app' — RLS da ruxsat berilgan.
  Future<OrderModel> createOrder({
    required String branchId,
    required String serviceId,
    required String carNumber,
    required String carModel,
    required int totalAmount,
    required String paymentMethod,
    String? customerId,
    DateTime? scheduledAt,
    List<String> addonServiceIds = const [],
  }) async {
    final data = <String, dynamic>{
      'branch_id':      branchId,
      'service_id':     serviceId,
      'car_number':     carNumber,
      'car_model':      carModel,
      'total_amount':   totalAmount,
      'payment_method': paymentMethod,
      'source':         AppConstants.orderSourceClientApp,
      'status':         AppConstants.statusQueued,
      'payment_status': AppConstants.statusPending,
    };

    if (customerId != null) data['customer_id'] = customerId;
    if (scheduledAt != null) data['scheduled_at'] = scheduledAt.toIso8601String();

    // Addon services: note olish uchun carModel ga append qilamiz (orders jadvalida addons yo'q)
    // Yoki notes columniga yozamiz agar bor bo'lsa
    if (addonServiceIds.isNotEmpty) {
      data['car_model'] = '$carModel|addons:${addonServiceIds.join(",")}';
    }

    final inserted = await _client
        .from('orders')
        .insert(data)
        .select('''
          id, status, car_number, car_model, total_amount,
          payment_method, payment_status, source,
          scheduled_at, created_at,
          branch_id,
          service_id
        ''')
        .single();

    return OrderModel.fromJson(inserted as Map<String, dynamic>);
  }

  /// Foydalanuvchining buyurtmalari (telefon va car_number bo'yicha)
  Future<List<OrderModel>> getMyOrders({
    required String phone,
    required List<String> carNumbers,
  }) async {
    if (carNumbers.isEmpty) return [];

    // Car numbers bo'yicha qidirish
    final response = await _client
        .from('orders')
        .select('''
          id, status, car_number, car_model, total_amount,
          payment_method, payment_status, source,
          scheduled_at, created_at, completed_at,
          branch_id,
          service_id,
          branches ( name, address ),
          services ( name, description )
        ''')
        .eq('source', AppConstants.orderSourceClientApp)
        .inFilter('car_number', carNumbers)
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List<dynamic>)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Buyurtmani bekor qilish — RPC orqali (SECURITY DEFINER).
  Future<OrderModel> cancelOrder(String orderId) async {
    final response = await _client.rpc(
      'cancel_order',
      params: {'p_order_id': orderId},
    );

    if (response == null) {
      throw Exception('Buyurtma topilmadi yoki allaqachon bajarilgan');
    }

    final data = response as Map<String, dynamic>;
    if (data['error'] != null) {
      throw Exception(data['error'] as String);
    }

    return OrderModel.fromJson(data);
  }

  /// Bitta buyurtma holati
  Future<OrderModel?> getOrder(String orderId) async {
    final response = await _client
        .from('orders')
        .select('''
          id, status, car_number, car_model, total_amount,
          payment_method, payment_status, source,
          scheduled_at, created_at, completed_at,
          branches ( name, address ),
          services ( name, description )
        ''')
        .eq('id', orderId)
        .maybeSingle();

    if (response == null) return null;
    return OrderModel.fromJson(response as Map<String, dynamic>);
  }

  /// Berilgan sana va filial uchun band qilingan vaqtlarni qaytaradi.
  /// Format: ['09:00', '10:30', ...]
  Future<List<String>> getBookedTimeSlots({
    required String branchId,
    required DateTime date,
  }) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final response = await _client
        .from('orders')
        .select('scheduled_at')
        .eq('branch_id', branchId)
        .gte('scheduled_at', dayStart.toIso8601String())
        .lt('scheduled_at', dayEnd.toIso8601String())
        .neq('status', 'cancelled');

    final slots = <String>{};
    for (final row in response as List<dynamic>) {
      final scheduledAt = row['scheduled_at'] as String?;
      if (scheduledAt != null) {
        final dt = DateTime.parse(scheduledAt);
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        slots.add('$hour:$minute');
      }
    }
    return slots.toList();
  }

  /// Real-time — buyurtma statusini kuzatish
  RealtimeChannel watchOrderStatus({
    required String orderId,
    required void Function(OrderModel order) onUpdate,
  }) {
    return _client
        .channel('order-$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: orderId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            onUpdate(OrderModel.fromJson(data));
          },
        )
        .subscribe();
  }

  // ─────────────────────────────────────────────────────────
  // SUBSCRIPTIONS  (membership / obuna)
  // ─────────────────────────────────────────────────────────

  /// Foydalanuvchining aktiv obunasini qaytaradi
  Future<SubscriptionModel?> getActiveSubscription(String customerId) async {
    final response = await _client
        .from('subscriptions')
        .select('id, name, price, total_washes, washes_used, starts_at, expires_at, is_active')
        .eq('customer_id', customerId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return SubscriptionModel.fromJson(response as Map<String, dynamic>);
  }

  /// Foydalanuvchining barcha obunalarini qaytaradi
  Future<List<SubscriptionModel>> getSubscriptions(String customerId) async {
    final response = await _client
        .from('subscriptions')
        .select('id, name, price, total_washes, washes_used, starts_at, expires_at, is_active')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Obuna sotib olish so‘rovi yaratish (chek yuklash)
  Future<void> createMembershipPayment({
    required String customerId,
    required String planName,
    required int planPrice,
    required int totalWashes,
    required String receiptUrl,
    String? branchId,
    int durationMonths = 1,
  }) async {
    await _client.from('membership_payments').insert({
      'customer_id': customerId,
      'branch_id': branchId,
      'plan_name': planName,
      'plan_price': planPrice,
      'total_washes': totalWashes,
      'receipt_url': receiptUrl,
      'status': 'pending',
      'duration_months': durationMonths,
    });
  }

  /// Promo kodni backend orqali tekshirish (validate_promo RPC)
  Future<PromoResult> validatePromo(String code, int total) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return const PromoResult.invalid();
    try {
      final response = await _client.rpc(
        'validate_promo',
        params: {'_code': trimmed},
      );
      final rows = response as List<dynamic>?;
      if (rows == null || rows.isEmpty) return const PromoResult.invalid();
      final row = rows[0] as Map<String, dynamic>;
      final percent = row['discount_percent'] as int;
      final discount = (total * percent / 100).round();
      return PromoResult(
        ok: true,
        discount: discount,
        total: (total - discount).clamp(0, total),
        label: row['label'] as String,
      );
    } catch (e) {
      return const PromoResult.invalid();
    }
  }

  // ─────────────────────────────────────────────────────────
  // TARIFF PLANS
  // ─────────────────────────────────────────────────────────

  /// Tarif rejalar ro'yxatini qaytaradi
  Future<List<TariffPlanModel>> getTariffPlans() async {
    final response = await _client
        .from('tariff_plans')
        .select('id, name, duration_months, total_washes, price, per_month_price, emoji, is_popular, sort_order')
        .eq('is_active', true)
        .order('sort_order');

    return (response as List<dynamic>)
        .map((e) => TariffPlanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────
  // SLOT AVAILABILITY
  // ─────────────────────────────────────────────────────────

  /// Berilgan filial va sana uchun band qilingan slotlar sonini qaytaradi.
  /// Returns: Map<"HH:mm", count>
  Future<Map<String, int>> getSlotCounts({
    required String branchId,
    required DateTime date,
  }) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await _client.rpc(
      'get_slot_counts',
      params: {
        '_branch_id': branchId,
        '_date': dateStr,
      },
    );

    final rows = response as List<dynamic>? ?? [];
    final map = <String, int>{};
    for (final row in rows) {
      final r = row as Map<String, dynamic>;
      final slotTime = r['slot_time'] as String;
      final count = r['booked_count'] as int? ?? 0;
      // Parse HH:mm from ISO timestamp
      final dt = DateTime.parse(slotTime);
      final hhmm = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      map[hhmm] = (map[hhmm] ?? 0) + count;
    }
    return map;
  }

  // ─────────────────────────────────────────────────────────
  // CUSTOMER PROFILE UPDATE
  // ─────────────────────────────────────────────────────────

  /// Mijoz profilini yangilash (name, language)
  Future<void> updateCustomerProfile({
    required String customerId,
    String? fullName,
    String? language,
  }) async {
    await _client.rpc(
      'update_customer_profile',
      params: {
        '_customer_id': customerId,
        if (fullName != null) '_full_name': fullName,
        if (language != null) '_language': language,
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // ORDER CANCEL (client-side direct UPDATE)
  // ─────────────────────────────────────────────────────────

  /// Mijoz o'zi buyurtmani bekor qilishi.
  /// Faqat 'pending_payment' yoki 'queue' statusidagi orderlar uchun.
  Future<void> cancelMyOrder(String orderId) async {
    await _client
        .from('orders')
        .update({
          'status': 'cancelled',
          'payment_status': 'cancelled',
        })
        .eq('id', orderId)
        .eq('source', AppConstants.orderSourceClientApp);
  }
}

// ─────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────

class BranchModel {
  final String id;
  final String name;
  final String address;
  final bool isActive;
  final double? latitude;
  final double? longitude;
  final List<ServiceModel> services;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.isActive,
    required this.services,
    this.latitude,
    this.longitude,
  });

  factory BranchModel.fromJson(Map<String, dynamic> j) {
    final rawServices = j['services'];
    final services = rawServices is List<dynamic>
        ? rawServices.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList()
        : <ServiceModel>[];

    return BranchModel(
      id:        j['id'] as String,
      name:      j['name'] as String,
      address:   j['address'] as String? ?? '',
      isActive:  j['is_active'] as bool? ?? true,
      latitude:    (j['latitude'] as num?)?.toDouble(),
      longitude:   (j['longitude'] as num?)?.toDouble(),
      services:    services,
    );
  }
}

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final bool isAddon;
  final String icon;
  final int sortOrder;
  final int? durationMinutes;
  final Map<String, int> prices; // vehicle_category → price

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isAddon,
    required this.icon,
    required this.sortOrder,
    required this.prices,
    this.durationMinutes,
  });

  int priceFor(String vehicleCategory) =>
      prices[vehicleCategory] ?? prices['sedan'] ?? 0;

  factory ServiceModel.fromJson(Map<String, dynamic> j) {
    final rawPrices = j['service_prices'];
    final prices = <String, int>{};
    if (rawPrices is List<dynamic>) {
      for (final p in rawPrices) {
        final pm = p as Map<String, dynamic>;
        prices[pm['vehicle_category'] as String] = pm['price'] as int;
      }
    }

    return ServiceModel(
      id:          j['id'] as String,
      name:        j['name'] as String,
      description: j['description'] as String? ?? '',
      isAddon:     j['is_addon'] as bool? ?? false,
      icon:        j['icon'] as String? ?? '✨',
      sortOrder:   j['sort_order'] as int? ?? 0,
      prices:      prices,
      durationMinutes: j['duration_minutes'] as int?,
    );
  }
}

class CustomerModel {
  final String id;
  final String fullName;
  final String phone;
  final String carNumber;
  final int totalVisits;
  final int totalSpent;

  const CustomerModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.carNumber,
    required this.totalVisits,
    required this.totalSpent,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> j) => CustomerModel(
    id:           j['id'] as String,
    fullName:     j['full_name'] as String,
    phone:        j['phone'] as String,
    carNumber:    j['car_number'] as String? ?? '',
    totalVisits:  j['total_visits'] as int? ?? 0,
    totalSpent:   j['total_spent'] as int? ?? 0,
  );
}

class OrderModel {
  final String id;
  final String status;
  final String carNumber;
  final String carModel;
  final int totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String source;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String branchId;
  final String? branchName;
  final String? branchAddress;
  final String? serviceId;
  final String? serviceName;

  const OrderModel({
    required this.id,
    required this.status,
    required this.carNumber,
    required this.carModel,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.source,
    required this.scheduledAt,
    required this.createdAt,
    required this.completedAt,
    required this.branchId,
    this.branchName,
    this.branchAddress,
    this.serviceId,
    this.serviceName,
  });

  bool get isPending    => status == AppConstants.statusPending || status == AppConstants.statusPendingPayment;
  bool get isQueued     => status == AppConstants.statusQueued;
  bool get isWashing    => status == AppConstants.statusWashing;
  bool get isReady      => status == AppConstants.statusReady;
  bool get isCompleted  => status == AppConstants.statusCompleted;
  bool get isCancelled  => status == AppConstants.statusCancelled;
  bool get isActive     => isPending || isQueued || isWashing || isReady;
  bool get canCancel    => isPending || isQueued;

  String get statusLabel {
    switch (status) {
      case 'pending':   return 'Kutilmoqda';
      case 'pending_payment': return 'To\'lov kutilmoqda';
      case 'queue':    return 'Navbatda';
      case 'washing':   return 'Yuvilmoqda';
      case 'ready':     return 'Tayyor';
      case 'completed': return 'Bajarildi';
      case 'cancelled': return 'Bekor qilindi';
      default:          return status;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> j) {
    final branches = j['branches'];
    final services = j['services'];

    return OrderModel(
      id:            j['id'] as String,
      status:        j['status'] as String? ?? 'pending',
      carNumber:     j['car_number'] as String,
      carModel:      j['car_model'] as String? ?? '',
      totalAmount:   j['total_amount'] as int? ?? 0,
      paymentMethod: j['payment_method'] as String? ?? 'cash',
      paymentStatus: j['payment_status'] as String? ?? 'pending',
      source:        j['source'] as String? ?? 'by_client_app',
      scheduledAt:   j['scheduled_at'] != null
          ? DateTime.parse(j['scheduled_at'] as String)
          : null,
      createdAt:     DateTime.parse(j['created_at'] as String),
      completedAt:   j['completed_at'] != null
          ? DateTime.parse(j['completed_at'] as String)
          : null,
      branchId:      j['branch_id'] as String? ?? '',
      branchName:    branches is Map ? branches['name'] as String? : null,
      branchAddress: branches is Map ? branches['address'] as String? : null,
      serviceId:     j['service_id'] as String?,
      serviceName:   services is Map ? services['name'] as String? : null,
    );
  }
}

class SubscriptionModel {
  final String id;
  final String name;
  final int price;
  final int totalWashes;
  final int washesUsed;
  final DateTime startsAt;
  final DateTime expiresAt;
  final bool isActive;

  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.price,
    required this.totalWashes,
    required this.washesUsed,
    required this.startsAt,
    required this.expiresAt,
    required this.isActive,
  });

  int get washesRemaining => totalWashes - washesUsed;
  double get progress => totalWashes > 0 ? washesUsed / totalWashes : 0;
  bool get isExpired => expiresAt.isBefore(DateTime.now());
  bool get isValid => isActive && !isExpired;

  factory SubscriptionModel.fromJson(Map<String, dynamic> j) {
    return SubscriptionModel(
      id:          j['id'] as String,
      name:        j['name'] as String? ?? 'Obuna',
      price:       j['price'] as int? ?? 0,
      totalWashes: j['total_washes'] as int? ?? 0,
      washesUsed:  j['washes_used'] as int? ?? 0,
      startsAt:    DateTime.parse(j['starts_at'] as String),
      expiresAt:   DateTime.parse(j['expires_at'] as String),
      isActive:    j['is_active'] as bool? ?? true,
    );
  }
}

class TariffPlanModel {
  final String id;
  final String name;
  final int durationMonths;
  final int totalWashes;
  final int price;
  final int perMonthPrice;
  final String emoji;
  final bool isPopular;

  const TariffPlanModel({
    required this.id,
    required this.name,
    required this.durationMonths,
    required this.totalWashes,
    required this.price,
    required this.perMonthPrice,
    required this.emoji,
    required this.isPopular,
  });

  factory TariffPlanModel.fromJson(Map<String, dynamic> j) {
    return TariffPlanModel(
      id:             j['id'] as String,
      name:           j['name'] as String,
      durationMonths: j['duration_months'] as int? ?? 1,
      totalWashes:    j['total_washes'] as int? ?? 4,
      price:          j['price'] as int? ?? 0,
      perMonthPrice:  j['per_month_price'] as int? ?? 0,
      emoji:          j['emoji'] as String? ?? '🚿',
      isPopular:      j['is_popular'] as bool? ?? false,
    );
  }
}
