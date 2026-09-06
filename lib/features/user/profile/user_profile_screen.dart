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

  int _selectedPlanIndex = 1; // "3 Oy" default tanlangan

  static const List<_VipPlan> _plans = [
    _VipPlan(months: 6, perMonthK: 599, isBest: true),
    _VipPlan(months: 3, perMonthK: 839),
    _VipPlan(months: 1, perMonthK: _VipPlan.baseMonthlyPriceK),
  ];

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await _ordersRepo.loadOrders();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = _c;
    final name = _session.name ?? context.t.profile.guest;
    final phone = _session.phone ?? '—';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          context.t.profile.title,
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
          padding: const EdgeInsets.only(bottom: 100),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildProfileCard(colors, name, phone),
            _buildHeaderDivider(colors),
            const SizedBox(height: 20),
            _buildVipPassSection(colors),
            const SizedBox(height: 24),
            _buildSectionLabel(context.t.profile.myCarsLabel, colors),
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
                          context.t.settings.title,
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
          ],
        ),
      ),
    );
  }

  // ── Profil kartasi ──────────────────────────────────────────────
  Widget _buildProfileCard(
      ApparenceKitColors colors, String name, String phone) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _session.profileImage == null
                      ? LinearGradient(
                          colors: [
                            colors.premiumGradientStart,
                            colors.premiumGradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: colors.background, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onBackground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.auto_awesome,
                        color: colors.warning, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(phone,
                    style: TextStyle(color: colors.grey2, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.grey1.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t.profile.customerLevel,
                    style: TextStyle(
                      color: colors.grey3,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(UserRoutePath.editProfile),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.onPrimaryContainer,
                shape: BoxShape.circle,
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

  // ── VIP Pass obunasi bo'limi ────────────────────────────────────
  Widget _buildVipPassSection(ApparenceKitColors colors) {
    final t = context.t;
    final selected = _plans[_selectedPlanIndex];
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLight ? colors.surface : colors.onPrimaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.divider, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.grey1.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          for (int i = 0; i < _plans.length; i++) ...[
                            if (i > 0) const SizedBox(width: 4),
                            Expanded(child: _buildPlanOption(colors, i)),
                          ],
                        ],
                      ),
                    ),
                    Positioned(
                      top: -9,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.warning,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  t.profile.bestBadge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: colors.divider, height: 1),
                const SizedBox(height: 16),
                _buildPlanDetailsContent(colors, selected),
                const SizedBox(height: 12),
                Divider(color: colors.divider, height: 1),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.profile.comingSoon),
                        backgroundColor: colors.grey3,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.warning, colors.accent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          t.profile.activateVip.replaceAll(
                              '{months}', '${selected.months}'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
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
        ),
      ],
    );
  }

  Widget _buildPlanOption(ApparenceKitColors colors, int index) {
    final t = context.t;
    final plan = _plans[index];
    final isSelected = index == _selectedPlanIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.profile.monthShort
                  .replaceAll('{months}', '${plan.months}'),
              style: TextStyle(
                color: isSelected ? colors.onPrimary : colors.onBackground,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${plan.perMonthK}k / ${t.profile.perMonth}',
              style: TextStyle(
                color: isSelected
                    ? colors.onPrimary.withValues(alpha: 0.85)
                    : colors.grey2,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetailsContent(ApparenceKitColors colors, _VipPlan plan) {
    final t = context.t;
    final savingsText = plan.savings > 0
        ? '+${_formatPrice(plan.savings)} UZS'
        : '—';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.profile.monthlyPriceLabel,
                    style: TextStyle(color: colors.grey2, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_formatPrice(plan.perMonthK * 1000)} UZS',
                      style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    t.profile.savingLabel,
                    style: TextStyle(color: colors.grey2, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      savingsText,
                      style: TextStyle(
                        color: plan.savings > 0
                            ? colors.success
                            : colors.grey2,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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

  String _formatPrice(int sum) {
    final s = sum.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
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
                      context.t.profile.addCar,
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
                      context.t.profile.addCarButton,
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
              await _session.removeCar(car);
              if (mounted) setState(() {});
            },
            child: Text("O'chirish", style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }
}

class _VipPlan {
  static const int baseMonthlyPriceK = 1190; // 1 oylik narx (ming so'mda)

  final int months;
  final int perMonthK; // ming so'mda (599 → 599k)
  final bool isBest;

  const _VipPlan({
    required this.months,
    required this.perMonthK,
    this.isBest = false,
  });

  int get totalPrice => perMonthK * 1000 * months;
  int get savings => (baseMonthlyPriceK - perMonthK) * 1000 * months;
}
