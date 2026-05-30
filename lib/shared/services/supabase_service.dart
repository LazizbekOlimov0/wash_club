import 'package:supabase_flutter/supabase_flutter.dart';
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
        .select('''
          id, name, address, is_active, created_at,
          services (
            id, name, description, is_active, is_addon, icon, sort_order,
            service_prices ( vehicle_category, price )
          )
        ''')
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
            id, name, description, is_active, is_addon, icon, sort_order,
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
        .select('id, name, description, is_active, is_addon, icon, sort_order, service_prices ( vehicle_category, price )')
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
      'status':         AppConstants.statusPending,
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

  /// Buyurtmani bekor qilish
  /// (Supabase'da client app orderlarini o'chirish mumkin — lekin bu yerda
  /// biz statusni 'cancelled' ga o'zgartirishni EMAS, balki o'chirishni ishlatamiz)
  Future<void> cancelOrder(String orderId) async {
    // Faqat pending va scheduled holatdagi buyurtmalarni bekor qilish mumkin
    await _client
        .from('orders')
        .delete()
        .eq('id', orderId)
        .eq('source', AppConstants.orderSourceClientApp)
        .inFilter('status', [AppConstants.statusPending]);
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
}

// ─────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────

class BranchModel {
  final String id;
  final String name;
  final String address;
  final bool isActive;
  final List<ServiceModel> services;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.isActive,
    required this.services,
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
      services:  services,
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
  final Map<String, int> prices; // vehicle_category → price

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isAddon,
    required this.icon,
    required this.sortOrder,
    required this.prices,
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

  bool get isPending    => status == AppConstants.statusPending;
  bool get isWashing    => status == AppConstants.statusWashing;
  bool get isReady      => status == AppConstants.statusReady;
  bool get isCompleted  => status == AppConstants.statusCompleted;
  bool get isCancelled  => status == AppConstants.statusCancelled;
  bool get isActive     => isPending || isWashing || isReady;
  bool get canCancel    => isPending;

  String get statusLabel {
    switch (status) {
      case 'pending':   return 'Kutilmoqda';
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