import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../shared/services/client_session.dart';
import '../../../../../shared/services/branches_repository.dart';
import '../../../../../shared/services/orders_repository.dart';
import '../../../../../shared/services/supabase_service.dart';
import '../../../../../shared/constants/app_constants.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _branchRepo = BranchesRepository.instance;
  final _ordersRepo = OrdersRepository.instance;
  final _session    = ClientSession.instance;

  List<BranchModel> _branches = [];
  List<OrderModel>  _activeOrders = [];
  bool _loading = true;
  String? _error;
  int _unreadNotifCount = 0;
  String _branchSearch = '';

  @override
  void initState() {
    super.initState();
    _load();

    // Orders stream kuzatish
    _ordersRepo.ordersStream.listen((orders) {
      if (mounted) {
        setState(() {
          _activeOrders      = orders.where((o) => o.isActive).toList();
          _unreadNotifCount  = _ordersRepo.unreadCount;
        });
      }
    });

    // Notification stream — badge yangilash
    _ordersRepo.notificationStream.listen((_) {
      if (mounted) setState(() => _unreadNotifCount = _ordersRepo.unreadCount);
    });
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _branchRepo.getBranches(),
        _ordersRepo.loadOrders(),
      ]);
      if (mounted) {
        setState(() {
          _branches          = results[0] as List<BranchModel>;
          _activeOrders      = (_ordersRepo.activeOrders);
          _unreadNotifCount  = _ordersRepo.unreadCount;
          _loading           = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  String get _userName => _session.name ?? context.t.home.welcome;

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  bool get _isLight => Theme.of(context).brightness == Brightness.light;

  Color _cardBg(ApparenceKitColors colors) =>
      _isLight ? colors.surface : colors.onPrimaryContainer;

  List<BoxShadow> _cardShadow(ApparenceKitColors colors) => _isLight
      ? [
    BoxShadow(
      color: colors.shadow.withValues(alpha: 0.07),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ]
      : [];

  Border? _cardBorder(ApparenceKitColors colors) =>
      _isLight ? Border.all(color: colors.divider, width: 1) : null;

  Widget _branchPlaceholder(ApparenceKitColors colors) => Container(
        height: 110,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A3A6B), Color(0xFF2D5AA0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Opacity(
            opacity: 0.7,
            child: Icon(Icons.local_car_wash_rounded, color: Colors.white, size: 40),
          ),
        ),
      );

  String _greeting(BuildContext context) {
    final t = context.t;
    final hour = DateTime.now().hour;
    if (hour < 12) return t.home.goodMorning;
    if (hour < 18) return t.home.goodAfternoon;
    return t.home.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final colors = _c;
    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: colors.info,
        child: _loading
            ? _buildSkeleton(colors)
            : _error != null
            ? _buildError(colors)
            : ListView(
          padding: const EdgeInsets.only(bottom: 100),
          physics: const ClampingScrollPhysics(),
          children: [
            _buildHeader(context, colors),
            const SizedBox(height: 16),
            _buildPromoCards(context, colors),
            if (_activeOrders.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildActiveOrdersSection(context, colors),
            ],
            const SizedBox(height: 24),
            _buildBranches(context, colors),
            const SizedBox(height: 24),
            _buildQuickActions(context, colors),
            const SizedBox(height: 24),
            _buildMyCars(context, colors),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, ApparenceKitColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      color: colors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(context),
                  style: TextStyle(
                    color: colors.onBackground.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(UserRoutePath.notifications),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isLight
                    ? colors.surface
                    : colors.onBackground.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(200),
                border: _isLight
                    ? Border.all(color: colors.divider, width: 1)
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.notifications_outlined,
                        color: colors.onBackground, size: 16),
                  ),
                  if (_unreadNotifCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: _unreadNotifCount > 9 ? 14 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: _unreadNotifCount > 1
                            ? Center(
                          child: Text(
                            _unreadNotifCount > 9
                                ? '9+'
                                : '$_unreadNotifCount',
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Active orders — stacked cards ───────────────────────────────
  Widget _buildActiveOrdersSection(
      BuildContext context, ApparenceKitColors colors) {
    final orders = _activeOrders.take(3).toList();
    final cardHeight = 130.0;
    final stackHeight = cardHeight + (orders.length - 1) * 12.0;

    return GestureDetector(
      onTap: () => context.go(UserRoutePath.orders),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: stackHeight,
          child: Stack(
            children: List.generate(orders.length, (i) {
              return Positioned(
                top: i * 12.0,
                left: 0,
                right: 0,
                child: _buildOrderCard(
                    context, colors, orders[i],
                    isTop: i == 0, isStacked: i > 0),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    ApparenceKitColors colors,
    OrderModel order, {
    bool isTop = true,
    bool isStacked = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isStacked ? colors.surface : _cardBg(colors),
        borderRadius: BorderRadius.circular(18),
        border: isStacked
            ? Border.all(color: colors.divider, width: 1)
            : _cardBorder(colors),
        boxShadow: isTop ? _cardShadow(colors) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusColor(order.status, colors),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _translateStatus(order.status),
                      style: TextStyle(
                        color: _statusColor(order.status, colors),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  order.branchName ?? '—',
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      order.carNumber,
                      style: TextStyle(color: colors.grey2, fontSize: 12),
                    ),
                    if (order.scheduledAt != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, color: colors.grey2, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${order.scheduledAt!.hour.toString().padLeft(2, '0')}:${order.scheduledAt!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: colors.grey2, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // QR code button
          GestureDetector(
            onTap: () => _showQrCode(context, order),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.qr_code, color: colors.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrCode(BuildContext context, OrderModel order) {
    final qrData = 'washclub:order:${order.id}';
    showDialog(
      context: context,
      builder: (ctx) {
        final colors = Theme.of(ctx).extension<ApparenceKitColors>()!;
        return AlertDialog(
          backgroundColor: colors.onPrimaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
            width: 280,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.close, color: colors.grey2, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: const Color(0xFF0F1B35),
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: const Color(0xFF0F1B35),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                order.carNumber,
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.branchName ?? '',
                style: TextStyle(color: colors.grey2, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(order.status, colors).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _translateStatus(order.status),
                  style: TextStyle(
                    color: _statusColor(order.status, colors),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  String _translateStatus(String status) {
    final t = context.t;
    switch (status) {
      case AppConstants.statusPending:        return t.orderStatus.pending;
      case AppConstants.statusPendingPayment: return t.orderStatus.pendingPayment;
      case AppConstants.statusQueued:         return t.orderStatus.queued;
      case AppConstants.statusConfirmed:      return t.orderStatus.confirmed;
      case AppConstants.statusWashing:        return t.orderStatus.washing;
      case AppConstants.statusDrying:         return t.orderStatus.drying;
      case AppConstants.statusReady:          return t.orderStatus.ready;
      case AppConstants.statusCompleted:      return t.orderStatus.completed;
      case AppConstants.statusCancelled:      return t.orderStatus.cancelled;
      default:                                return status;
    }
  }

  Color _statusColor(String status, ApparenceKitColors colors) {
    switch (status) {
      case 'pending':   return colors.warning;
      case 'washing':   return colors.info;
      case 'ready':     return colors.success;
      case 'completed': return colors.success;
      default:          return colors.error;
    }
  }

  // ── Quick actions ─────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context, ApparenceKitColors colors) {
    final t = context.t;
    final actions = [
      {'icon': Icons.calendar_today_outlined, 'label': t.home.book,
        'route': UserRoutePath.booking, 'push': false},
      {'icon': Icons.history_outlined, 'label': t.home.history,
        'route': UserRoutePath.orders, 'push': false},
      {'icon': Icons.person_outline, 'label': t.profile.title,
        'route': UserRoutePath.profile, 'push': false},
      {'icon': Icons.map_outlined, 'label': t.home.map,
        'route': UserRoutePath.map, 'push': true},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () {
              final route = a['route'] as String?;
              if (route == null) return;
              if (a['push'] == true) {
                context.push(route);
              } else {
                context.go(route);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _cardBg(colors),
                    borderRadius: BorderRadius.circular(18),
                    border: _cardBorder(colors),
                    boxShadow: _cardShadow(colors),
                  ),
                  child: Icon(a['icon'] as IconData,
                      color: colors.info, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  a['label'] as String,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.grey3,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Branches ──────────────────────────────────────────────────────
  Widget _buildBranches(BuildContext context, ApparenceKitColors colors) {
    final t = context.t;
    final filtered = _branches.where((b) {
      if (_branchSearch.isEmpty) return true;
      return b.name.toLowerCase().contains(_branchSearch.toLowerCase()) ||
          b.address.toLowerCase().contains(_branchSearch.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            t.home.nearestBranches,
            style: TextStyle(
              color: colors.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (v) => setState(() => _branchSearch = v),
            style: TextStyle(color: colors.onSurface, fontSize: 14),
            decoration: InputDecoration(
              hintText: context.t.home.searchBranch,
              hintStyle: TextStyle(color: colors.grey2, fontSize: 14),
              prefixIcon:
                  Icon(Icons.search, color: colors.grey2, size: 20),
              filled: true,
              fillColor: _isLight ? colors.surface : colors.onPrimaryContainer,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: filtered.isEmpty
              ? Center(
              child: Text('Filiallar topilmadi',
                  style: TextStyle(color: colors.grey2)))
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final b = filtered[i];
              return GestureDetector(
                onTap: () => context.push(
                  UserRoutePath.booking,
                  extra: {'branchId': b.id},
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.62,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: _cardBg(colors),
                    borderRadius: BorderRadius.circular(16),
                    border: _cardBorder(colors),
                    boxShadow: _cardShadow(colors),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: b.imageUrl != null && b.imageUrl!.isNotEmpty
                            ? Image.network(
                                b.imageUrl!,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _branchPlaceholder(colors),
                              )
                            : ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Image.asset(
                                  'assets/image/wash_club.png',
                                  height: 110,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    b.name,
                                    style: TextStyle(
                                      color: colors.onBackground,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: b.isOpenNow
                                        ? colors.success
                                        : colors.error,
                                    borderRadius:
                                    BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    b.isOpenNow ? context.t.home.open : context.t.home.closed,
                                    style: TextStyle(
                                      color: colors.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: colors.grey2, size: 12),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    b.address,
                                    style: TextStyle(
                                        color: colors.grey2,
                                        fontSize: 11),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Navigation helper — addCar + callback ─────────────────────────
  void _goToAddCar(BuildContext context) {
    context.push(
      UserRoutePath.addCar,
      extra: () {
        // AddCarScreen pop bo'lgandan keyin chaqiriladi
        if (mounted) setState(() {});
      },
    );
  }

  // ── My Cars ───────────────────────────────────────────────────────
  Widget _buildMyCars(BuildContext context, ApparenceKitColors colors) {
    final t = context.t;
    final cars = _session.cars;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  t.home.myCars,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _goToAddCar(context),
                icon: Icon(Icons.add, color: colors.info, size: 18),
                label: Text(
                    t.home.manage,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.info),
                  ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (cars.isEmpty)
            GestureDetector(
              onTap: () => _goToAddCar(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _isLight
                      ? colors.primary.withValues(alpha: 0.05)
                      : colors.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isLight
                        ? colors.primary.withValues(alpha: 0.20)
                        : colors.grey1,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: colors.info, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      t.home.addCar,
                      style: TextStyle(
                          color: colors.info,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else
            ...cars.map((car) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _cardBg(colors),
                borderRadius: BorderRadius.circular(14),
                border: _cardBorder(colors),
                boxShadow: _cardShadow(colors),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isLight
                          ? colors.primary.withValues(alpha: 0.08)
                          : colors.grey1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.directions_car_outlined,
                        color: colors.info, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: colors.onBackground,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          car.color.isNotEmpty
                              ? '${car.plate} · ${car.color}'
                              : car.plate,
                          style: TextStyle(
                              color: colors.grey2, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: colors.grey2, size: 20),
                ],
              ),
            )),
        ],
      ),
    );
  }

  // ── Skeleton / Error ──────────────────────────────────────────────
  Widget _buildSkeleton(ApparenceKitColors colors) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 56),
        _shimmer(colors, height: 60, radius: 12),
        const SizedBox(height: 16),
        _shimmer(colors, height: 180, radius: 18),
        const SizedBox(height: 16),
        _shimmer(colors, height: 80, radius: 14),
        const SizedBox(height: 16),
        _shimmer(colors, height: 120, radius: 14),
      ],
    );
  }

  Widget _shimmer(ApparenceKitColors colors,
      {required double height, required double radius}) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: colors.grey1.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildError(ApparenceKitColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: colors.grey2, size: 48),
            const SizedBox(height: 16),
            Text('Ulanishda xatolik',
                style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error ?? '',
                style: TextStyle(color: colors.grey2, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Qaytadan urinish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.info,
                foregroundColor: colors.onPrimary,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// user_home_screen.dart ichiga qo'shiladi

// ── Promo Cards ──────────────────────────────────────────────────
Widget _buildPromoCards(BuildContext context, ApparenceKitColors colors) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        _buildMembershipCard(context, colors),
        const SizedBox(height: 12),
        _buildBookingPromoCard(context, colors),
      ],
    ),
  );
}

Widget _buildMembershipCard(BuildContext context, ApparenceKitColors colors) {
  final t = context.t;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B1A), Color(0xFFFF4500)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    clipBehavior: Clip.hardEdge,
    child: Stack(
      children: [
        // Special price banner — top right
        Positioned(
          top: 0,
          right: 0,
          child: Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 90,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: const Color(0xFFCC0000),
              child: Text(
                t.home.membershipSpecialPrice,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.workspace_premium, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'WASHCLUB MEMBERSHIP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Price
            Text(
              t.home.membershipPrice,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.home.membershipOffer,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // Button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextButton(
                onPressed: () {
                  // If guest, ask to login first
                  if (!ClientSession.instance.isOnboarded) {
                    context.push(UserRoutePath.otpLogin);
                    return;
                  }
                  context.go(UserRoutePath.profile);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.home.membershipSubscribe,
                      style: const TextStyle(
                        color: Color(0xFFFF4500),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right, color: Color(0xFFFF4500), size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildBookingPromoCard(BuildContext context, ApparenceKitColors colors) {
  final t = context.t;
  return GestureDetector(
    onTap: () => context.go(UserRoutePath.booking),
    child: Container(
      width: double.infinity,
      height: 200,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF2D1B69)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
      children: [
        // Background image
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            AppConstants.branchImages[0],
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF4A2080)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.local_car_wash, color: Colors.white54, size: 60),
              ),
            ),
          ),
        ),
        // Dark overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        // Content
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'TEZROQ',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.home.bookingPromoTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    t.home.bookingPromoDesc,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            t.home.bookingPromoButton,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }