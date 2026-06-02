import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/services/client_session.dart';
import '../../../../shared/services/orders_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _session = ClientSession.instance;
  final _ordersRepo = OrdersRepository.instance;

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  int get _completedCount =>
      _ordersRepo.cachedOrders.where((o) => o.isCompleted).length;

  Future<void> _refresh() async {
    await _ordersRepo.loadOrders();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = _c;
    final name  = _session.name  ?? 'Mehmon';
    final phone = _session.phone ?? '—';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          t.profile.title,
          style: TextStyle(
            color: colors.onBackground,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push(UserRoutePath.settings),
            icon: Icon(Icons.more_horiz,
                color: colors.onBackground, size: 24),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: colors.info,
        child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildHeader(colors, name, phone),
          _buildHeaderDivider(colors),
          const SizedBox(height: 20),
          _buildStatsRow(colors),
          const SizedBox(height: 12),
          _buildSubscriptionBanner(colors),
          const SizedBox(height: 24),
          _buildSectionLabel('MENING MASHINALARIM', colors),
          _buildMyCars(context, colors),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => context.push(UserRoutePath.settings),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colors.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.grey1, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined,
                        color: colors.grey2, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sozlamalar',
                        style: TextStyle(
                          color: colors.onBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: colors.grey2, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Wash Club · v1.0.0',
              style: TextStyle(color: colors.grey2, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader(
      ApparenceKitColors colors, String name, String phone) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push(UserRoutePath.editProfile),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                image: _session.profileImage != null
                    ? DecorationImage(
                        image: MemoryImage(
                            base64Decode(_session.profileImage!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _session.profileImage == null
                  ? Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'M',
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(phone,
                    style: TextStyle(color: colors.grey2, fontSize: 14)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(UserRoutePath.editProfile),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.onPrimaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.grey1, width: 1),
              ),
              child: Icon(Icons.edit_outlined,
                  color: colors.grey2, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderDivider(ApparenceKitColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: colors.divider, height: 1, thickness: 1),
    );
  }

  Widget _buildStatsRow(ApparenceKitColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.onPrimaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.grey1, width: 1),
        ),
        child: Row(
          children: [
            _statItem(
                '$_completedCount', "YUVILGAN", colors: colors),
            _statDivider(colors),
            _statItem(
                _session.cars.length.toString(), "MASHINA", colors: colors),
            _statDivider(colors),
            _statItem('Bronze', "DARAJA",
                colors: colors, valueColor: colors.info),
          ],
        ),
      ),
    );
  }

  Widget _statItem(
    String value,
    String label, {
    required ApparenceKitColors colors,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? colors.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: colors.grey2, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _statDivider(ApparenceKitColors colors) =>
      Container(width: 1, height: 32, color: colors.grey1);

  Widget _buildSubscriptionBanner(ApparenceKitColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.onPrimaryContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.grey1, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Text('👑', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Obuna faol emas',
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Wash Club bilan 70% tejang',
                    style: TextStyle(color: colors.grey2, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.grey2, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, ApparenceKitColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        label,
        style: TextStyle(
          color: colors.grey2,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMyCars(BuildContext context, ApparenceKitColors colors) {
    final cars = _session.cars;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => context.push(UserRoutePath.addCar),
                child: Row(
                  children: [
                    Icon(Icons.add, color: colors.info, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "Qo'shish",
                      style: TextStyle(
                          color: colors.info,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (cars.isEmpty)
            GestureDetector(
              onTap: () => context.push(UserRoutePath.addCar),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: colors.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.grey1, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: colors.info, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Mashina qo'shing",
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
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.grey1, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.grey1,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              car.color.isNotEmpty
                                  ? '${car.plate} · ${car.color}'
                                  : car.plate,
                              style: TextStyle(
                                  color: colors.grey2, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _confirmDeleteCar(context, car, colors),
                        icon: Icon(Icons.delete_outline,
                            color: colors.grey2, size: 20),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  void _confirmDeleteCar(
      BuildContext context, SavedCar car, ApparenceKitColors colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.onPrimaryContainer,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Mashina o'chirish",
            style: TextStyle(color: colors.onBackground)),
        content: Text('${car.displayName} (${car.plate}) ni o\'chirmoqchimisiz?',
            style: TextStyle(color: colors.grey2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Bekor", style: TextStyle(color: colors.info)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _session.removeCar(car.plate);
              if (mounted) setState(() {});
            },
            child: Text("O'chirish", style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }
}
