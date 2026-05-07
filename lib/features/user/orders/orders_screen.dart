import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock orders
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

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.orders.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_active.length} активных · $_totalCount всего',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab bar ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2340),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: const Color(0xFF0D0D0D),
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Rounded',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SF Pro Rounded',
                  ),
                  tabs: const [
                    Tab(text: 'Активные'),
                    Tab(text: 'История'),
                    Tab(text: 'Отменённые'),
                  ],
                ),
              ),
            ),

            // ── Tab views ──────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(_active, emptyLabel: 'Нет активных заказов'),
                  _buildOrderList(_history,
                      emptyLabel: 'Завершённых заказов пока нет',
                      showBookButton: true),
                  _buildOrderList(_cancelled,
                      emptyLabel: 'Нет отменённых заказов'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Order list ─────────────────────────────────────────────────
  Widget _buildOrderList(
      List<_Order> orders, {
        required String emptyLabel,
        bool showBookButton = false,
      }) {
    if (orders.isEmpty) {
      return _buildEmpty(emptyLabel, showBookButton: showBookButton);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: orders.length,
      itemBuilder: (context, i) => _OrderCard(order: orders[i]),
    );
  }

  // ── Empty state ────────────────────────────────────────────────
  Widget _buildEmpty(String label, {bool showBookButton = false}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2340),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.calendar_today_outlined,
                color: Color(0xFF6B7280), size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 15,
            ),
          ),
          if (showBookButton) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go(UserRoutePath.booking),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Забронировать'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D9EFF),
                foregroundColor: Colors.white,
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

// ── Order card ─────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _Order order;

  @override
  Widget build(BuildContext context) {
    final statusColor = order.status == OrderStatus.confirmed
        ? const Color(0xFF4D9EFF)
        : const Color(0xFFEF4444);

    final statusLabel = order.status == OrderStatus.confirmed
        ? 'Подтверждено'
        : 'Отменено';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2340),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3560), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: status + menu ──────────────────────────
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
                if (order.status == OrderStatus.confirmed)
                  IconButton(
                    onPressed: () =>
                        _showOrderMenu(context, order),
                    icon: const Icon(Icons.more_horiz,
                        color: Color(0xFF6B7280), size: 20),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  order.date,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 15,
                  ),
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
                _infoRow(
                    Icons.access_time_outlined, order.serviceType),
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFF2A3560)),
          ),

          // ── Payment + price ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.paymentMethod,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
                Text(
                  order.price,
                  style: const TextStyle(
                    color: Colors.white,
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
        Icon(icon, color: const Color(0xFF6B7280), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  void _showOrderMenu(BuildContext context, _Order order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2340),
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
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
                color: const Color(0xFF2A3560),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _menuItem(
              ctx,
              icon: Icons.calendar_today_outlined,
              label: 'Перенести',
              onTap: () => Navigator.pop(ctx),
            ),
            _menuItem(
              ctx,
              icon: Icons.close,
              label: 'Отменить бронь',
              color: const Color(0xFFEF4444),
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
        Color? color,
      }) {
    final c = color ?? Colors.white;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                  color: c,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────
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