import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/services/client_session.dart';
import '../../../../shared/services/orders_repository.dart';
import 'vip_plan.dart';

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
            icon: Icon(Icons.settings_outlined,
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

  // ── VIP Pass obunasi bo'limi (teaser karta) ─────────────────────
  Widget _buildVipPassSection(ApparenceKitColors colors) {
    final t = context.t;
    final cheapest = vipPlans.reduce(
      (a, b) => a.perMonthK < b.perMonthK ? a : b,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sarlavha qatori: bo'lim nomi + "Barcha obunalar >"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.subscriptions.title,
                style: TextStyle(
                  color: colors.grey2,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(UserRoutePath.subscriptions),
                child: Row(
                  children: [
                    Text(
                      t.subscriptions.all,
                      style: TextStyle(
                        color: colors.info,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: colors.info, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Teaser karta
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => context.push(UserRoutePath.subscriptions),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.premiumGradientStart,
                    colors.premiumGradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.workspace_premium,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.profile.vipPassTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.subscriptions.fromPrice.replaceAll(
                        '{price}', formatPrice(cheapest.monthlyPrice)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _benefitDot(),
                      const SizedBox(width: 8),
                      Text(
                        t.profile.featureUnlimited,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _benefitDot(),
                      const SizedBox(width: 8),
                      Text(
                        t.profile.featureAllBranches,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t.subscriptions.view,
                      style: TextStyle(
                        color: colors.premiumGradientEnd,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _benefitDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
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
