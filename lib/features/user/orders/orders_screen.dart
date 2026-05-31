import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../data/repositories/orders_repository.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = OrdersRepository.instance;

  List<OrderModel> _all = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));

    // Realtime stream
    _repo.ordersStream.listen((orders) {
      if (mounted) setState(() => _all = orders);
    });

    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final orders = await _repo.loadOrders(forceRefresh: true);
      if (mounted) setState(() { _all = orders; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<OrderModel> get _active    => _all.where((o) => o.isActive).toList();
  List<OrderModel> get _history   => _all.where((o) => o.isCompleted).toList();
  List<OrderModel> get _cancelled => _all.where((o) => o.isCancelled).toList();

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = _c;

    final tabBarBg   = _isDark ? colors.onPrimaryContainer : colors.grey1;
    final tabIndClr  = _isDark ? colors.onBackground : colors.onBackground;
    final tabLblClr  = _isDark ? colors.background   : colors.onPrimary;
    final tabUnselClr= _isDark ? colors.grey2         : colors.grey3;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.orders.title,
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_active.length} faol · ${_all.length} jami',
                    style: TextStyle(color: colors.grey2, fontSize: 13),
                  ),
                ],
              ),
            ),

            // ── Tabs ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: tabBarBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isDark
                        ? colors.grey1.withValues(alpha: 0.6)
                        : colors.grey2.withValues(alpha: 0.35),
                    width: _isDark ? 1 : 1.5,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: tabIndClr,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: tabLblClr,
                  unselectedLabelColor: tabUnselClr,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Rounded',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SF Pro Rounded',
                  ),
                  tabs: const [
                    Tab(text: 'Faol',     height: 34),
                    Tab(text: 'Tarix',    height: 34),
                    Tab(text: 'Bekor',    height: 34),
                  ],
                ),
              ),
            ),

            // ── Tab views ─────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(color: colors.info),
                    )
                  : _error != null
                      ? _buildError(colors)
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: colors.info,
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildList(_active,
                                  emptyLabel: 'Faol buyurtmalar yo\'q',
                                  colors: colors),
                              _buildList(_history,
                                  emptyLabel: 'Bajarilgan buyurtmalar yo\'q',
                                  showBookButton: true,
                                  colors: colors),
                              _buildList(_cancelled,
                                  emptyLabel: 'Bekor qilingan buyurtmalar yo\'q',
                                  colors: colors),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    List<OrderModel> orders, {
    required String emptyLabel,
    bool showBookButton = false,
    required ApparenceKitColors colors,
  }) {
    if (orders.isEmpty) {
      return _buildEmpty(emptyLabel,
          showBookButton: showBookButton, colors: colors);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: orders.length,
      itemBuilder: (context, i) =>
          _OrderCard(order: orders[i], colors: colors, isDark: _isDark,
              onCancel: orders[i].canCancel
                  ? () => _confirmCancel(orders[i])
                  : null),
    );
  }

  Widget _buildEmpty(
    String label, {
    bool showBookButton = false,
    required ApparenceKitColors colors,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _isDark ? colors.onPrimaryContainer : colors.grey1,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.calendar_today_outlined,
                color: colors.grey2, size: 28),
          ),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: colors.grey2, fontSize: 15)),
          if (showBookButton) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go(UserRoutePath.booking),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Band qilish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.info,
                foregroundColor: colors.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(ApparenceKitColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: colors.grey2, size: 40),
          const SizedBox(height: 12),
          Text('Xatolik yuz berdi',
              style: TextStyle(color: colors.onBackground, fontSize: 15)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.info,
              foregroundColor: colors.onPrimary,
              elevation: 0,
            ),
            child: const Text('Qayta urinish'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _c.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Bekor qilish',
            style: TextStyle(color: _c.onBackground)),
        content: Text('Buyurtmani bekor qilmoqchimisiz?',
            style: TextStyle(color: _c.grey2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Yo'q", style: TextStyle(color: _c.info)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _repo.cancelOrder(order.id);
            },
            child: Text('Ha', style: TextStyle(color: _c.error)),
          ),
        ],
      ),
    );
  }
}

// ── Order Card ─────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.colors,
    required this.isDark,
    this.onCancel,
  });

  final OrderModel order;
  final ApparenceKitColors colors;
  final bool isDark;
  final VoidCallback? onCancel;

  Color get _cardBg =>
      isDark ? colors.onPrimaryContainer : colors.surface;

  Color _statusColor() {
    switch (order.status) {
      case AppConstants.statusPending:   return colors.warning;
      case AppConstants.statusWashing:   return colors.info;
      case AppConstants.statusReady:     return colors.success;
      case AppConstants.statusCompleted: return colors.success;
      default:                           return colors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.grey1, width: 1),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status + menu ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _statusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  order.statusLabel,
                  style: TextStyle(
                    color: _statusColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onCancel != null)
                  IconButton(
                    onPressed: () => _showMenu(context),
                    icon: Icon(Icons.more_horiz,
                        color: colors.grey2, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          // ── Time ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _displayTime(),
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _displayDate(),
                  style: TextStyle(color: colors.grey2, fontSize: 15),
                ),
              ],
            ),
          ),

          // ── Info rows ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                _row(Icons.location_on_outlined,
                    order.branchName ?? order.branchId),
                const SizedBox(height: 6),
                _row(Icons.directions_car_outlined, order.carNumber),
                if (order.serviceName != null) ...[
                  const SizedBox(height: 6),
                  _row(Icons.local_car_wash_outlined, order.serviceName!),
                ],
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: colors.grey1),
          ),

          // ── Price ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _paymentLabel(order.paymentMethod),
                  style: TextStyle(color: colors.grey2, fontSize: 13),
                ),
                Text(
                  _formatPrice(order.totalAmount),
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayTime() {
    final dt = order.scheduledAt ?? order.createdAt;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _displayDate() {
    final dt = order.scheduledAt ?? order.createdAt;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'card':  return 'Karta';
      case 'cash':  return 'Naqd';
      case 'click': return 'Click';
      case 'payme': return 'Payme';
      default:      return method;
    }
  }

  Widget _row(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: colors.grey2, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(color: colors.grey2, fontSize: 13)),
        ),
      ],
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? colors.onPrimaryContainer : colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.grey1,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _menuItem(ctx,
              icon: Icons.close,
              label: 'Buyurtmani bekor qilish',
              color: colors.error,
              onTap: () {
                Navigator.pop(ctx);
                onCancel?.call();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int sum) {
  final s = sum.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return "${buf.toString()} so'm";
}
