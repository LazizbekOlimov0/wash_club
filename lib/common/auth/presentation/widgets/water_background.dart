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
      duration: const Duration(seconds: 8),
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
      builder: (_, __) {
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

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final rng = _hash(t);

    for (int i = 0; i < 8; i++) {
      final x = size.width * (0.1 + (rng[i % rng.length] / 100) * 0.8);
      final y = size.height * (0.3 - (t + i * 0.13) % 1.3);
      final r = 20.0 + (rng[(i + 3) % rng.length] % 40).toDouble();
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  List<int> _hash(double v) {
    final h = (v * 100000).toInt();
    return List.generate(12, (i) => ((h >> (i * 2)) & 0xFF));
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => old.t != t;
}
