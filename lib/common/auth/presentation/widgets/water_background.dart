import 'package:flutter/material.dart';
import 'package:wash_club/core/theme/colors.dart';

class WaterBackground extends StatefulWidget {
  const WaterBackground({super.key});

  @override
  State<WaterBackground> createState() => _WaterBackgroundState();
}

class _WaterBackgroundState extends State<WaterBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<ApparenceKitColors>()!;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _BubblePainter(c.primary.withValues(alpha: 0.06), _ctrl.value),
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final double t;

  _BubblePainter(this.color, this.t);

  // Har bir pufakcha uchun sobit joylashuv, radius va faza.
  static const List<double> _xs = [0.12, 0.28, 0.42, 0.58, 0.70, 0.85, 0.22, 0.64];
  static const List<double> _radii = [18.0, 28.0, 22.0, 36.0, 16.0, 26.0, 20.0, 32.0];
  static const List<double> _phases = [0.0, 0.18, 0.35, 0.52, 0.68, 0.82, 0.1, 0.42];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = size.width * _xs[i % _xs.length];
      final radius = _radii[i % _radii.length];
      // 0..1 oralig'ida, pastdan yuqoriga sekin ko'tariladi.
      final progress = (t + _phases[i % _phases.length]) % 1.0;
      final y = size.height * (1.15 - progress * 1.35);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => old.t != t;
}
