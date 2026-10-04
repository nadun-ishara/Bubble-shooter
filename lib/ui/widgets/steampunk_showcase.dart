import 'dart:math';
import 'package:flutter/material.dart';
import '../../game/models/bubble_type.dart';

class SteampunkShowcase extends StatefulWidget {
  const SteampunkShowcase({super.key});

  @override
  State<SteampunkShowcase> createState() => _SteampunkShowcaseState();
}

class _SteampunkShowcaseState extends State<SteampunkShowcase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final floatY = sin(_animController.value * pi) * 8.0;

        return SizedBox(
          width: 320,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Subtle glowing amber aura behind showcase
              Container(
                width: 240,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.18),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),

              // 2. Floating Gem Bubbles cluster (matching concept art)
              Positioned(
                top: 12 + floatY,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOrb(BubbleType.ruby, 22),
                    const SizedBox(width: 8),
                    _buildOrb(BubbleType.aquamarine, 24),
                    const SizedBox(width: 8),
                    _buildOrb(BubbleType.emerald, 28, isMain: true),
                    const SizedBox(width: 8),
                    _buildOrb(BubbleType.amber, 24),
                    const SizedBox(width: 8),
                    _buildOrb(BubbleType.amethyst, 22),
                  ],
                ),
              ),

              // 3. Illustrated Steampunk Cannon
              Positioned(
                bottom: 8,
                child: CustomPaint(
                  size: const Size(140, 110),
                  painter: _ShowcaseCannonPainter(
                    floatOffset: floatY,
                    glowAlpha: 0.6 + sin(_animController.value * pi) * 0.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrb(BubbleType type, double radius, {bool isMain = false}) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.88,
          colors: type.gradientColors,
          stops: const [0.0, 0.45, 0.82, 1.0],
        ),
        border: Border.all(
          color: const Color(0xFFFFD54F).withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: type.glowColor.withValues(alpha: isMain ? 0.6 : 0.35),
            blurRadius: isMain ? 12 : 6,
            spreadRadius: isMain ? 2 : 0,
          ),
        ],
      ),
      child: Align(
        alignment: const Alignment(-0.4, -0.45),
        child: Container(
          width: radius * 0.5,
          height: radius * 0.3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _ShowcaseCannonPainter extends CustomPainter {
  final double floatOffset;
  final double glowAlpha;

  _ShowcaseCannonPainter({
    required this.floatOffset,
    required this.glowAlpha,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 35;

    // Wheeled base carriage
    final wheelPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD54F), Color(0xFF8D6E63), Color(0xFF3E2723)],
      ).createShader(Rect.fromLTWH(cx - 50, cy - 10, 100, 35))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(Offset(cx - 30, cy + 12), 16, wheelPaint);
    canvas.drawCircle(Offset(cx + 30, cy + 12), 16, wheelPaint);

    // Spoke lines
    final spokePaint = Paint()..color = const Color(0xFFB8860B)..strokeWidth = 2.0;
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 4;
      canvas.drawLine(
        Offset(cx - 30 + cos(a) * 14, cy + 12 + sin(a) * 14),
        Offset(cx - 30 - cos(a) * 14, cy + 12 - sin(a) * 14),
        spokePaint,
      );
      canvas.drawLine(
        Offset(cx + 30 + cos(a) * 14, cy + 12 + sin(a) * 14),
        Offset(cx + 30 - cos(a) * 14, cy + 12 - sin(a) * 14),
        spokePaint,
      );
    }

    // Carriage bracket
    final bracketPaint = Paint()..color = const Color(0xFF4E342E);
    final bracketPath = Path()
      ..moveTo(cx - 40, cy + 12)
      ..lineTo(cx, cy - 8)
      ..lineTo(cx + 40, cy + 12)
      ..close();
    canvas.drawPath(bracketPath, bracketPaint);

    // Swivel gear ring
    final gearPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFD54F), Color(0xFF8B6508)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy - 8), radius: 18));
    canvas.drawCircle(Offset(cx, cy - 8), 16, gearPaint);

    // Cannon Barrel (angled slightly up)
    canvas.save();
    canvas.translate(cx, cy - 8);

    final barrelPath = Path()
      ..moveTo(-14, 0)
      ..lineTo(-10, -50)
      ..lineTo(-13, -50)
      ..lineTo(-13, -56)
      ..lineTo(13, -56)
      ..lineTo(13, -50)
      ..lineTo(10, -50)
      ..lineTo(14, 0)
      ..close();

    final barrelGradient = const LinearGradient(
      colors: [
        Color(0xFF5D4037),
        Color(0xFFD4AF37),
        Color(0xFFFFF8E1),
        Color(0xFFB8860B),
        Color(0xFF3E2723),
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    ).createShader(const Rect.fromLTWH(-14, -56, 28, 56));

    final barrelPaint = Paint()..shader = barrelGradient;
    canvas.drawPath(barrelPath, barrelPaint);

    // Decorative rings
    final ringPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(-12, -22), const Offset(12, -22), ringPaint);
    canvas.drawLine(const Offset(-11, -38), const Offset(11, -38), ringPaint);

    // Muzzle glow aura
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: (glowAlpha * 0.5).clamp(0.0, 1.0))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawCircle(const Offset(0, -60), 16.0, glowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShowcaseCannonPainter oldDelegate) =>
      oldDelegate.floatOffset != floatOffset || oldDelegate.glowAlpha != glowAlpha;
}
