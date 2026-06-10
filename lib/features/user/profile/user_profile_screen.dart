import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/services/client_session.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../shared/services/orders_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _session = ClientSession.instance;
  final _ordersRepo = OrdersRepository.instance;
  final _api = SupabaseService.instance;

  SubscriptionModel? _subscription;
  List<TariffPlanModel> _tariffPlans = [];
  bool _subLoading = true;

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  int get _completedCount =>
      _ordersRepo.cachedOrders.where((o) => o.isCompleted).length;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await Future.wait([
      _ordersRepo.loadOrders(),
      _loadSubscription(),
    ]);
    if (mounted) setState(() {});
  }

  Future<void> _loadSubscription() async {
    final customerId = _session.customerId;
    if (customerId == null) {
      _subLoading = false;
      return;
    }
    try {
      final results = await Future.wait([
        _api.getActiveSubscription(customerId),
        _api.getTariffPlans(),
      ]);
      _subscription = results[0] as SubscriptionModel?;
      _tariffPlans = results[1] as List<TariffPlanModel>;
    } catch (_) {
      _subscription = null;
      _tariffPlans = [];
    } finally {
      _subLoading = false;
    }
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
    final sub = _subscription;
    if (_subLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 64,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: colors.info),
          ),
        ),
      );
    }

    if (sub != null && sub.isValid) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.info, colors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.name,
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${sub.washesRemaining} ta yuvish qoldi',
                          style: TextStyle(
                            color: colors.onPrimary.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: sub.progress,
                  backgroundColor: colors.onPrimary.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Amal qiladi: ${_formatDate(sub.expiresAt)}',
                style: TextStyle(
                  color: colors.onPrimary.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              // TODO: membership sahifasiga
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B5EEA), Color(0xFF9B7BF5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium obuna',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Faol emas · 70% gacha tejang',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_tariffPlans.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Obuna rasmiylashtirish',
              style: TextStyle(
                color: colors.onBackground,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (int i = 0; i < _tariffPlans.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _buildTariffCard(colors: colors, plan: _tariffPlans[i]),
                ],
              ],
            ),
          ),
        ],
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

  String _formatDate(DateTime d) =>
      '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Widget _buildTariffCard({
    required ApparenceKitColors colors,
    required TariffPlanModel plan,
  }) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final isBest = plan.isPopular;

    return GestureDetector(
      onTap: () {
        // TODO: shu tarif bilan obuna qilish
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isBest
              ? const Color(0xFFFFA500)
              : (isLight ? colors.surface : colors.onPrimaryContainer),
          borderRadius: BorderRadius.circular(16),
          border: isBest
              ? null
              : Border.all(color: colors.divider, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isBest
                    ? Colors.white.withValues(alpha: 0.25)
                    : (isLight
                    ? colors.primary.withValues(alpha: 0.08)
                    : colors.grey1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child:
                Text(plan.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${plan.durationMonths} oy',
                        style: TextStyle(
                          color: isBest
                              ? Colors.white
                              : colors.onBackground,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isBest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Eng yaxshi narx',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Limitless yuvish · ${_formatPriceShort(plan.perMonthPrice)} / oy',
                    style: TextStyle(
                      color: isBest
                          ? Colors.white.withValues(alpha: 0.8)
                          : colors.grey2,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPriceShort(plan.price),
                  style: TextStyle(
                    color: isBest ? Colors.white : colors.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'jami',
                  style: TextStyle(
                    color: isBest
                        ? Colors.white.withValues(alpha: 0.7)
                        : colors.grey2,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPriceShort(int sum) {
    final s = sum.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return "${buf.toString()} so'm";
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
