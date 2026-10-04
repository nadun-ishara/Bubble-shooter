import 'dart:math';
import 'package:flutter/material.dart';

class ClockworkGears extends StatefulWidget {
  const ClockworkGears({super.key});

  @override
  State<ClockworkGears> createState() => _ClockworkGearsState();
}

class _ClockworkGearsState extends State<ClockworkGears>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GearsPainter(_controller.value * 2 * pi),
          size: Size.infinite,
        );
      },
    );
  }
}

class _GearsPainter extends CustomPainter {
  final double angle;

  _GearsPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    // Gear 1: Top Right (Large, clockwise)
    _drawGear(
      canvas: canvas,
      center: Offset(size.width * 0.88, size.height * 0.14),
      radius: 95,
      teeth: 16,
      angle: angle,
      color: const Color(0xFFD4AF37),
      alpha: 0.18,
    );

    // Gear 2: Meshing with Gear 1 (Medium, counter-clockwise)
    _drawGear(
      canvas: canvas,
      center: Offset(size.width * 0.52, size.height * 0.08),
      radius: 65,
      teeth: 12,
      angle: -angle * (16 / 12),
      color: const Color(0xFFB8860B),
      alpha: 0.16,
    );

    // Gear 3: Bottom Left (Large, counter-clockwise)
    _drawGear(
      canvas: canvas,
      center: Offset(size.width * 0.10, size.height * 0.82),
      radius: 110,
      teeth: 18,
      angle: -angle * 0.7,
      color: const Color(0xFFD4AF37),
      alpha: 0.16,
    );

    // Gear 4: Meshing with Gear 3 (Small, clockwise)
    _drawGear(
      canvas: canvas,
      center: Offset(size.width * 0.38, size.height * 0.90),
      radius: 50,
      teeth: 10,
      angle: angle * (18 / 10) * 0.7,
      color: const Color(0xFFFFD54F),
      alpha: 0.18,
    );
  }

  void _drawGear({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required int teeth,
    required double angle,
    required Color color,
    required double alpha,
  }) {
    final gearPaint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Outer rim
    canvas.drawCircle(center, radius, gearPaint);
    // Inner hub rim
    canvas.drawCircle(center, radius * 0.38, gearPaint);

    // Hub center bolt
    final boltPaint = Paint()
      ..color = color.withValues(alpha: (alpha * 1.3).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 7.0, boltPaint);

    // Teeth
    final toothLength = 11.0;
    for (int i = 0; i < teeth; i++) {
      final a = angle + (i * 2 * pi / teeth);
      final p1 = Offset(center.dx + cos(a) * (radius - 4), center.dy + sin(a) * (radius - 4));
      final p2 = Offset(center.dx + cos(a) * (radius + toothLength), center.dy + sin(a) * (radius + toothLength));
      canvas.drawLine(p1, p2, gearPaint);
    }

    // Spokes
    final spokePaint = Paint()
      ..color = color.withValues(alpha: (alpha * 0.9).clamp(0.0, 1.0))
      ..strokeWidth = 2.5;
    const int spokes = 6;
    for (int i = 0; i < spokes; i++) {
      final a = angle * 0.5 + (i * 2 * pi / spokes);
      final p1 = Offset(center.dx + cos(a) * (radius * 0.38), center.dy + sin(a) * (radius * 0.38));
      final p2 = Offset(center.dx + cos(a) * (radius - 2), center.dy + sin(a) * (radius - 2));
      canvas.drawLine(p1, p2, spokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GearsPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
