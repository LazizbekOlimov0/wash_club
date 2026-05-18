import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String _userName = 'Bobur';
  static const String _userPhone = '+998 97 520 40 60';
  static const int _washCount = 2;
  static const int _savedAmount = 18000;
  static const String _level = 'Bronze';

  ApparenceKitColors _colors(BuildContext context) =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = _colors(context);

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
            icon: Icon(Icons.more_horiz, color: colors.onBackground, size: 24),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          _buildHeader(colors),
          const SizedBox(height: 16),
          _buildStatsRow(colors),
          const SizedBox(height: 12),
          _buildSubscriptionBanner(colors),
          const SizedBox(height: 24),
          _buildSectionLabel('МОИ МАШИНЫ', colors),
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
                        'Настройки',
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
    );
  }

  Widget _buildHeader(ApparenceKitColors colors) {
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
                _userName[0].toUpperCase(),
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
                  _userName,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userPhone,
                  style: TextStyle(color: colors.grey2, fontSize: 14),
                ),
              ],
            ),
          ),
          // Edit button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.onPrimaryContainer,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.grey1, width: 1),
            ),
            child: Icon(Icons.edit_outlined, color: colors.grey2, size: 18),
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
            _statItem('$_washCount', 'МОЕК', colors: colors),
            _statDivider(colors),
            _statItem('$_savedAmount', 'СЭКОНОМЛЕНО', colors: colors),
            _statDivider(colors),
            _statItem(_level, 'УРОВЕНЬ',
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
          Text(
            label,
            style: TextStyle(color: colors.grey2, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _statDivider(ApparenceKitColors colors) {
    return Container(width: 1, height: 32, color: colors.grey1);
  }

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
                    'Подписка не активна',
                    style: TextStyle(
                      color: colors.onBackground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Экономьте до 70% с Wash Club',
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
                      'Добавить',
                      style: TextStyle(
                        color: colors.info,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
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
                        'Chevrolet Malibu',
                        style: TextStyle(
                          color: colors.onBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '01 U 571 QA · Qora',
                        style: TextStyle(
                            color: colors.grey2, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.delete_outline,
                      color: colors.grey2, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}