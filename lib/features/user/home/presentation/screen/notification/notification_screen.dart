import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../../../../shared/services/orders_repository.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _repo = OrdersRepository.instance;
  late StreamSubscription<AppNotification> _sub;

  // Lokal nusxa — realtime'dan yangilanadi
  List<AppNotification> _items = [];

  @override
  void initState() {
    super.initState();

    // Mavjud notiflarni ko'rsatish
    _items = List<AppNotification>.from(_repo.notifications);

    // Yangi notif kelsa — UI yangilanadi
    _sub = _repo.notificationStream.listen((notif) {
      if (mounted) {
        setState(() {
          // duplicate check
          if (!_items.any((n) => n.id == notif.id)) {
            _items.insert(0, notif);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _markAllRead() {
    _repo.markAllRead();
    setState(() {
      for (final n in _items) {
        n.isRead = true;
      }
    });
  }

  void _markRead(AppNotification n) {
    _repo.markRead(n.id);
    setState(() => n.isRead = true);
  }

  bool get _hasUnread => _items.any((n) => !n.isRead);

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = _c;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: isDark ? colors.background : colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.onSurface,
            size: 18,
          ),
        ),
        title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  t.notification.title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_hasUnread) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_items.where((n) => !n.isRead).length}',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        actions: [
          if (_hasUnread)
            IconButton(
              onPressed: _markAllRead,
              tooltip: t.notification.markAllRead,
              icon: Icon(
                Icons.done_all_rounded,
                color: colors.primary,
                size: 22,
              ),
            ),
        ],
      ),
      body: _items.isEmpty
          ? _buildEmpty(context, colors)
          : RefreshIndicator(
              onRefresh: () async {
                // Orders reload qilganda yangi notiflar ham kelishi mumkin
                await _repo.loadOrders();
                if (mounted) {
                  setState(() {
                    _items = List<AppNotification>.from(_repo.notifications);
                  });
                }
              },
              color: colors.info,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final n = _items[i];
                  return _buildTile(context, n, colors, isDark);
                },
              ),
            ),
    );
  }

  Widget _buildEmpty(BuildContext context, ApparenceKitColors colors) {
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
                border: Border.all(color: colors.divider),
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
            const SizedBox(height: 24),
            Text(
              t.notification.emptyHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.grey3.withValues(alpha: 0.7),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    AppNotification n,
    ApparenceKitColors colors,
    bool isDark,
  ) {
    final Color iconColor;
    final IconData iconData;
    final String typeLabel;
    final t = context.t;

    switch (n.type) {
      case NotifType.booking:
        iconColor = colors.primary;
        iconData  = Icons.calendar_today_outlined;
        typeLabel = t.notification.booking;
        break;
      case NotifType.promo:
        iconColor = colors.warning;
        iconData  = Icons.local_offer_outlined;
        typeLabel = t.notification.promo;
        break;
      case NotifType.system:
        iconColor = colors.success;
        iconData  = Icons.info_outline_rounded;
        typeLabel = t.notification.system;
        break;
    }

    final cardColor = n.isRead
        ? (isDark ? colors.onPrimaryContainer : colors.surface)
        : colors.primary.withValues(alpha: isDark ? 0.12 : 0.06);

    final borderColor = n.isRead
        ? colors.divider
        : colors.primary.withValues(alpha: 0.30);

    return GestureDetector(
      onTap: () => _markRead(n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? null
              : [
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
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        n.relativeTime,
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
                    ),
                  ),
                ],
              ),
            ),

            // Unread dot
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
