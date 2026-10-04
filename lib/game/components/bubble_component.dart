import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_config.dart';
import '../models/bubble_type.dart';
import '../models/grid_position.dart';

enum BubbleState {
  idle,
  flying,
  popping,
  falling,
}

class BubbleComponent extends PositionComponent {
  BubbleType bubbleType;
  GridPosition? gridPosition;
  BubbleState state;

  Vector2 velocity = Vector2.zero();
  double gravity = 1200.0;
  double _popScale = 1.0;
  double _popAlpha = 1.0;
  final double radius = GameConfig.bubbleRadius;

  // Collision callback
  void Function(BubbleComponent bubble)? onCollisionWithGrid;

  BubbleComponent({
    required this.bubbleType,
    this.gridPosition,
    this.state = BubbleState.idle,
    Vector2? position,
    this.onCollisionWithGrid,
  }) : super(
          position: position ?? Vector2.zero(),
          size: Vector2.all(GameConfig.bubbleRadius * 2),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);

    switch (state) {
      case BubbleState.idle:
        // subtle breathing animation
        break;

      case BubbleState.flying:
        // Move along velocity vector
        position += velocity * dt;

        // Bounce off left wall
        if (position.x - radius <= GameConfig.wallMarginLeft) {
          position.x = GameConfig.wallMarginLeft + radius;
          velocity.x = -velocity.x;
        }
        // Bounce off right wall
        else if (position.x + radius >= GameConfig.wallMarginRight) {
          position.x = GameConfig.wallMarginRight - radius;
          velocity.x = -velocity.x;
        }

        // Notify grid check
        onCollisionWithGrid?.call(this);
        break;

      case BubbleState.popping:
        _popScale = max(0.0, _popScale - dt * 5.0);
        _popAlpha = max(0.0, _popAlpha - dt * 4.0);
        if (_popScale <= 0.05 || _popAlpha <= 0.05) {
          removeFromParent();
        }
        break;

      case BubbleState.falling:
        velocity.y += gravity * dt;
        position += velocity * dt;
        if (position.y > GameConfig.gameHeight + 100) {
          removeFromParent();
        }
        break;
    }
  }

  /// Trigger popping sequence
  void pop() {
    state = BubbleState.popping;
  }

  /// Trigger orphan fall sequence
  void fall() {
    state = BubbleState.falling;
    final rng = Random();
    velocity = Vector2(
      (rng.nextDouble() - 0.5) * 160.0,
      -80.0 - rng.nextDouble() * 100.0,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);
    final currentR = radius * _popScale;
    if (currentR <= 0.5) return;

    final gradientColors = bubbleType.gradientColors;

    // 1. Outer Brass / Clockwork Rim ring
    final rimPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: (0.55 * _popAlpha).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(center, currentR - 0.5, rimPaint);

    // 2. Soft outer magical glow
    final glowPaint = Paint()
      ..color = bubbleType.glowColor.withValues(alpha: (0.35 * _popAlpha).clamp(0.0, 1.0))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(center, currentR - 1.0, glowPaint);

    // 3. Multi-stop 3D Spherical Radial Gradient
    final sphereGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.88,
      colors: [
        gradientColors[0].withValues(alpha: _popAlpha.clamp(0.0, 1.0)),
        gradientColors[1].withValues(alpha: _popAlpha.clamp(0.0, 1.0)),
        gradientColors[2].withValues(alpha: _popAlpha.clamp(0.0, 1.0)),
        gradientColors[3].withValues(alpha: _popAlpha.clamp(0.0, 1.0)),
      ],
      stops: const [0.0, 0.45, 0.82, 1.0],
    );

    final spherePaint = Paint()
      ..shader = sphereGradient.createShader(
        Rect.fromCircle(center: center, radius: currentR - 1.5),
      );
    canvas.drawCircle(center, currentR - 1.5, spherePaint);

    // 4. Primary Specular Gloss Highlight (upper-left glossy curved reflection)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.78 * _popAlpha).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final highlightOffset = Offset(
      center.dx - currentR * 0.32,
      center.dy - currentR * 0.35,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: highlightOffset,
        width: currentR * 0.58,
        height: currentR * 0.35,
      ),
      highlightPaint,
    );

    // 5. Secondary subtle bottom-right bounce reflection
    final bouncePaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.22 * _popAlpha).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    final bounceOffset = Offset(
      center.dx + currentR * 0.28,
      center.dy + currentR * 0.32,
    );
    canvas.drawCircle(bounceOffset, currentR * 0.18, bouncePaint);

    // 6. Tiny decorative center rune/clockwork dot for steampunk feel
    final cogCorePaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: (0.40 * _popAlpha).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, currentR * 0.35, cogCorePaint);
  }
}
