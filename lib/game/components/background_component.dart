import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_config.dart';

class BackgroundComponent extends PositionComponent {
  double _bgGearRotation = 0.0;

  BackgroundComponent()
      : super(
          position: Vector2.zero(),
          size: Vector2(GameConfig.gameWidth, GameConfig.gameHeight),
        );

  @override
  void update(double dt) {
    super.update(dt);
    _bgGearRotation += dt * 0.15;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Deep Steampunk Workshop Backdrop Gradient
    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgGradient = const RadialGradient(
      center: Alignment(0.0, -0.2),
      radius: 1.1,
      colors: [
        Color(0xFF2B2118), // warm dark bronze ambient
        Color(0xFF191310),
        Color(0xFF0F0B09),
      ],
      stops: [0.0, 0.6, 1.0],
    );
    final bgPaint = Paint()..shader = bgGradient.createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // 2. Faint Ambient Background Clockwork Gears (very subtle in background)
    _renderFaintGear(canvas, Offset(80, 240), 90, _bgGearRotation);
    _renderFaintGear(canvas, Offset(340, 320), 120, -_bgGearRotation * 0.7);
    _renderFaintGear(canvas, Offset(210, 520), 75, _bgGearRotation * 1.2);

    // 3. Danger Line (Warning threshold)
    final dangerY = GameConfig.dangerY;
    final dangerPaint = Paint()
      ..color = const Color(0xFFEF5350).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dashed danger line
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double startX = GameConfig.wallMarginLeft;
    while (startX < GameConfig.wallMarginRight) {
      canvas.drawLine(
        Offset(startX, dangerY),
        Offset(startX + dashWidth, dangerY),
        dangerPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // 4. Left and Right Brass Bumper Walls
    _renderBrassWall(canvas, 0, GameConfig.wallMarginLeft, true);
    _renderBrassWall(canvas, GameConfig.wallMarginRight, size.x, false);

    // 5. Bottom Cannon Stage / Plate
    final stageRect = Rect.fromLTWH(0, GameConfig.gameHeight - 60, size.x, 60);
    final stagePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3E2723), Color(0xFF1E140A)],
      ).createShader(stageRect);
    canvas.drawRect(stageRect, stagePaint);

    // Stage brass trim line
    final trimPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2.5;
    canvas.drawLine(
      Offset(0, GameConfig.gameHeight - 60),
      Offset(size.x, GameConfig.gameHeight - 60),
      trimPaint,
    );
  }

  void _renderBrassWall(Canvas canvas, double left, double right, bool isLeftWall) {
    final wallRect = Rect.fromLTRB(left, 0, right, size.y);
    final wallPaint = Paint()
      ..shader = LinearGradient(
        begin: isLeftWall ? Alignment.centerLeft : Alignment.centerRight,
        end: isLeftWall ? Alignment.centerRight : Alignment.centerLeft,
        colors: const [
          Color(0xFF3E2723),
          Color(0xFF8D6E63),
          Color(0xFFD4AF37),
          Color(0xFF5D4037),
        ],
        stops: const [0.0, 0.4, 0.85, 1.0],
      ).createShader(wallRect);
    canvas.drawRect(wallRect, wallPaint);

    // Rivets along the wall
    final rivetPaint = Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.7);
    final rivetX = isLeftWall ? 8.0 : size.x - 8.0;
    for (double y = 40.0; y < size.y - 40; y += 45.0) {
      canvas.drawCircle(Offset(rivetX, y), 2.2, rivetPaint);
    }
  }

  void _renderFaintGear(Canvas canvas, Offset center, double radius, double angle) {
    final gearPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, radius, gearPaint);
    canvas.drawCircle(center, radius * 0.35, gearPaint);

    const int teeth = 12;
    for (int i = 0; i < teeth; i++) {
      final a = angle + (i * 2 * pi / teeth);
      final p1 = Offset(center.dx + cos(a) * (radius - 6), center.dy + sin(a) * (radius - 6));
      final p2 = Offset(center.dx + cos(a) * (radius + 8), center.dy + sin(a) * (radius + 8));
      canvas.drawLine(p1, p2, gearPaint);
    }
  }
}
