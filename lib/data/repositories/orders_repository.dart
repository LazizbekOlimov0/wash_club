import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/services/client_session.dart';
import '../../shared/services/supabase_service.dart';

/// Orders'ni boshqaruvchi repository.
/// Cache va realtime subscription shu yerda.
class OrdersRepository {
  OrdersRepository._();
  static final OrdersRepository instance = OrdersRepository._();

  final SupabaseService _api = SupabaseService.instance;
  final ClientSession   _session = ClientSession.instance;

  // In-memory cache
  List<OrderModel> _orders = [];
  bool _loaded = false;

  // Active realtime channels keyed by orderId
  final Map<String, RealtimeChannel> _channels = {};

  // Stream controller for UI updates
  final _controller = StreamController<List<OrderModel>>.broadcast();
  Stream<List<OrderModel>> get ordersStream => _controller.stream;

  List<OrderModel> get cachedOrders => List.unmodifiable(_orders);

  List<OrderModel> get activeOrders =>
      _orders.where((o) => o.isActive).toList();

  // ── Load ──────────────────────────────────────────────────
  Future<List<OrderModel>> loadOrders({bool forceRefresh = false}) async {
    if (_loaded && !forceRefresh) return _orders;

    final cars = _session.cars.map((c) => c.plate).toList();
    if (cars.isEmpty) {
      _orders = [];
      _loaded = true;
      _controller.add(_orders);
      return _orders;
    }

    _orders = await _api.getMyOrders(
      phone:      _session.phone ?? '',
      carNumbers: cars,
    );
    _loaded = true;
    _controller.add(_orders);

    // Active orderlar uchun realtime subscription
    for (final o in _orders.where((o) => o.isActive)) {
      _subscribeToOrder(o.id);
    }

    return _orders;
  }

  // ── Create order ──────────────────────────────────────────
  Future<OrderModel> createOrder({
    required String branchId,
    required String serviceId,
    required String carNumber,
    required String carModel,
    required int totalAmount,
    required String paymentMethod,
    required String vehicleCategory,
    DateTime? scheduledAt,
    List<String> addonServiceIds = const [],
  }) async {
    // 1) Customer upsert
    CustomerModel? customer;
    if (_session.isOnboarded) {
      customer = await _api.upsertCustomer(
        branchId:        branchId,
        fullName:        _session.name!,
        phone:           _session.phone!,
        carNumber:       carNumber,
        carModel:        carModel,
        vehicleCategory: vehicleCategory,
      );
    }

    // 2) Order yaratish
    final order = await _api.createOrder(
      branchId:       branchId,
      serviceId:      serviceId,
      carNumber:      carNumber,
      carModel:       carModel,
      totalAmount:    totalAmount,
      paymentMethod:  paymentMethod,
      customerId:     customer?.id,
      scheduledAt:    scheduledAt,
      addonServiceIds: addonServiceIds,
    );

    // 3) Cache update
    _orders.insert(0, order);
    _controller.add(_orders);

    // 4) Realtime kuzatish
    _subscribeToOrder(order.id);

    return order;
  }

  // ── Cancel order ──────────────────────────────────────────
  Future<void> cancelOrder(String orderId) async {
    await _api.cancelOrder(orderId);
    _unsubscribeFromOrder(orderId);
    _orders.removeWhere((o) => o.id == orderId);
    _controller.add(_orders);
  }

  // ── Realtime ──────────────────────────────────────────────
  void _subscribeToOrder(String orderId) {
    if (_channels.containsKey(orderId)) return;

    final channel = _api.watchOrderStatus(
      orderId: orderId,
      onUpdate: (updated) {
        final idx = _orders.indexWhere((o) => o.id == orderId);
        if (idx >= 0) {
          _orders[idx] = updated;
          _controller.add(_orders);
        }
        // Aktiv emas bo'lsa — unsubscribe
        if (!updated.isActive) {
          _unsubscribeFromOrder(orderId);
        }
      },
    );
    _channels[orderId] = channel;
  }

  void _unsubscribeFromOrder(String orderId) {
    final ch = _channels.remove(orderId);
    ch?.unsubscribe();
  }

  void dispose() {
    for (final ch in _channels.values) {
      ch.unsubscribe();
    }
    _channels.clear();
    _controller.close();
  }

  void invalidate() {
    _loaded = false;
    _orders = [];
  }
}