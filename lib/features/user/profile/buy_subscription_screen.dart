import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import 'package:wash_club/core/theme/colors.dart';
import 'package:wash_club/core/widgets/top_banner.dart';

import 'vip_plan.dart';

class BuySubscriptionScreen extends StatefulWidget {
  const BuySubscriptionScreen({super.key, required this.plan});

  final VipPlan plan;

  @override
  State<BuySubscriptionScreen> createState() => _BuySubscriptionScreenState();
}

class _BuySubscriptionScreenState extends State<BuySubscriptionScreen> {
  DateTime _activationDate = DateTime.now();
  int _selectedPayment = 0;
  final _promoController = TextEditingController();

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _c;
    final t = context.t;
    final plan = widget.plan;

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
          t.buySubscription.title,
          style: TextStyle(
            color: colors.onBackground,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        physics: const ClampingScrollPhysics(),
        children: [
          _buildSummaryCard(colors, plan),
          const SizedBox(height: 24),
          _buildSectionLabel(t.buySubscription.activationDate, colors),
          _buildDateField(colors),
          const SizedBox(height: 16),
          _buildPromoField(colors),
          const SizedBox(height: 24),
          _buildSectionLabel(t.buySubscription.paymentMethod, colors),
          _buildPaymentOptions(colors),
          const SizedBox(height: 24),
          _buildPriceDetails(colors, plan),
          const SizedBox(height: 24),
          _buildPayButton(colors),
        ],
      ),
    );
  }

  // ── Tarif xulosasi ─────────────────────────────────────────────
  Widget _buildSummaryCard(ApparenceKitColors colors, VipPlan plan) {
    final t = context.t;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? colors.surface
            : colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _badgeGradient(colors),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '${plan.washCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.buySubscription.planName
                      .replaceAll('{months}', '${plan.months}'),
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatPrice(plan.totalPrice)} so\'m',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.buySubscription.daysWashes.replaceAll(
                    '{days}', '${plan.days}').replaceAll(
                    '{count}', '${plan.washCount}'),
                  style: TextStyle(color: colors.grey2, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.successSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    t.buySubscription.unlimitedChip,
                    style: TextStyle(
                      color: colors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  // ── Sana maydoni ───────────────────────────────────────────────
  Widget _buildDateField(ApparenceKitColors colors) {
    final formatted =
        MaterialLocalizations.of(context).formatMediumDate(_activationDate);

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? colors.surface
              : colors.onPrimaryContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.grey1, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                formatted,
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.calendar_today_outlined,
                color: colors.grey2, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _activationDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _activationDate = picked);
  }

  // ── Promokod ───────────────────────────────────────────────────
  Widget _buildPromoField(ApparenceKitColors colors) {
    return TextField(
      controller: _promoController,
      style: TextStyle(color: colors.onBackground, fontSize: 14),
      decoration: InputDecoration(
        hintText: context.t.buySubscription.promoCode,
        hintStyle: TextStyle(color: colors.grey2, fontSize: 14),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.light
            ? colors.surface
            : colors.onPrimaryContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.grey1, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }

  // ── To'lov usullari ────────────────────────────────────────────
  Widget _buildPaymentOptions(ApparenceKitColors colors) {
    final t = context.t;
    final methods = [
      (t.buySubscription.payme, Icons.payment_outlined),
      (t.buySubscription.click, Icons.account_balance_wallet_outlined),
      (t.buySubscription.card, Icons.credit_card_outlined),
    ];

    return Column(
      children: [
        for (int i = 0; i < methods.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _selectedPayment = i),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? colors.surface
                    : colors.onPrimaryContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedPayment == i
                      ? colors.primary
                      : colors.grey1,
                  width: _selectedPayment == i ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(methods[i].$2, color: colors.grey2, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      methods[i].$1,
                      style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _selectedPayment == i
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _selectedPayment == i
                        ? colors.primary
                        : colors.grey2,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Narx tafsiloti ─────────────────────────────────────────────
  Widget _buildPriceDetails(ApparenceKitColors colors, VipPlan plan) {
    final t = context.t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(t.buySubscription.price, colors),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? colors.surface
                : colors.onPrimaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.divider, width: 1),
          ),
          child: Column(
            children: [
              _priceRow(
                t.buySubscription.subscriptionPrice,
                '${formatPrice(plan.totalPrice)} so\'m',
                colors,
              ),
              const SizedBox(height: 12),
              _priceRow(t.buySubscription.promo, '- 0 so\'m', colors),
              const SizedBox(height: 12),
              Divider(color: colors.divider, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.buySubscription.totalPayment,
                      style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${formatPrice(plan.totalPrice)} so\'m',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value, ApparenceKitColors colors) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: colors.grey2, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.onBackground,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── To'lov qilish ──────────────────────────────────────────────
  Widget _buildPayButton(ApparenceKitColors colors) {
    return GestureDetector(
      onTap: _onPay,
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
        alignment: Alignment.center,
        child: Text(
          context.t.buySubscription.payButton,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _onPay() async {
    final t = context.t;
    final colors = _c;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.onPrimaryContainer,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t.buySubscription.confirmTitle,
            style: TextStyle(color: colors.onBackground)),
        content: Text(t.buySubscription.confirmMessage,
            style: TextStyle(color: colors.grey2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.buySubscription.confirmNo,
                style: TextStyle(color: colors.info)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.buySubscription.confirmYes,
                style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final title = t.buySubscription.purchasedTitle
        .replaceAll('{months}', '${widget.plan.months}');
    final subtitle = t.buySubscription.purchasedSubtitle
        .replaceAll('{count}', '${widget.plan.washCount}');

    context.go(UserRoutePath.home);
    TopBannerBus.publish(TopBannerMessage(title: title, subtitle: subtitle));
  }

  // ── Yordamchilar ───────────────────────────────────────────────
  Widget _buildSectionLabel(String label, ApparenceKitColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
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

  List<Color> _badgeGradient(ApparenceKitColors colors) {
    switch (widget.plan.months) {
      case 6:
        return [colors.premiumGradientStart, colors.premiumGradientEnd];
      case 3:
        return const [Color(0xFF00B894), Color(0xFF55EFC4)];
      default:
        return const [Color(0xFF7F8FA6), Color(0xFF576574)];
    }
  }
}
