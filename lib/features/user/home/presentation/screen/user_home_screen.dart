import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // Mock data — backenddan keladi
  final bool _hasBooking = true;
  final String _userName = 'Bobur';
  final String _userPhone = '+998 91 048 02 44';
  final String _weather = '+18°';

  final List<Map<String, dynamic>> _promotions = [
    {
      'tag': '–15% ВЕСЬ АПРЕЛЬ',
      'title': 'Премиум-детейлинг',
      'button': 'Подробнее',
      'gradient': [Color(0xFFD4632A), Color(0xFFE8A020)],
    },
    {
      'tag': 'ПРОМОКОД WEEKDAY',
      'title': '–20% по будням',
      'button': 'Активировать',
      'gradient': [Color(0xFF1A237E), Color(0xFF00BCD4)],
    },
    {
      'tag': '–10% ОБОИМ ЗА РЕФЕРАЛА',
      'title': 'Приведи друга',
      'button': 'Поделиться',
      'gradient': [Color(0xFF6A1B9A), Color(0xFFCE93D8)],
    },
  ];

  final List<Map<String, dynamic>> _branches = [
    {
      'name': 'Wash Club Yunusobod',
      'address': 'Yunusobod tumani, Amir Temur ko\'chasi 108',
      'rating': '4.9',
      'distance': '1.2 km',
      'hours': '08:00 — 22:00',
      'isOpen': true,
    },
    {
      'name': 'Wash Club Chilonzor',
      'address': 'Chilonzor tumani, Bunyodkor shoh...',
      'rating': '4.8',
      'distance': '3.8 km',
      'hours': '07:00 — 23:00',
      'isOpen': true,
    },
    {
      'name': 'Wash Club Mirzo Ulug\'bek',
      'address': 'Mirzo Ulug\'bek tumani',
      'rating': '4.7',
      'distance': '5.1 km',
      'hours': '09:00 — 21:00',
      'isOpen': false,
    },
  ];

  final List<Map<String, dynamic>> _cars = [
    {'name': 'Chevrolet Malibu', 'plate': '01 U 571 QA', 'color': 'Qora'},
  ];

  String _greeting(BuildContext context) {
    final t = context.t;
    final hour = DateTime.now().hour;
    if (hour < 12) return t.home.goodMorning;
    if (hour < 18) return t.home.goodAfternoon;
    return t.home.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          _buildHeader(context),
          if (_hasBooking) ...[
            const SizedBox(height: 16),
            _buildBookingCard(context),
          ],
          const SizedBox(height: 24),
          _buildPromotions(context),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildBranches(context),
          const SizedBox(height: 24),
          _buildMyCars(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final t = context.t;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(color: Color(0xFF0D0D0D)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: greeting + name + phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(context),
                  style: const TextStyle(
                    fontFamily: 'SF Pro Rounded',
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Rounded',
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: weather + notification
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 4,
            children: [
              // Weather chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x22FFFFFF),
                  borderRadius: BorderRadius.circular(200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wb_sunny_outlined,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _weather,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Rounded',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
                    color: const Color(0x22FFFFFF),
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      // Red dot
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
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
        ],
      ),
    );
  }

  // ── Booking card ──────────────────────────────────────────────────
  Widget _buildBookingCard(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2340),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.home.nearestBooking,
              style: const TextStyle(
                color: Color(0xFF4D9EFF),
                fontFamily: 'SF Pro Rounded',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '10:00',
                  style: TextStyle(
                    fontFamily: 'SF Pro Rounded',
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3560),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '2026-05-03 · ${t.home.now}',
              style: const TextStyle(
                fontFamily: 'SF Pro Rounded',
                color: Color(0xFF9EA3AE),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0x22FFFFFF), height: 1),
            const SizedBox(height: 16),
            _bookingRow(
              icon: Icons.location_on_outlined,
              title: 'Wash Club Yunusobod',
              subtitle: 'Yunusobod tumani, Amir Temur ko\'chasi 108',
            ),
            const SizedBox(height: 10),
            _bookingRow(
              icon: Icons.directions_car_outlined,
              title: 'Chevrolet Malibu · 01 U 571 QA',
              subtitle: t.home.standard,
            ),
            const SizedBox(height: 10),
            _bookingRow(
              icon: Icons.access_time_outlined,
              title: '${t.home.paymentMethod}: ${t.home.card}',
              subtitle: null,
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0x22FFFFFF), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      spacing: 12,
                      children: [
                        Icon(Icons.date_range, color: Colors.white, size: 20),
                        Text(
                          t.home.change,
                          style: TextStyle(
                            fontFamily: 'SF Pro Rounded',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      spacing: 12,
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                          size: 20,
                        ),
                        Text(
                          t.home.cancel,
                          style: TextStyle(
                            fontFamily: 'SF Pro Rounded',
                            color: Colors.red,
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

  Widget _bookingRow({
    required IconData icon,
    required String title,
    required String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF9EA3AE), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SF Pro Rounded',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Rounded',
                    color: Color(0xFF9EA3AE),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Promotions ────────────────────────────────────────────────────
  Widget _buildPromotions(BuildContext context) {
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
                t.home.promotions,
                style: const TextStyle(
                  fontFamily: 'SF Pro Rounded',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  t.home.seeAll,

                  style: const TextStyle(
                    fontFamily: 'SF Pro Rounded',
                    color: Color(0xFF4D9EFF),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _promotions.length,
            itemBuilder: (context, i) {
              final p = _promotions[i];
              final colors = (p['gradient'] as List).cast<Color>();
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['tag'],
                      style: TextStyle(
                        fontFamily: 'SF Pro Rounded',
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p['title'],
                      style: const TextStyle(
                        fontFamily: 'SF Pro Rounded',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x33000000),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p['button'],
                        style: const TextStyle(
                          fontFamily: 'SF Pro Rounded',
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Quick actions ─────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    final t = context.t;
    final actions = [
      {'icon': Icons.calendar_today_outlined, 'label': t.home.book},
      {'icon': Icons.location_on_outlined, 'label': t.home.branches},
      {'icon': Icons.history_outlined, 'label': t.home.history},
      {'icon': Icons.help_outline, 'label': t.home.help},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2340),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    a['icon'] as IconData,
                    color: const Color(0xFF4D9EFF),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  a['label'] as String,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Rounded',
                    color: Color(0xFF9EA3AE),
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
  Widget _buildBranches(BuildContext context) {
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
                t.home.nearestBranches,
                style: const TextStyle(
                  fontFamily: 'SF Pro Rounded',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  t.home.seeAll,
                  style: const TextStyle(color: Color(0xFF4D9EFF)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _branches.length,
            itemBuilder: (context, i) {
              final b = _branches[i];
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2340),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image placeholder
                    Stack(
                      children: [
                        Container(
                          height: 110,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A3560),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.local_car_wash,
                              color: Color(0xFF4D9EFF),
                              size: 40,
                            ),
                          ),
                        ),
                        if (b['isOpen'] as bool)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34C759),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.home.open,
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Rounded',
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  b['name'],
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro Rounded',
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFB800),
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                b['rating'],
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Rounded',
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF9EA3AE),
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  b['address'],
                                  style: const TextStyle(
                                    color: Color(0xFF9EA3AE),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_outlined,
                                    color: Color(0xFF9EA3AE),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    b['hours'],
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro Rounded',
                                      color: Color(0xFF9EA3AE),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                b['distance'],
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Rounded',
                                  color: Color(0xFF4D9EFF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── My Cars ───────────────────────────────────────────────────────
  Widget _buildMyCars(BuildContext context) {
    final t = context.t;
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
                style: const TextStyle(
                  fontFamily: 'SF Pro Rounded',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push(UserRoutePath.addCar),
                icon: const Icon(Icons.add, color: Color(0xFF4D9EFF), size: 18),
                label: Text(
                  t.home.manage,
                  style: const TextStyle(color: Color(0xFF4D9EFF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._cars.map((car) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2340),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3560),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car_outlined,
                      color: Color(0xFF4D9EFF),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car['name'],
                          style: const TextStyle(
                            fontFamily: 'SF Pro Rounded',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${car['plate']} · ${car['color']}',
                          style: const TextStyle(
                            fontFamily: 'SF Pro Rounded',
                            color: Color(0xFF9EA3AE),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9EA3AE),
                    size: 20,
                  ),
                ],
              ),
            );
          }),
          // Add car button
          GestureDetector(
            onTap: () => context.push(UserRoutePath.addCar),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2340),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2A3560), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF4D9EFF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.home.addCar,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Rounded',
                      color: Color(0xFF4D9EFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
}
