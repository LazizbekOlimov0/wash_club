import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_Order> _active = [
    _Order(
      status: OrderStatus.confirmed,
      time: '13:00',
      date: '2026-05-04',
      branch: 'Wash Club Yunusobod',
      car: 'Chevrolet Malibu · 01 U 571 QA',
      serviceType: 'Стандарт',
      paymentMethod: 'Карта',
      price: '60 000 сум',
    ),
    _Order(
      status: OrderStatus.confirmed,
      time: '10:00',
      date: '2026-05-03',
      branch: 'Wash Club Yunusobod',
      car: 'Chevrolet Malibu · 01 U 571 QA',
      serviceType: 'Стандарт',
      paymentMethod: 'Карта',
      price: '60 000 сум',
    ),
  ];

  final List<_Order> _history = [];

  final List<_Order> _cancelled = [
    _Order(
      status: OrderStatus.cancelled,
      time: '10:00',
      date: '2026-05-01',
      branch: 'Wash Club Yunusobod',
      car: 'Chevrolet Malibu · 01 U 571 QA',
      serviceType: 'Стандарт',
      paymentMethod: 'Карта',
      price: '60 000 сум',
    ),
  ];

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _totalCount =>
      _active.length + _history.length + _cancelled.length;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = _c;

    // Tab bar renglari: dark vs light uchun alohida
    final tabBarBg = _isDark
        ? colors.onPrimaryContainer          // dark: #1A2B4A
        : colors.grey1;                      // light: #E2E6EF — ko'zga tashlanarli

    final tabIndicatorColor = _isDark
        ? colors.onBackground                // dark: white pill
        : colors.onBackground;               // light: #0F1B35 dark pill

    final tabLabelColor = _isDark
        ? colors.background                  // dark: white text on dark pill
        : colors.onPrimary;                  // light: white text on dark pill

    final tabUnselectedColor = _isDark
        ? colors.grey2
        : colors.grey3;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
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
                    '${_active.length} активных · $_totalCount всего',
                    style: TextStyle(color: colors.grey2, fontSize: 13),
                  ),
                ],
              ),
            ),

            // ── Tab bar ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: tabBarBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    // light modeda border aniq ko'rinsin, dark'da ingichka
                    color: _isDark
                        ? colors.grey1.withValues(alpha: 0.6)
                        : colors.grey2.withValues(alpha: 0.35),
                    width: _isDark ? 1 : 1.5,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: tabIndicatorColor,
                    borderRadius: BorderRadius.circular(7),
                    // pill'ga yengil shadow — ayniqsa light mode uchun
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
                  labelColor: tabLabelColor,
                  unselectedLabelColor: tabUnselectedColor,
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
                    Tab(text: 'Активные',   height: 34),
                    Tab(text: 'История',    height: 34),
                    Tab(text: 'Отменённые', height: 34),
                  ],
                ),
              ),
            ),

            // ── Tab views ───────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                // Swipe gesture'ni yoqib qo'yamiz (default yoqiq, lekin
                // parent scroll'lar bilan muammo bo'lsa physics belgilanadi)
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildOrderList(
                    _active,
                    emptyLabel: 'Нет активных заказов',
                    colors: colors,
                  ),
                  _buildOrderList(
                    _history,
                    emptyLabel: 'Завершённых заказов пока нет',
                    showBookButton: true,
                    colors: colors,
                  ),
                  _buildOrderList(
                    _cancelled,
                    emptyLabel: 'Нет отменённых заказов',
                    colors: colors,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(
      List<_Order> orders, {
        required String emptyLabel,
        bool showBookButton = false,
        required ApparenceKitColors colors,
      }) {
    if (orders.isEmpty) {
      return _buildEmpty(
        emptyLabel,
        showBookButton: showBookButton,
        colors: colors,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: orders.length,
      itemBuilder: (context, i) =>
          _OrderCard(order: orders[i], colors: colors, isDark: _isDark),
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
          Text(
            label,
            style: TextStyle(color: colors.grey2, fontSize: 15),
          ),
          if (showBookButton) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go(UserRoutePath.booking),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Забронировать'),
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
}

// ── Order card ────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.colors,
    required this.isDark,
  });

  final _Order order;
  final ApparenceKitColors colors;
  final bool isDark;

  // Karta foni: dark'da onPrimaryContainer (#1A2B4A), light'da surface (#FFF)
  Color get _cardBg => isDark ? colors.onPrimaryContainer : colors.surface;

  // Karta border: dark'da ingichka grey1, light'da ajralib tursin
  Color get _cardBorder => isDark
      ? colors.grey1
      : colors.grey1; // light: #E2E6EF

  @override
  Widget build(BuildContext context) {
    final isConfirmed = order.status == OrderStatus.confirmed;
    final statusColor = isConfirmed ? colors.info : colors.error;
    final statusLabel = isConfirmed ? 'Подтверждено' : 'Отменено';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1),
        // Light modeda kartalar background'dan ajralib turishi uchun shadow
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
          // ── Status + menu ──────────────────────────────────
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
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isConfirmed)
                  IconButton(
                    onPressed: () => _showOrderMenu(context),
                    icon: Icon(Icons.more_horiz,
                        color: colors.grey2, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          // ── Time + date ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  order.time,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  order.date,
                  style: TextStyle(color: colors.grey2, fontSize: 15),
                ),
              ],
            ),
          ),

          // ── Info rows ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                _infoRow(Icons.location_on_outlined, order.branch),
                const SizedBox(height: 6),
                _infoRow(Icons.directions_car_outlined, order.car),
                const SizedBox(height: 6),
                _infoRow(Icons.access_time_outlined, order.serviceType),
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: colors.grey1),
          ),

          // ── Payment + price ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.paymentMethod,
                  style: TextStyle(color: colors.grey2, fontSize: 13),
                ),
                Text(
                  order.price,
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

  Widget _infoRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: colors.grey2, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: colors.grey2, fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _showOrderMenu(BuildContext context) {
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
            _menuItem(
              ctx,
              icon: Icons.calendar_today_outlined,
              label: 'Перенести',
              color: colors.onBackground,
              onTap: () => Navigator.pop(ctx),
            ),
            _menuItem(
              ctx,
              icon: Icons.close,
              label: 'Отменить бронь',
              color: colors.error,
              onTap: () => Navigator.pop(ctx),
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
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Models ─────────────────────────────────────────────────────────
enum OrderStatus { confirmed, cancelled }

class _Order {
  final OrderStatus status;
  final String time;
  final String date;
  final String branch;
  final String car;
  final String serviceType;
  final String paymentMethod;
  final String price;

  const _Order({
    required this.status,
    required this.time,
    required this.date,
    required this.branch,
    required this.car,
    required this.serviceType,
    required this.paymentMethod,
    required this.price,
  });
}