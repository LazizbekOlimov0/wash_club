import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wash_club/core/theme/colors.dart';

/// Yuqorida ko'rinadigan karta-uslubidagi bildirishnoma uchun matn.
class TopBannerMessage {
  final String title;
  final String subtitle;
  const TopBannerMessage({required this.title, required this.subtitle});
}

/// Sotib olish ekranidan Home screen'ga xabar uzatish uchun global bus.
class TopBannerBus {
  TopBannerBus._();

  static final ValueNotifier<TopBannerMessage?> notifier = ValueNotifier(null);

  static TopBannerMessage? get current => notifier.value;

  static void publish(TopBannerMessage message) => notifier.value = message;

  static void clear() => notifier.value = null;
}

OverlayEntry? _activeEntry;

/// Ekran yuqorisida, overlay sifatida karta-uslubidagi banner ko'rsatadi.
///
/// Bir vaqtning o'zida faqat bitta banner bo'ladi — yangisi eskisini almashtiradi.
void showTopBanner(BuildContext context, {required TopBannerMessage message}) {
  _activeEntry?.remove();
  _activeEntry = null;

  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: _TopBannerOverlay(
        message: message,
        onDismiss: () {
          entry.remove();
          if (_activeEntry == entry) _activeEntry = null;
        },
      ),
    ),
  );

  _activeEntry = entry;
  overlay.insert(entry);
}

class _TopBannerOverlay extends StatefulWidget {
  const _TopBannerOverlay({required this.message, required this.onDismiss});

  final TopBannerMessage message;
  final VoidCallback onDismiss;

  @override
  State<_TopBannerOverlay> createState() => _TopBannerOverlayState();
}

class _TopBannerOverlayState extends State<_TopBannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, -1.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(const Duration(seconds: 3), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    if (_controller.isDismissed) {
      widget.onDismiss();
      return;
    }
    await _controller.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ApparenceKitColors>()!;
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: SlideTransition(
          position: _offset,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _buildCard(colors),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ApparenceKitColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.message.title,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.message.subtitle,
                  style: TextStyle(
                    color: colors.grey2,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _dismiss,
            icon: Icon(Icons.close, color: colors.grey2, size: 20),
          ),
        ],
      ),
    );
  }
}
