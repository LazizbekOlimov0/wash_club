import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/top_banner.dart';
import '../../../../../shared/services/client_session.dart';
import '../../../../../shared/services/branches_repository.dart';
import '../../../../../shared/services/orders_repository.dart';
import '../../../../../shared/services/supabase_service.dart';
import '../../../../../shared/constants/app_constants.dart';
import 'qr_scanner_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _branchRepo = BranchesRepository.instance;
  final _ordersRepo = OrdersRepository.instance;
  final _session = ClientSession.instance;
  final _api = SupabaseService.instance;

  List<BranchModel> _branches = [];
  List<OrderModel> _activeOrders = [];
  bool _loading = true;
  bool _scanningGate = false;
  String? _error;
  int _unreadNotifCount = 0;
  LatLng? _userPosition;

  @override
  void initState() {
    super.initState();
    _load();
    _fetchUserLocationSilently();

    // Orders stream kuzatish
    _ordersRepo.ordersStream.listen((orders) {
      if (mounted) {
        setState(() {
          _activeOrders = orders.where((o) => o.isActive).toList();
          _unreadNotifCount = _ordersRepo.unreadCount;
        });
      }
    });

    // Notification stream — badge yangilash
    _ordersRepo.notificationStream.listen((_) {
      if (mounted) setState(() => _unreadNotifCount = _ordersRepo.unreadCount);
    });

    // Sotib olish bildirishnomasi — Home screen'da yuqoridan banner
    TopBannerBus.notifier.addListener(_onPurchaseBanner);
  }

  void _onPurchaseBanner() {
    final message = TopBannerBus.current;
    if (message == null || !mounted) return;
    TopBannerBus.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showTopBanner(context, message: message);
    });
  }

  @override
  void dispose() {
    TopBannerBus.notifier.removeListener(_onPurchaseBanner);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _branchRepo.getBranches(),
        _ordersRepo.loadOrders(),
      ]);
      if (mounted) {
        setState(() {
          _branches = results[0] as List<BranchModel>;
          _activeOrders = (_ordersRepo.activeOrders);
          _unreadNotifCount = _ordersRepo.unreadCount;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = e.toString();
        });
    }
  }

  Future<void> _fetchUserLocationSilently() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      if (mounted) {
        setState(() => _userPosition = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {
      // Joylashuv olinmadi — masofa Toshkent markaziga nisbatan ko'rsatiladi.
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
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [colors.branchGradientStart, colors.branchGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Opacity(
        opacity: 0.7,
        child: Icon(
          Icons.local_car_wash_rounded,
          color: Colors.white,
          size: 40,
        ),
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
                  if (_activeOrders.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildActiveBookingCard(
                      context,
                      colors,
                      _activeOrders.first,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildMembershipCard(context, colors),
                  const SizedBox(height: 24),
                  _buildBranches(context, colors),
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
                    child: Icon(
                      Icons.notifications_outlined,
                      color: colors.onBackground,
                      size: 16,
                    ),
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

  // ── Faol bron kartasi ─────────────────────────────────────────
  Widget _buildActiveBookingCard(
    BuildContext context,
    ApparenceKitColors colors,
    OrderModel order,
  ) {
    final t = context.t;
    final time = order.scheduledAt ?? order.createdAt;
    final timeLabel =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final isToday =
        order.scheduledAt != null &&
        _isSameDay(order.scheduledAt!, DateTime.now());
    final dayLabel = isToday
        ? t.booking.today
        : '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg(colors),
          borderRadius: BorderRadius.circular(20),
          border: _cardBorder(colors),
          boxShadow: _cardShadow(colors),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.info,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  t.home.activeBooking,
                  style: TextStyle(
                    color: colors.grey3,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(
                      order.status,
                      colors,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _translateStatus(order.status),
                    style: TextStyle(
                      color: _statusColor(order.status, colors),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeLabel,
                  style: TextStyle(
                    color: colors.info,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    dayLabel,
                    style: TextStyle(
                      color: colors.grey3,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push(
                      '${UserRoutePath.map}?branchId=${order.branchId}',
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: colors.grey2,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.branchName ?? '—',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.onBackground,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (order.branchAddress != null &&
                                  order.branchAddress!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  order.branchAddress!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.grey2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: colors.grey2,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _scanningGate ? null : () => _openScanner(order),
                  child: Container(
                    width: 96,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: colors.onPrimary,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t.home.qrScan,
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.grey1.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.carNumber,
                    style: TextStyle(
                      color: colors.grey3,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    order.carModel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colors.grey2,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    order.serviceName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.info,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: colors.divider, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.home.gateInstruction,
                    style: TextStyle(color: colors.grey2, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openScanner(OrderModel order) async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code == null || code.isEmpty || !mounted) return;

    setState(() => _scanningGate = true);
    try {
      final ok = await _api.openGate(orderId: order.id, scannedCode: code);
      if (!mounted) return;
      if (ok) {
        _showGateSuccess();
      } else {
        _showGateError(order, message: context.t.qrScan.invalidQr);
      }
    } catch (_) {
      if (!mounted) return;
      _showGateError(order, message: context.t.qrScan.error);
    } finally {
      if (mounted) setState(() => _scanningGate = false);
    }
  }

  void _showGateSuccess() {
    final t = context.t;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final colors = Theme.of(ctx).extension<ApparenceKitColors>()!;
        Future.delayed(const Duration(seconds: 2), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
        return AlertDialog(
          backgroundColor: colors.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.successSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: colors.success, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                t.qrScan.gateOpened,
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.qrScan.gateOpenedDesc,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.grey2, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGateError(OrderModel order, {required String message}) {
    final t = context.t;
    showDialog(
      context: context,
      builder: (ctx) {
        final colors = Theme.of(ctx).extension<ApparenceKitColors>()!;
        return AlertDialog(
          backgroundColor: colors.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            t.qrScan.error,
            style: TextStyle(
              color: colors.onBackground,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(color: colors.grey2, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t.qrScan.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _openScanner(order);
              },
              child: Text(t.qrScan.tryAgain),
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _translateStatus(String status) {
    final t = context.t;
    switch (status) {
      case AppConstants.statusPending:
        return t.orderStatus.pending;
      case AppConstants.statusPendingPayment:
        return t.orderStatus.pendingPayment;
      case AppConstants.statusQueued:
        return t.orderStatus.queued;
      case AppConstants.statusConfirmed:
        return t.orderStatus.confirmed;
      case AppConstants.statusWashing:
        return t.orderStatus.washing;
      case AppConstants.statusDrying:
        return t.orderStatus.drying;
      case AppConstants.statusReady:
        return t.orderStatus.ready;
      case AppConstants.statusCompleted:
        return t.orderStatus.completed;
      case AppConstants.statusCancelled:
        return t.orderStatus.cancelled;
      default:
        return status;
    }
  }

  Color _statusColor(String status, ApparenceKitColors colors) {
    switch (status) {
      case 'pending':
        return colors.warning;
      case 'queued':
        return colors.success;
      case 'confirmed':
        return colors.success;
      case 'washing':
        return colors.info;
      case 'drying':
        return colors.info;
      case 'ready':
        return colors.success;
      case 'completed':
        return colors.success;
      default:
        return colors.error;
    }
  }

  // ── Branches ──────────────────────────────────────────────────────
  Widget _buildBranches(BuildContext context, ApparenceKitColors colors) {
    final t = context.t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.home.branches,
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(UserRoutePath.map),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.home.map,
                      style: TextStyle(
                        color: colors.info,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: colors.info, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 192,
          child: _branches.isEmpty
              ? Center(
                  child: Text(
                    'Filiallar topilmadi',
                    style: TextStyle(color: colors.grey2),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _branches.length,
                  itemBuilder: (context, i) =>
                      _buildBranchCard(context, colors, _branches[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildBranchCard(
    BuildContext context,
    ApparenceKitColors colors,
    BranchModel b,
  ) {
    final t = context.t;
    final width = MediaQuery.of(context).size.width * 0.78;

    return GestureDetector(
      onTap: () => context.go('${UserRoutePath.booking}?branchId=${b.id}'),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _cardBg(colors),
          borderRadius: BorderRadius.circular(20),
          border: _cardBorder(colors),
          boxShadow: _cardShadow(colors),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: b.imageUrl != null && b.imageUrl!.isNotEmpty
                      ? Image.network(
                          b.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _branchPlaceholder(colors),
                        )
                      : _branchPlaceholder(colors),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: b.isOpenNow ? colors.success : colors.grey3,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          b.isOpenNow ? t.home.open : t.home.closed,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: colors.warning, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          b.rating?.toStringAsFixed(1) ?? '4.9',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              b.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (_distanceLabel(b).isNotEmpty) ...[
                    Icon(
                      Icons.location_on_outlined,
                      color: colors.grey2,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _distanceLabel(b),
                      style: TextStyle(
                        color: colors.grey2,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.info.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: colors.info, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          t.home.freeBoxes(count: b.availableBoxes ?? 3),
                          style: TextStyle(
                            color: colors.info,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.home.select,
                        style: TextStyle(
                          color: colors.info,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right, color: colors.info, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _distanceLabel(BranchModel b) {
    if (b.latitude == null || b.longitude == null) return '';
    // Foydalanuvchi joylashuvi bo'lsa unga nisbatan, aks holda Toshkent markaziga.
    final origin = _userPosition ?? const LatLng(41.2995, 69.2401);
    final km = const Distance().as(
      LengthUnit.Kilometer,
      origin,
      LatLng(b.latitude!, b.longitude!),
    );
    return '${km.toStringAsFixed(1)} km';
  }

  // ── Membership / Obuna kartasi ──────────────────────────────────
  Widget _buildMembershipCard(BuildContext context, ApparenceKitColors colors) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push(UserRoutePath.subscriptions),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.accent, colors.warning],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Maxsus narx banneri — yuqori o'ng
              Positioned(
                top: 0,
                right: 0,
                child: Transform.rotate(
                  angle: 0.785,
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: colors.error,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 14,
                        ),
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
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextButton(
                      onPressed: () =>
                          context.push(UserRoutePath.subscriptions),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t.home.membershipSubscribe,
                            style: TextStyle(
                              color: colors.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right,
                            color: colors.accent,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                    Icon(
                      Icons.add_circle_outline,
                      color: colors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.home.addCar,
                      style: TextStyle(
                        color: colors.info,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...cars.map(
              (car) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _cardBg(colors),
                  borderRadius: BorderRadius.circular(14),
                  border: _cardBorder(colors),
                  boxShadow: _cardShadow(colors),
                ),
                child: Row(
                  children: [
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            car.color.isNotEmpty
                                ? '${car.plate} · ${car.color}'
                                : car.plate,
                            style: TextStyle(color: colors.grey2, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: colors.grey2, size: 20),
                  ],
                ),
              ),
            ),
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

  Widget _shimmer(
    ApparenceKitColors colors, {
    required double height,
    required double radius,
  }) {
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
            Text(
              'Ulanishda xatolik',
              style: TextStyle(
                color: colors.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: TextStyle(color: colors.grey2, fontSize: 12),
              textAlign: TextAlign.center,
            ),
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
