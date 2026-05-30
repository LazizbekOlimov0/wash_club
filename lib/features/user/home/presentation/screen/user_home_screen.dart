import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../data/repositories/branches_repository.dart';
import '../../../../../data/repositories/orders_repository.dart';
import '../../../../../shared/services/client_session.dart';
import '../../../../../shared/services/supabase_service.dart';

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

  @override
  void initState() {
    super.initState();
    _load();

    // Orders stream kuzatish
    _ordersRepo.ordersStream.listen((orders) {
      if (mounted) {
        setState(() => _activeOrders = orders.where((o) => o.isActive).toList());
      }
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
          _branches     = results[0] as List<BranchModel>;
          _activeOrders = (_ordersRepo.activeOrders);
          _loading      = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  String get _userName => _session.name ?? 'Mehmon';

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
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          children: [
            _buildHeader(context, colors),
            if (_activeOrders.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildActiveOrderCard(context, colors, _activeOrders.first),
            ],
            const SizedBox(height: 24),
            _buildQuickActions(context, colors),
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
                    child: Icon(Icons.notifications_outlined,
                        color: colors.onBackground, size: 16),
                  ),
                  if (_activeOrders.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.error,
                          shape: BoxShape.circle,
                        ),
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

  // ── Active order card ─────────────────────────────────────────────
  Widget _buildActiveOrderCard(
      BuildContext context, ApparenceKitColors colors, OrderModel order) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg(colors),
          borderRadius: BorderRadius.circular(18),
          border: _cardBorder(colors),
          boxShadow: _cardShadow(colors),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
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
                  order.statusLabel.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(order.status, colors),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Time
            Text(
              order.scheduledAt != null
                  ? '${order.scheduledAt!.hour.toString().padLeft(2, '0')}:${order.scheduledAt!.minute.toString().padLeft(2, '0')}'
                  : '—',
              style: TextStyle(
                color: colors.onBackground,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              order.scheduledAt != null
                  ? '${order.scheduledAt!.year}-${order.scheduledAt!.month.toString().padLeft(2, '0')}-${order.scheduledAt!.day.toString().padLeft(2, '0')}'
                  : order.createdAt.toString().substring(0, 10),
              style: TextStyle(color: colors.grey3, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Divider(color: colors.divider, height: 1),
            const SizedBox(height: 16),
            _bookingRow(
              icon: Icons.location_on_outlined,
              title: order.branchName ?? '—',
              subtitle: order.branchAddress,
              colors: colors,
            ),
            const SizedBox(height: 10),
            _bookingRow(
              icon: Icons.directions_car_outlined,
              title: order.carNumber,
              subtitle: order.carModel.isNotEmpty ? order.carModel : null,
              colors: colors,
            ),
            if (order.serviceName != null) ...[
              const SizedBox(height: 10),
              _bookingRow(
                icon: Icons.local_car_wash_outlined,
                title: order.serviceName!,
                subtitle: null,
                colors: colors,
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: colors.divider, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (order.canCancel)
                  GestureDetector(
                    onTap: () => _confirmCancel(context, order),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined,
                              color: colors.error, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            t.home.cancel,
                            style: TextStyle(
                              color: colors.error,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () => context.go(UserRoutePath.orders),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.list_alt_outlined,
                            color: colors.info, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Barchasi',
                          style: TextStyle(
                            color: colors.info,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
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

  void _confirmCancel(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _c.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Bekor qilish', style: TextStyle(color: _c.onBackground)),
        content: Text(
          "Buyurtmani bekor qilmoqchimisiz?",
          style: TextStyle(color: _c.grey2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Yo\'q', style: TextStyle(color: _c.info)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _ordersRepo.cancelOrder(order.id);
            },
            child: Text('Ha', style: TextStyle(color: _c.error)),
          ),
        ],
      ),
    );
  }

  Widget _bookingRow({
    required IconData icon,
    required String title,
    required String? subtitle,
    required ApparenceKitColors colors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.grey2, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(color: colors.grey2, fontSize: 12)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Quick actions ─────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context, ApparenceKitColors colors) {
    final t = context.t;
    final actions = [
      {'icon': Icons.calendar_today_outlined, 'label': t.home.book,
        'route': UserRoutePath.booking},
      {'icon': Icons.history_outlined, 'label': t.home.history,
        'route': UserRoutePath.orders},
      {'icon': Icons.person_outline, 'label': t.profile.title,
        'route': UserRoutePath.profile},
      {'icon': Icons.help_outline, 'label': t.home.help,
        'route': null},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () {
              final route = a['route'] as String?;
              if (route != null) context.go(route);
            },
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _cardBg(colors),
                    borderRadius: BorderRadius.circular(18),
                    border: _cardBorder(colors),
                    boxShadow: _cardShadow(colors),
                  ),
                  child: Icon(a['icon'] as IconData,
                      color: colors.info, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  a['label'] as String,
                  style: TextStyle(
                    color: colors.grey3,
                    fontSize: 12,
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
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: _branches.isEmpty
              ? Center(
              child: Text('Filiallar topilmadi',
                  style: TextStyle(color: colors.grey2)))
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _branches.length,
            itemBuilder: (context, i) {
              final b = _branches[i];
              return GestureDetector(
                onTap: () => context.push(
                  UserRoutePath.booking,
                  extra: {'branchId': b.id},
                ),
                child: Container(
                  width: 220,
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
                      Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: _isLight
                              ? colors.primary.withValues(alpha: 0.06)
                              : colors.grey1,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.local_car_wash,
                              color: colors.info, size: 40),
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
                                    color: b.isActive
                                        ? colors.success
                                        : colors.error,
                                    borderRadius:
                                    BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    b.isActive ? 'Ochiq' : 'Yopiq',
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
              Text(
                t.home.myCars,
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push(UserRoutePath.addCar),
                icon: Icon(Icons.add, color: colors.info, size: 18),
                label:
                Text(t.home.manage, style: TextStyle(color: colors.info)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (cars.isEmpty)
            GestureDetector(
              onTap: () => context.push(UserRoutePath.addCar),
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