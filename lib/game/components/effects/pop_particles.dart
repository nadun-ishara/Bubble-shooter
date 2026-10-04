import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PopParticleEmitter extends Component {
  final Vector2 position;
  final Color color;
  final int count;
  final double lifeTime;

  late final List<_Sparkle> _sparkles;
  double _elapsed = 0.0;

  PopParticleEmitter({
    required this.position,
    required this.color,
    this.count = 14,
    this.lifeTime = 0.55,
  });

  @override
  void onLoad() {
    super.onLoad();
    final rng = Random();
    _sparkles = List.generate(count, (i) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 80.0 + rng.nextDouble() * 220.0;
      final size = 2.5 + rng.nextDouble() * 4.5;
      final isBrass = rng.nextBool(); // mix of gem color and brass sparks
      return _Sparkle(
        x: position.x,
        y: position.y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: size,
        color: isBrass ? const Color(0xFFFFD54F) : color,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= lifeTime) {
      removeFromParent();
      return;
    }

    // Update sparkle positions and gravity
    for (final s in _sparkles) {
      s.x += s.vx * dt;
      s.y += s.vy * dt;
      s.vy += 220.0 * dt; // gravity
      s.vx *= 0.95; // drag
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / lifeTime).clamp(0.0, 1.0);
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    // Expanding shockwave ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: (alpha * 0.7).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * (1.0 - progress);
    canvas.drawCircle(
      Offset(position.x, position.y),
      25.0 * progress + 8.0,
      ringPaint,
    );

    // Individual sparkles
    for (final s in _sparkles) {
      final pSize = s.size * (1.0 - progress * 0.7);
      final pPaint = Paint()
        ..color = s.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(s.x, s.y), pSize, pPaint);

      // Bright white core for inner sparkles
      if (s.size > 4.0) {
        final corePaint = Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(s.x, s.y), pSize * 0.45, corePaint);
      }
    }
  }
}

class _Sparkle {
  double x;
  double y;
  double vx;
  double vy;
  final double size;
  final Color color;

  _Sparkle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
  });
}
