import 'package:flutter/material.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

import '../../../../../../core/theme/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<_NotifItem> _notifications = [
    _NotifItem(
      type: NotifType.booking,
      title: 'Bron tasdiqlandi',
      body: 'Wash Club Yunusobod · 10:00 · 2026-05-03',
      time: '2 daqiqa oldin',
      isRead: false,
    ),
    _NotifItem(
      type: NotifType.promo,
      title: '–15% Premium-detailing',
      body: 'Butun aprel davomida aksiya. Hoziroq foydalaning!',
      time: '1 soat oldin',
      isRead: false,
    ),
    _NotifItem(
      type: NotifType.promo,
      title: 'Promo-kod WEEKDAY',
      body: 'Hafta kunlari –20% chegirma. Aktiv qiling!',
      time: '3 soat oldin',
      isRead: true,
    ),
    _NotifItem(
      type: NotifType.system,
      title: 'Ilovaga xush kelibsiz!',
      body:
      'Wash Club ilovasini yuklab oldingiz. Birinchi broningizni qiling.',
      time: 'Kecha',
      isRead: true,
    ),
    _NotifItem(
      type: NotifType.booking,
      title: 'Bron yakunlandi',
      body: 'Wash Club Chilonzor · 15:00 · 2026-05-02',
      time: '2 kun oldin',
      isRead: true,
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = Theme.of(context).extension<ApparenceKitColors>()!;
    final hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.onSurface,
            size: 18,
          ),
        ),
        title: Text(
          t.notification.title,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                t.notification.markAllRead,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmpty(context, colors)
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _notifications.length,
        itemBuilder: (context, i) {
          final n = _notifications[i];
          return _buildNotifTile(context, n, i, colors);
        },
      ),
    );
  }

  Widget _buildEmpty(
      BuildContext context,
      ApparenceKitColors colors,
      ) {
    final t = context.t;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors.divider,
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: colors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              t.notification.empty,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.notification.emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.grey3,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifTile(
      BuildContext context,
      _NotifItem n,
      int index,
      ApparenceKitColors colors,
      ) {
    Color iconColor;
    IconData iconData;
    String typeLabel;

    switch (n.type) {
      case NotifType.booking:
        iconColor = colors.primary;
        iconData = Icons.calendar_today_outlined;
        typeLabel = context.t.notification.booking;
        break;

      case NotifType.promo:
        iconColor = colors.warning;
        iconData = Icons.local_offer_outlined;
        typeLabel = context.t.notification.promo;
        break;

      case NotifType.system:
        iconColor = colors.success;
        iconData = Icons.info_outline_rounded;
        typeLabel = context.t.notification.system;
        break;
    }

    final cardColor = n.isRead
        ? colors.surface
        : colors.primary.withValues(alpha: 0.08);

    final borderColor = n.isRead
        ? colors.divider
        : colors.primary.withValues(alpha: 0.25);

    return GestureDetector(
      onTap: () {
        setState(() => n.isRead = true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        n.time,
                        style: TextStyle(
                          color: colors.grey3,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    n.title,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 14,
                      height: 1.25,
                      fontWeight:
                      n.isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    n.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.grey3,
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            if (!n.isRead) ...[
              const SizedBox(width: 10),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum NotifType {
  booking,
  promo,
  system,
}

class _NotifItem {
  final NotifType type;
  final String title;
  final String body;
  final String time;
  bool isRead;

  _NotifItem({
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}