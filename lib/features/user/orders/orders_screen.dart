import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/services/orders_repository.dart';
import '../home/presentation/screen/qr_scanner_screen.dart';

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
  bool _cancelling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      final orders = await _repo.loadOrders();
      if (mounted) setState(() { _all = orders; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<OrderModel> get _active  => _all.where((o) => o.isActive).toList();
  List<OrderModel> get _history => _all.where((o) => o.isCompleted || o.isCancelled).toList();

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = _c;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colors),
            _buildSegmentedTabs(colors),
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
                                  emptyLabel: t.orders.emptyActive,
                                  colors: colors),
                              _buildList(_history,
                                  emptyLabel: t.orders.emptyHistory,
                                  showBookButton: true,
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

  // ── Sarlavha ─────────────────────────────────────────────────────
  Widget _buildHeader(ApparenceKitColors colors) {
    final t = context.t;
    return Padding(
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
            t.orders.summary
                .replaceAll('{active}', '${_active.length}')
                .replaceAll('{history}', '${_history.length}'),
            style: TextStyle(color: colors.grey2, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Segmented tabs ───────────────────────────────────────────────
  Widget _buildSegmentedTabs(ApparenceKitColors colors) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _isDark ? colors.onPrimaryContainer : colors.grey1,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSegTab(0, t.orders.activeTab,
                  badge: _active.length, colors: colors),
            ),
            Expanded(
              child: _buildSegTab(1, t.orders.history, colors: colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegTab(
    int index,
    String label, {
    int? badge,
    required ApparenceKitColors colors,
  }) {
    final selected = _tabController.index == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? colors.onPrimary : colors.onBackground,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? colors.onPrimary
                      : colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    color: selected ? colors.primary : colors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── QR scan (umumiy oqim) ────────────────────────────────────────
  Future<void> _openQrScanner(OrderModel order) async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code == null || code.isEmpty || !mounted) return;

    try {
      final ok = await SupabaseService.instance.openGate(
        orderId: order.id,
        scannedCode: code,
      );
      if (!mounted) return;
      if (ok) {
        _showGateSuccess();
      } else {
        _showGateError(order, message: context.t.qrScan.invalidQr);
      }
    } catch (_) {
      if (!mounted) return;
      _showGateError(order, message: context.t.qrScan.error);
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
              borderRadius: BorderRadius.circular(20)),
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
              borderRadius: BorderRadius.circular(20)),
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
                _openQrScanner(order);
              },
              child: Text(t.qrScan.tryAgain),
            ),
          ],
        );
      },
    );
  }

  // ── Ro'yxat ──────────────────────────────────────────────────────
  Widget _buildList(
    List<OrderModel> orders, {
    required String emptyLabel,
    bool showBookButton = false,
    required ApparenceKitColors colors,
  }) {
    if (orders.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildEmpty(emptyLabel,
                    showBookButton: showBookButton, colors: colors),
              ),
            ),
          );
        },
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: orders.length,
      itemBuilder: (context, i) => _OrderCard(
        order: orders[i],
        colors: colors,
        isDark: _isDark,
        onCancel: orders[i].canCancel
            ? () => _confirmCancel(orders[i])
            : null,
        onQrScan: orders[i].isActive
            ? () => _openQrScanner(orders[i])
            : null,
      ),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _isDark ? colors.onPrimaryContainer : colors.grey1,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.calendar_today_outlined,
                color: colors.grey2, size: 24),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: colors.grey2, fontSize: 14)),
          if (showBookButton) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go(UserRoutePath.booking),
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.t.orders.bookNow),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.info,
                foregroundColor: colors.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
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
          Text(context.t.orders.error,
              style: TextStyle(color: colors.onBackground, fontSize: 15)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.info,
              foregroundColor: colors.onPrimary,
              elevation: 0,
            ),
            child: Text(context.t.orders.retry),
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
        title: Text(context.t.orders.cancelTitle,
            style: TextStyle(color: _c.onBackground)),
        content: Text(context.t.orders.cancelConfirm,
            style: TextStyle(color: _c.grey2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t.orders.cancelNo, style: TextStyle(color: _c.info)),
          ),
          TextButton(
            onPressed: _cancelling
                ? null
                : () async {
                    Navigator.pop(ctx);
                    setState(() => _cancelling = true);
                    try {
                      await _repo.cancelOrder(order.id);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${context.t.orders.cancelError}: $e'),
                            backgroundColor: _c.error,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _cancelling = false);
                    }
                  },
            child: _cancelling
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_c.error),
                    ),
                  )
                : Text(context.t.orders.cancelYes, style: TextStyle(color: _c.error)),
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
    this.onQrScan,
  });

  final OrderModel order;
  final ApparenceKitColors colors;
  final bool isDark;
  final VoidCallback? onCancel;
  final VoidCallback? onQrScan;

  Color get _cardBg =>
      isDark ? colors.onPrimaryContainer : colors.surface;

  String _translateStatus(BuildContext context) {
    final t = context.t;
    switch (order.status) {
      case AppConstants.statusPending:        return t.orderStatus.pending;
      case AppConstants.statusPendingPayment: return t.orderStatus.pendingPayment;
      case AppConstants.statusQueued:         return t.orderStatus.queued;
      case AppConstants.statusConfirmed:      return t.orderStatus.confirmed;
      case AppConstants.statusWashing:        return t.orderStatus.washing;
      case AppConstants.statusDrying:         return t.orderStatus.drying;
      case AppConstants.statusReady:          return t.orderStatus.ready;
      case AppConstants.statusCompleted:      return t.orderStatus.completed;
      case AppConstants.statusCancelled:      return t.orderStatus.cancelled;
      default:                                return order.status;
    }
  }

  Color _statusColor() {
    switch (order.status) {
      case AppConstants.statusPending:
      case AppConstants.statusPendingPayment: return colors.warning;
      case AppConstants.statusQueued:
      case AppConstants.statusConfirmed:      return colors.success;
      case AppConstants.statusWashing:
      case AppConstants.statusDrying:         return colors.info;
      case AppConstants.statusReady:
      case AppConstants.statusCompleted:      return colors.success;
      case AppConstants.statusCancelled:      return colors.error;
      default:                                return colors.error;
    }
  }

  String _orderIdLabel() {
    final id = order.id;
    final short = id.length < 8 ? id : id.substring(0, 8);
    return '#${short.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

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
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _translateStatus(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Divider(height: 1, thickness: 1),
          ),

          // ── Time + date + order ID ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                  style: TextStyle(color: colors.grey2, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  _orderIdLabel(),
                  style: TextStyle(
                    color: colors.grey2,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // ── Location ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _row(Icons.location_on_outlined,
                order.branchName ?? order.branchId),
          ),
          const SizedBox(height: 6),
          // ── Car ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _row(
              Icons.directions_car_outlined,
              order.carModel.isNotEmpty
                  ? '${order.carNumber} • ${order.carModel}'
                  : order.carNumber,
            ),
          ),
          if (order.serviceName != null) ...[
            const SizedBox(height: 6),
            // ── Service ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _row(
                  Icons.local_car_wash_outlined, order.serviceName!),
            ),
          ],

          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Divider(height: 1, thickness: 1),
          ),

          // ── Summa + QR Scan ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t.orders.summa,
                        style:
                            TextStyle(color: colors.grey2, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatPrice(order.totalAmount),
                        style: TextStyle(
                          color: colors.info,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onQrScan != null)
                  GestureDetector(
                    onTap: onQrScan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner,
                              color: colors.onPrimary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            context.t.home.qrScan,
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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
      backgroundColor: isDark ? colors.onPrimaryContainer : colors.surface,
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
            if (onCancel != null)
              _menuItem(ctx,
                icon: Icons.close,
                label: context.t.orders.cancelOrder,
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
  return "${buf.toString()} UZS";
}
