import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wash_club/config/router/router.dart';
import 'package:wash_club/core/i18n/translations.g.dart';
import '../../../../core/theme/colors.dart';
import '../../../core/theme/providers/theme_provider.dart';
import '../../../../shared/services/client_session.dart';
import '../../../../shared/services/branches_repository.dart';
import '../../../../shared/services/orders_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _promoNotifications   = false;

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  String get _currentLanguageName {
    final locale = LocaleSettings.currentLocale.languageCode;
    switch (locale) {
      case 'uz': return context.t.profile.languageUz;
      case 'ru': return context.t.profile.languageRu;
      default:   return context.t.profile.languageEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BuildContextTranslationsExtension(context).t;
    final colors = _c;

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
          t.settings.title,
          style: TextStyle(
            color: colors.onBackground,
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
          // ── Hisob ───────────────────────────────────────────────
          _sectionLabel(t.settings.account, colors),
          _settingsGroup([
            _navItem(
              icon: Icons.person_outline,
              label: t.settings.editProfile,
              onTap: () => context.push(UserRoutePath.editProfile),
              colors: colors,
            ),
            _navItem(
              icon: Icons.phone_outlined,
              label: t.settings.changePhone,
              onTap: () => _showChangePhone(context, colors),
              colors: colors,
            ),
          ], colors),
          const SizedBox(height: 24),

          // ── Ko'rinish ────────────────────────────────────────────
          _sectionLabel(t.settings.appearance, colors),
          _settingsGroup([_themeItem(t, colors)], colors),
          const SizedBox(height: 24),

          // ── Bildirishnomalar ─────────────────────────────────────
          _sectionLabel(t.settings.notifications, colors),
          _settingsGroup([
            _toggleItem(
              icon: Icons.notifications_outlined,
              label: t.settings.pushNotifications,
              subtitle: t.settings.pushSubtitle,
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
              colors: colors,
            ),
            _toggleItem(
              icon: Icons.auto_awesome_outlined,
              label: t.settings.promoNotifications,
              subtitle: t.settings.promoSubtitle,
              value: _promoNotifications,
              onChanged: (v) => setState(() => _promoNotifications = v),
              colors: colors,
            ),
          ], colors),
          const SizedBox(height: 24),

          // ── Til ──────────────────────────────────────────────────
          _sectionLabel(t.settings.language, colors),
          _settingsGroup([
            _navItem(
              icon: Icons.language_outlined,
              label: t.settings.appLanguage,
              trailing: _currentLanguageName,
              onTap: () => _showLanguageSheet(context, colors),
              colors: colors,
            ),
          ], colors),
          const SizedBox(height: 24),

          // ── Yordam ───────────────────────────────────────────────
          _sectionLabel(t.settings.support, colors),
          _settingsGroup([
            _navItem(
              icon: Icons.headset_mic_outlined,
              label: t.settings.contactSupport,
              onTap: () {},
              colors: colors,
            ),
            _navItem(
              icon: Icons.send_outlined,
              label: t.settings.telegramChannel,
              onTap: () {},
              colors: colors,
            ),
            _navItem(
              icon: Icons.star_outline,
              label: t.settings.rateApp,
              onTap: () {},
              colors: colors,
            ),
            _navItem(
              icon: Icons.description_outlined,
              label: t.settings.privacyPolicy,
              onTap: () {},
              colors: colors,
            ),
          ], colors),
          const SizedBox(height: 24),

          // ── Xavfli zona ──────────────────────────────────────────
          _sectionLabel(t.settings.dangerZone, colors),
          _settingsGroup([
            _navItem(
              icon: Icons.logout,
              label: t.settings.logout,
              labelColor: colors.error,
              iconColor: colors.error,
              showArrow: false,
              onTap: () => _showLogoutDialog(context, t, colors),
              colors: colors,
            ),
          ], colors),
          const SizedBox(height: 32),

          Center(
            child: Text(
              t.settings.version,
              style: TextStyle(color: colors.grey2, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────
  Widget _sectionLabel(String label, ApparenceKitColors colors) {
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

  Widget _settingsGroup(
      List<Widget> children, ApparenceKitColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.onPrimaryContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.grey1, width: 1),
        ),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(height: 1, color: colors.grey1, indent: 48),
            ],
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ApparenceKitColors colors,
    String? trailing,
    Color? labelColor,
    Color? iconColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? colors.grey2, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    color: labelColor ?? colors.onBackground,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            if (trailing != null) ...[
              Text(trailing,
                  style: TextStyle(color: colors.grey2, fontSize: 13)),
              const SizedBox(width: 4),
            ],
            if (showArrow)
              Icon(Icons.chevron_right, color: colors.grey2, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ApparenceKitColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: colors.grey2, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(color: colors.grey2, fontSize: 12)),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.info,
            activeTrackColor: colors.info.withValues(alpha: 0.3),
            inactiveThumbColor: colors.grey2,
            inactiveTrackColor: colors.grey1,
          ),
        ],
      ),
    );
  }

  Widget _themeItem(dynamic t, ApparenceKitColors colors) {
    final appTheme = ThemeProvider.of(context);
    final currentMode = switch (appTheme.mode) {
      ThemeMode.light  => 'light',
      ThemeMode.dark   => 'dark',
      ThemeMode.system => 'auto',
    };
    final themes = [
      {'key': 'light', 'icon': Icons.wb_sunny_outlined,
        'label': t.settings.themeLight as String},
      {'key': 'dark',  'icon': Icons.dark_mode_outlined,
        'label': t.settings.themeDark  as String},
      {'key': 'auto',  'icon': Icons.computer_outlined,
        'label': t.settings.themeAuto  as String},
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, color: colors.grey2, size: 20),
                const SizedBox(width: 12),
                Text(t.settings.theme as String,
                    style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: themes.map((theme) {
                final isSelected = currentMode == theme['key'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      switch (theme['key'] as String) {
                        case 'light':
                          appTheme.setMode(ThemeMode.light);
                          break;
                        case 'dark':
                          appTheme.setMode(ThemeMode.dark);
                          break;
                        case 'auto':
                          appTheme.setMode(ThemeMode.system);
                          break;
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.info : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(theme['icon'] as IconData,
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.grey2,
                              size: 18),
                          const SizedBox(height: 4),
                          Text(theme['label'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? colors.onPrimary
                                    : colors.grey2,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              )),
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

  void _showLanguageSheet(BuildContext context, ApparenceKitColors colors) {
    final languages = [
      {'code': 'uz', 'flag': '🇺🇿', 'name': "O'zbek",  'native': "O'zbekcha"},
      {'code': 'ru', 'flag': '🇷🇺', 'name': 'Русский', 'native': 'Русский язык'},
      {'code': 'en', 'flag': '🇬🇧', 'name': 'English', 'native': 'English'},
    ];
    String selected = LocaleSettings.currentLocale.languageCode;
    final t = BuildContextTranslationsExtension(context).t;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Text(t.settings.appLanguage,
                    style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                ...languages.map((lang) {
                  final isSelected = selected == lang['code'];
                  return GestureDetector(
                    onTap: () =>
                        setSheetState(() => selected = lang['code']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.15)
                            : colors.onPrimaryContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? colors.info : colors.grey1,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(lang['flag']!,
                              style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lang['name']!,
                                    style: TextStyle(
                                        color: isSelected
                                            ? colors.info
                                            : colors.onBackground,
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500)),
                                Text(lang['native']!,
                                    style: TextStyle(
                                        color: isSelected
                                            ? colors.info.withValues(alpha: 0.7)
                                            : colors.grey3,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: isSelected
                                ? Container(
                                    key: ValueKey(lang['code']),
                                    width: 24, height: 24,
                                    decoration: BoxDecoration(
                                      color: colors.info,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.check,
                                        color: colors.onPrimary, size: 14),
                                  )
                                : Container(
                                    key: ValueKey('empty_${lang['code']}'),
                                    width: 24, height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: colors.grey1, width: 1.5),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      await LocaleSettings.setLocaleRaw(selected);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('locale', selected);
                      setState(() {});
                      if (context.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.info,
                      foregroundColor: colors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(t.settings.confirm,
                        style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Chiqish: session + cache tozalash
  Future<void> _logout() async {
    // 1) Session tozalash
    await ClientSession.instance.clear();

    // 2) Cache tozalash
    OrdersRepository.instance.invalidate();
    BranchesRepository.instance.invalidate();

    if (mounted) context.go(UserRoutePath.otpLogin);
  }

  void _showChangePhone(
      BuildContext context, ApparenceKitColors colors) {
    final session = ClientSession.instance;
    final phoneCtrl = TextEditingController(text: session.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20,
            MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text(context.t.settings.phoneChange,
                style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                labelText: context.t.settings.phoneLabel,
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
                  final newPhone = phoneCtrl.text.trim();
                  if (newPhone.length < 9) return;
                  await session.saveProfile(
                    name: session.name ?? '',
                    phone: newPhone,
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
                child: Text(context.t.settings.save,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, dynamic t, ApparenceKitColors colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.onPrimaryContainer,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(t.settings.logoutTitle as String,
            style: TextStyle(color: colors.onBackground, fontSize: 17)),
        content: Text(t.settings.logoutBody as String,
            style: TextStyle(color: colors.grey2, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.settings.cancel as String,
                style: TextStyle(color: colors.info)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logout();
            },
            child: Text(t.settings.confirm as String,
                style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }
}

