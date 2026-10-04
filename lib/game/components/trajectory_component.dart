import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_config.dart';
import '../models/bubble_type.dart';
import 'bubble_grid_component.dart';

class TrajectoryComponent extends Component {
  final BubbleGridComponent gridComponent;
  bool isAiming = false;
  Vector2 origin = Vector2(GameConfig.cannonX, GameConfig.cannonY);
  Vector2 direction = Vector2(0, -1);
  BubbleType? currentType;

  final List<Vector2> _points = [];
  double _pulseTime = 0.0;

  TrajectoryComponent({
    required this.gridComponent,
  });

  void updateAim({
    required bool aiming,
    required Vector2 newOrigin,
    required Vector2 newDirection,
    required BubbleType bubbleType,
  }) {
    isAiming = aiming;
    origin = newOrigin.clone();
    direction = newDirection.normalized();
    currentType = bubbleType;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt * 4.0;

    if (!isAiming) {
      _points.clear();
      return;
    }

    _calculateTrajectory();
  }

  void _calculateTrajectory() {
    _points.clear();
    final r = GameConfig.bubbleRadius;
    final leftBound = GameConfig.wallMarginLeft + r;
    final rightBound = GameConfig.wallMarginRight - r;
    final ceiling = GameConfig.ceilingY + gridComponent.gridOffsetY + r;
    final collisionDist = GameConfig.bubbleDiameter * 0.92;

    var currentPos = origin.clone();
    var currentDir = direction.clone();

    const double stepSize = 14.0;
    const int maxSteps = 45;

    for (int step = 0; step < maxSteps; step++) {
      currentPos += currentDir * stepSize;

      // Check wall bounce left
      if (currentPos.x <= leftBound) {
        currentPos.x = leftBound;
        currentDir.x = -currentDir.x;
      }
      // Check wall bounce right
      else if (currentPos.x >= rightBound) {
        currentPos.x = rightBound;
        currentDir.x = -currentDir.x;
      }

      _points.add(currentPos.clone());

      // Check ceiling collision
      if (currentPos.y <= ceiling) {
        break;
      }

      // Check grid bubble collision
      bool hitBubble = false;
      for (final b in gridComponent.grid.values) {
        if (currentPos.distanceTo(b.position) <= collisionDist) {
          hitBubble = true;
          break;
        }
      }

      if (hitBubble) {
        break;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!isAiming || _points.isEmpty) return;

    final dotColor = currentType?.primaryColor ?? const Color(0xFFFFD54F);
    final glowColor = currentType?.glowColor ?? const Color(0x80FFD54F);

    for (int i = 0; i < _points.length; i++) {
      final pt = _points[i];
      final progress = i / _points.length;
      final wave = (sin(_pulseTime - i * 0.3) + 1.0) / 2.0;
      final dotRadius = 3.0 + wave * 1.5;
      final alpha = (1.0 - progress * 0.45).clamp(0.2, 1.0);

      // Glow behind dot
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: (alpha * 0.6).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
      canvas.drawCircle(Offset(pt.x, pt.y), dotRadius + 2.0, glowPaint);

      // Inner sharp dot
      final dotPaint = Paint()
        ..color = dotColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pt.x, pt.y), dotRadius, dotPaint);

      // Core white sparkle
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: (alpha * 0.8).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pt.x, pt.y), dotRadius * 0.4, corePaint);
    }
  }
}
