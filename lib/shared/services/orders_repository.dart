import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/client_session.dart';
import '../constants/app_constants.dart';

/// Notifikatsiya turi
enum NotifType { booking, promo, system }

/// Notifikatsiya modeli
class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daq';
    if (diff.inHours < 24) return '${diff.inHours} soat';
    if (diff.inDays < 7) return '${diff.inDays} kun';
    return '${createdAt.day}/${createdAt.month}';
  }
}

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

  // Notifications
  final List<AppNotification> _notifications = [];
  final _notifController = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get notificationStream => _notifController.stream;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

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
    // Status'ni cancelled ga o'zgartiramiz (o'chirmaymiz)
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx] = OrderModel(
        id: _orders[idx].id,
        status: AppConstants.statusCancelled,
        carNumber: _orders[idx].carNumber,
        carModel: _orders[idx].carModel,
        totalAmount: _orders[idx].totalAmount,
        paymentMethod: _orders[idx].paymentMethod,
        paymentStatus: _orders[idx].paymentStatus,
        source: _orders[idx].source,
        scheduledAt: _orders[idx].scheduledAt,
        createdAt: _orders[idx].createdAt,
        completedAt: _orders[idx].completedAt,
        branchId: _orders[idx].branchId,
        branchName: _orders[idx].branchName,
        branchAddress: _orders[idx].branchAddress,
        serviceId: _orders[idx].serviceId,
        serviceName: _orders[idx].serviceName,
      );
    }
    _controller.add(_orders);
  }

  // ── Realtime ──────────────────────────────────────────────
  void _subscribeToOrder(String orderId) {
    if (_channels.containsKey(orderId)) return;

    final channel = _api.watchOrderStatus(
      orderId: orderId,
      onUpdate: (updated) {
        final idx = _orders.indexWhere((o) => o.id == orderId);
        final oldStatus = idx >= 0 ? _orders[idx].status : null;
        if (idx >= 0) {
          _orders[idx] = updated;
          _controller.add(_orders);
        }
        // Status o'zgarganda notifikatsiya yaratish
        if (oldStatus != null && oldStatus != updated.status) {
          _addNotification(
            type: NotifType.booking,
            title: _statusToTitle(updated.status),
            body: '${updated.carNumber} · ${updated.serviceName ?? "Xizmat"}',
          );
        }
        // Aktiv emas bo'lsa — unsubscribe
        if (!updated.isActive) {
          _unsubscribeFromOrder(orderId);
        }
      },
    );
    _channels[orderId] = channel;
  }

  void _addNotification({
    required NotifType type,
    required String title,
    required String body,
  }) {
    final notif = AppNotification(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
    );
    _notifications.insert(0, notif);
    _notifController.add(notif);
  }

  String _statusToTitle(String status) {
    switch (status) {
      case 'pending':   return 'Buyurtma qabul qilindi';
      case 'washing':   return 'Yuvish boshlandi';
      case 'ready':     return 'Mashinangiz tayyor';
      case 'completed': return 'Buyurtma yakunlandi';
      case 'cancelled': return 'Buyurtma bekor qilindi';
      default:          return 'Holat yangilandi';
    }
  }

  void markRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) _notifications[idx].isRead = true;
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
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
    _notifController.close();
  }

  void invalidate() {
    _loaded = false;
    _orders = [];
    _notifications.clear();
  }
}
