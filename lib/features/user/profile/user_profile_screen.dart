import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/services/client_session.dart';
import '../../../data/repositories/orders_repository.dart';

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
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  int get _completedCount =>
      _ordersRepo.cachedOrders.where((o) => o.isCompleted).length;

  Future<void> _refresh() async {
    await _ordersRepo.loadOrders(forceRefresh: true);
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
        physics: const ClampingScrollPhysics(),
        children: [
          _buildHeader(colors, name, phone),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'M',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          // Edit button
          GestureDetector(
            onTap: () => _showEditProfile(context, colors),
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

  void _showEditProfile(BuildContext context, ApparenceKitColors colors) {
    final nameCtrl  = TextEditingController(text: _session.name);
    final phoneCtrl = TextEditingController(text: _session.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20, 20, 20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: colors.grey1,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Profilni tahrirlash',
                style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                labelText: 'Ism',
                labelStyle: TextStyle(color: colors.grey2),
                filled: true,
                fillColor: colors.onPrimaryContainer,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                labelText: 'Telefon',
                labelStyle: TextStyle(color: colors.grey2),
                filled: true,
                fillColor: colors.onPrimaryContainer,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  await _session.saveProfile(
                    name:  nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  if (mounted) setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.info,
                  foregroundColor: colors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Saqlash',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
