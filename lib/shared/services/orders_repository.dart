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
    if (diff.inMinutes < 1) return 'time.now';
    if (diff.inMinutes < 60) return 'time.minutes.${diff.inMinutes}';
    if (diff.inHours < 24) return 'time.hours.${diff.inHours}';
    if (diff.inDays < 7) return 'time.days.${diff.inDays}';
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

  List<OrderModel> _orders = [];

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

  // ── Load (har doim API'dan yangi malumot) ─────────────────
  Future<List<OrderModel>> loadOrders() async {
    final cars = _session.cars.map((c) => c.plate).toList();
    if (cars.isEmpty) {
      _orders = [];
      _controller.add(_orders);
      return _orders;
    }

    _orders = await _api.getMyOrders(
      phone:      _session.phone ?? '',
      carNumbers: cars,
    );
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
    required bool hasSubscription,
    DateTime? scheduledAt,
    List<String> addonServiceIds = const [],
    String? receiptUrl,
    String? promoCode,
    String? branchName,
    String? serviceName,
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

    String? bookingPaymentId;
    if (!hasSubscription && receiptUrl != null && customer != null) {
      // One-time booking: create membership_payment first
      final promoLabel = promoCode != null ? 'Bir martalik bron ($promoCode)' : 'Bir martalik bron';
      bookingPaymentId = await _api.createMembershipPayment(
        customerId: customer.id,
        branchId: branchId,
        planName: promoLabel,
        planPrice: totalAmount,
        receiptUrl: receiptUrl,
        paymentType: 'one_time_booking',
        totalWashes: 1,
        durationMonths: 0,
      );
    }

    // 2) Order yaratish
    final order = await _api.createOrder(
      branchId:         branchId,
      serviceId:        serviceId,
      carNumber:        carNumber,
      carModel:         carModel,
      totalAmount:      totalAmount,
      paymentMethod:    hasSubscription ? AppConstants.paymentSubscription : AppConstants.paymentCardReceipt,
      hasSubscription:  hasSubscription,
      customerId:       customer?.id,
      scheduledAt:      scheduledAt,
      addonServiceIds:  addonServiceIds,
      bookingPaymentId: bookingPaymentId,
    );

    // 3) Telegram QR yuborish (faqat member bron uchun)
    if (hasSubscription && order.id.isNotEmpty) {
      final telegramChatId = _session.telegramChatId;
      if (telegramChatId != null && telegramChatId.isNotEmpty) {
        _api.sendBookingQrToTelegram(
          chatId: telegramChatId,
          carNumber: carNumber,
          orderId: order.id,
          serviceName: serviceName,
          branchName: branchName,
        );
      }
    }

    // 4) Branch operator notification (fire-and-forget)
    _api.notifyBranchOperator(
      branchId: branchId,
      message: '📱 Yangi bron (Ilova)${hasSubscription ? ' · Obuna' : ' · 1 martalik chek'}\n'
          '🚗 $carNumber${carModel.isNotEmpty ? ' · $carModel' : ''}',
    );

    // 5) API'dan qayta yuklash
    await loadOrders();

    return order;
  }

  // ── Cancel order (client-side) ────────────────────────────
  Future<void> cancelOrder(String orderId) async {
    await _api.cancelMyOrder(orderId);
    _unsubscribeFromOrder(orderId);
    await loadOrders();
  }

  // ── Delete order (client-side, eski order uchun) ──────────
  Future<void> deleteOrder(String orderId) async {
    await _api.deleteMyOrder(orderId);
    _unsubscribeFromOrder(orderId);
    await loadOrders();
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
            body: '${updated.carNumber} · ${updated.serviceName ?? "Service"}',
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
      case AppConstants.statusPending:        return 'orderStatus.pending';
      case AppConstants.statusPendingPayment: return 'orderStatus.pending_payment';
      case AppConstants.statusQueued:         return 'orderStatus.queued';
      case AppConstants.statusConfirmed:      return 'orderStatus.confirmed';
      case AppConstants.statusWashing:        return 'orderStatus.washing';
      case AppConstants.statusDrying:         return 'orderStatus.drying';
      case AppConstants.statusReady:          return 'orderStatus.ready';
      case AppConstants.statusCompleted:      return 'orderStatus.completed';
      case AppConstants.statusCancelled:      return 'orderStatus.cancelled';
      default:                                return 'orderStatus.pending';
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
    _orders = [];
    _notifications.clear();
  }
}
