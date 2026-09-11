import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import 'package:wash_club/core/theme/colors.dart';

import 'vip_plan.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ApparenceKitColors>()!;
    final t = context.t;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new,
              color: colors.onBackground, size: 18),
        ),
        title: Text(
          t.subscriptions.title,
          style: TextStyle(
            color: colors.onBackground,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: vipPlans.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, i) =>
            _PlanCard(plan: vipPlans[i], colors: colors),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.colors});

  final VipPlan plan;
  final ApparenceKitColors colors;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final hasDiscount = plan.discountPercent > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? colors.surface
            : colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.isBest ? colors.warning : colors.divider,
          width: plan.isBest ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Chap: muddat, narx, moyka soni ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          t.subscriptions
                              .monthDuration
                              .replaceAll('{months}', '${plan.months}'),
                          style: TextStyle(
                            color: colors.onBackground,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (hasDiscount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.successSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${plan.discountPercent}%',
                              style: TextStyle(
                                color: colors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        if (plan.isBest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.warning,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t.profile.bestBadge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            '${formatPrice(plan.totalPrice)} so\'m',
                            style: TextStyle(
                              color: colors.onBackground,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            t.subscriptions
                                .perMonths
                                .replaceAll('{months}', '${plan.months}'),
                            style: TextStyle(
                              color: colors.grey2,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${formatPrice(plan.originalPrice)} so\'m',
                        style: TextStyle(
                          color: colors.grey2,
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.water_drop_outlined,
                            color: colors.info, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          t.profile.washCountLabel
                              .replaceAll('{count}', '${plan.washCount}'),
                          style: TextStyle(
                            color: colors.onBackground,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ── O'ng: rangli gradient badge ──
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _badgeGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${plan.washCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: 12),
          _buildBenefits(context, colors),
          const SizedBox(height: 16),
          // ── Sotib olish tugmasi ──
          GestureDetector(
            onTap: () =>
                context.push(UserRoutePath.payment, extra: plan.months),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.warning, colors.accent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                t.subscriptions.buy,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> get _badgeGradient {
    switch (plan.months) {
      case 6:
        return [colors.premiumGradientStart, colors.premiumGradientEnd];
      case 3:
        return const [Color(0xFF00B894), Color(0xFF55EFC4)];
      default:
        return const [Color(0xFF7F8FA6), Color(0xFF576574)];
    }
  }

  Widget _buildBenefits(BuildContext context, ApparenceKitColors colors) {
    final t = context.t;
    final benefits = [
      t.subscriptions.benefitDailyWash,
      t.subscriptions.benefitCountrywide,
      t.subscriptions.benefitPremium,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < benefits.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: colors.success, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  benefits[i],
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
