import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wash_club/config/router/router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _promoNotifications = false;
  String _themeMode = 'dark';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
        ),
        title: const Text(
          'Настройки',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        physics: const ClampingScrollPhysics(),
        children: [
          // ── Аккаунт ───────────────────────────────────────────
          _sectionLabel('АККАУНТ'),
          _settingsGroup([
            _navItem(
              icon: Icons.person_outline,
              label: 'Редактировать профиль',
              onTap: () {},
            ),
            _navItem(
              icon: Icons.phone_outlined,
              label: 'Изменить номер телефона',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),

          // ── Внешний вид ───────────────────────────────────────
          _sectionLabel('ВНЕШНИЙ ВИД'),
          _settingsGroup([
            _themeItem(),
          ]),
          const SizedBox(height: 24),

          // ── Уведомления ───────────────────────────────────────
          _sectionLabel('УВЕДОМЛЕНИЯ'),
          _settingsGroup([
            _toggleItem(
              icon: Icons.notifications_outlined,
              label: 'Push-уведомления',
              subtitle: 'Бронь, статус и напоминания',
              value: _notificationsEnabled,
              onChanged: (v) =>
                  setState(() => _notificationsEnabled = v),
            ),
            _toggleItem(
              icon: Icons.auto_awesome_outlined,
              label: 'Промо-уведомления',
              subtitle: 'Акции и специальные предложения',
              value: _promoNotifications,
              onChanged: (v) =>
                  setState(() => _promoNotifications = v),
            ),
          ]),
          const SizedBox(height: 24),

          // ── Язык ─────────────────────────────────────────────
          _sectionLabel('ЯЗЫК'),
          _settingsGroup([
            _navItem(
              icon: Icons.language_outlined,
              label: 'Язык приложения',
              trailing: 'Русский',
              onTap: () => context.push(UserRoutePath.language),
            ),
          ]),
          const SizedBox(height: 24),

          // ── История ──────────────────────────────────────────
          _sectionLabel('ИСТОРИЯ'),
          _settingsGroup([
            _navItem(
              icon: Icons.history_outlined,
              label: 'История посещений',
              onTap: () {},
            ),
            _navItem(
              icon: Icons.receipt_long_outlined,
              label: 'История платежей',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),

          // ── Поддержка ─────────────────────────────────────────
          _sectionLabel('ПОДДЕРЖКА'),
          _settingsGroup([
            _navItem(
              icon: Icons.headset_mic_outlined,
              label: 'Связаться с поддержкой',
              onTap: () {},
            ),
            _navItem(
              icon: Icons.send_outlined,
              label: 'Telegram канал',
              onTap: () {},
            ),
            _navItem(
              icon: Icons.star_outline,
              label: 'Оценить приложение',
              onTap: () {},
            ),
            _navItem(
              icon: Icons.description_outlined,
              label: 'Политика конфиденциальности',
              onTap: () {},
            ),
            _navItem(
              icon: Icons.gavel_outlined,
              label: 'Пользовательское соглашение',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),

          // ── Аккаунт — опасная зона ────────────────────────────
          _sectionLabel('АККАУНТ'),
          _settingsGroup([
            _navItem(
              icon: Icons.logout,
              label: 'Выйти из аккаунта',
              labelColor: const Color(0xFFEF4444),
              iconColor: const Color(0xFFEF4444),
              showArrow: false,
              onTap: () => _showLogoutDialog(context),
            ),
            _navItem(
              icon: Icons.delete_outline,
              label: 'Удалить аккаунт',
              labelColor: const Color(0xFFEF4444),
              iconColor: const Color(0xFFEF4444),
              showArrow: false,
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ]),
          const SizedBox(height: 32),

          // ── Version ───────────────────────────────────────────
          const Center(
            child: Text(
              'Wash Club · v1.0.0',
              style: TextStyle(color: Color(0xFF4B5563), fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Group container ────────────────────────────────────────────
  Widget _settingsGroup(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2340),
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: const Color(0xFF2A3560), width: 1),
        ),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                const Divider(
                    height: 1,
                    color: Color(0xFF2A3560),
                    indent: 48),
            ],
          ],
        ),
      ),
    );
  }

  // ── Nav item ───────────────────────────────────────────────────
  Widget _navItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? trailing,
    Color? labelColor,
    Color? iconColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: iconColor ?? const Color(0xFF9CA3AF),
                size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing,
                style: const TextStyle(
                    color: Color(0xFF6B7280), fontSize: 13),
              ),
              const SizedBox(width: 4),
            ],
            if (showArrow)
              const Icon(Icons.chevron_right,
                  color: Color(0xFF4B5563), size: 18),
          ],
        ),
      ),
    );
  }

  // ── Toggle item ────────────────────────────────────────────────
  Widget _toggleItem({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4D9EFF),
            activeTrackColor:
            const Color(0xFF4D9EFF).withValues(alpha: 0.3),
            inactiveThumbColor: const Color(0xFF6B7280),
            inactiveTrackColor: const Color(0xFF2A3560),
          ),
        ],
      ),
    );
  }

  // ── Theme item ─────────────────────────────────────────────────
  Widget _themeItem() {
    final themes = [
      {
        'key': 'light',
        'icon': Icons.wb_sunny_outlined,
        'label': 'Светлая'
      },
      {
        'key': 'dark',
        'icon': Icons.dark_mode_outlined,
        'label': 'Тёмная'
      },
      {
        'key': 'auto',
        'icon': Icons.computer_outlined,
        'label': 'Авто'
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Icon(Icons.palette_outlined,
                    color: Color(0xFF9CA3AF), size: 20),
                SizedBox(width: 12),
                Text(
                  'Тема оформления',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: themes.map((theme) {
                final isSelected = _themeMode == theme['key'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                            () => _themeMode = theme['key'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4D9EFF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            theme['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6B7280),
                            size: 18,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme['label'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2340),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Выйти из аккаунта?',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        content: const Text(
          'Вы уверены, что хотите выйти?',
          style:
          TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена',
                style: TextStyle(color: Color(0xFF4D9EFF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(UserRoutePath.login);
            },
            child: const Text('Выйти',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2340),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Удалить аккаунт?',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        content: const Text(
          'Все данные будут безвозвратно удалены. Это действие нельзя отменить.',
          style:
          TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена',
                style: TextStyle(color: Color(0xFF4D9EFF))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Удалить',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}