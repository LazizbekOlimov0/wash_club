import 'package:flutter/material.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';

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
      title: '–15% Premиum-deteyling',
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
      body: 'Wash Club ilovasini yuklab oldingiz. Birinchi broningizni qiling.',
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
    final hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
        ),
        title: Text(
          t.notification.title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                t.notification.markAllRead,
                style: const TextStyle(
                    color: Color(0xFF4D9EFF), fontSize: 12),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmpty(context)
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _notifications.length,
        itemBuilder: (context, i) {
          final n = _notifications[i];
          return _buildNotifTile(context, n, i);
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final t = context.t;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2340),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.notifications_none_outlined,
                color: Color(0xFF4D9EFF), size: 36),
          ),
          const SizedBox(height: 20),
          Text(t.notification.empty,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(t.notification.emptySubtitle,
              style: const TextStyle(
                  color: Color(0xFF9EA3AE), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNotifTile(
      BuildContext context, _NotifItem n, int index) {
    final t = context.t;

    Color iconColor;
    IconData iconData;
    String typeLabel;

    switch (n.type) {
      case NotifType.booking:
        iconColor = const Color(0xFF4D9EFF);
        iconData = Icons.calendar_today_outlined;
        typeLabel = t.notification.booking;
        break;
      case NotifType.promo:
        iconColor = const Color(0xFFFFB800);
        iconData = Icons.local_offer_outlined;
        typeLabel = t.notification.promo;
        break;
      case NotifType.system:
        iconColor = const Color(0xFF34C759);
        iconData = Icons.info_outline;
        typeLabel = t.notification.system;
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() => n.isRead = true);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.isRead
              ? const Color(0xFF1C2340)
              : const Color(0xFF1E2E55),
          borderRadius: BorderRadius.circular(14),
          border: n.isRead
              ? null
              : Border.all(
              color: const Color(0xFF2A4A8A), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(typeLabel,
                            style: TextStyle(
                                color: iconColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                      const Spacer(),
                      Text(n.time,
                          style: const TextStyle(
                              color: Color(0xFF9EA3AE), fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(n.title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: n.isRead
                              ? FontWeight.w500
                              : FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(n.body,
                      style: const TextStyle(
                          color: Color(0xFF9EA3AE), fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Unread dot
            if (!n.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF4D9EFF),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum NotifType { booking, promo, system }

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