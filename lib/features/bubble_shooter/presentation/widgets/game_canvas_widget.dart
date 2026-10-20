import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/theme/steampunk_theme.dart';
import '../../domain/entities/bubble_entity.dart';
import '../../domain/entities/projectile_entity.dart';
import '../bloc/game_state.dart';

class GameCanvasWidget extends StatelessWidget {
  final GameState state;
  final void Function(double virtualX, double virtualY) onAim;
  final VoidCallback onCancelAim;
  final VoidCallback onFire;
  final VoidCallback onSwap;

  const GameCanvasWidget({
    super.key,
    required this.state,
    required this.onAim,
    required this.onCancelAim,
    required this.onFire,
    required this.onSwap,
  });

  (double vx, double vy) _toVirtual(Offset localPos, Size widgetSize) {
    final scaleX = widgetSize.width / GameConstants.virtualWidth;
    final scaleY = widgetSize.height / GameConstants.virtualHeight;
    final scale = min(scaleX, scaleY);

    final offsetX = (widgetSize.width - GameConstants.virtualWidth * scale) / 2;
    final offsetY = (widgetSize.height - GameConstants.virtualHeight * scale) / 2;

    final vx = (localPos.dx - offsetX) / scale;
    final vy = (localPos.dy - offsetY) / scale;

    return (vx, vy);
  }

  bool _isSwapTapped(double vx, double vy) {
    const swapX = GameConstants.cannonX - 74.0;
    const swapY = GameConstants.cannonY + 8.0;
    final dx = vx - swapX;
    final dy = vy - swapY;
    return sqrt(dx * dx + dy * dy) <= 38.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final (vx, vy) = _toVirtual(details.localPosition, widgetSize);
            if (_isSwapTapped(vx, vy)) {
              onSwap();
            } else {
              onAim(vx, vy);
            }
          },
          onTapUp: (details) {
            final (vx, vy) = _toVirtual(details.localPosition, widgetSize);
            if (_isSwapTapped(vx, vy)) return;
            onAim(vx, vy);
            onFire();
          },
          onPanStart: (details) {
            final (vx, vy) = _toVirtual(details.localPosition, widgetSize);
            if (!_isSwapTapped(vx, vy)) {
              onAim(vx, vy);
            }
          },
          onPanUpdate: (details) {
            final (vx, vy) = _toVirtual(details.localPosition, widgetSize);
            onAim(vx, vy);
          },
          onPanEnd: (details) {
            if (state.cannon.isAiming) {
              onFire();
            } else {
              onCancelAim();
            }
          },
          onPanCancel: onCancelAim,
          child: CustomPaint(
            size: Size.infinite,
            painter: _GamePainter(state: state),
          ),
        );
      },
    );
  }
}

class _GamePainter extends CustomPainter {
  final GameState state;

  _GamePainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameConstants.virtualWidth;
    final scaleY = size.height / GameConstants.virtualHeight;
    final scale = min(scaleX, scaleY);

    final offsetX = (size.width - GameConstants.virtualWidth * scale) / 2;
    final offsetY = (size.height - GameConstants.virtualHeight * scale) / 2;

    // Letterbox viewport
    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    final virtualRect = const Rect.fromLTWH(
      0,
      0,
      GameConstants.virtualWidth,
      GameConstants.virtualHeight,
    );
    canvas.clipRect(virtualRect);

    // 1. Draw Steampunk Workshop Backdrop
    _drawBackdrop(canvas, virtualRect);

    // 2. Draw Brass Ceiling Bar
    _drawCeiling(canvas);

    // 3. Draw Danger Threshold Line
    _drawDangerLine(canvas);

    // 4. Draw Trajectory Line
    if (state.aimLineEnabled && state.trajectory.isNotEmpty) {
      _drawTrajectory(canvas);
    }

    // 5. Draw Grid Bubbles
    for (final bubble in state.board.bubbles.values) {
      _drawBubble(canvas, bubble);
    }

    // 6. Draw Dynamic Bubbles (popping / falling)
    for (final dynamicBubble in state.board.dynamicBubbles) {
      _drawBubble(canvas, dynamicBubble);
    }

    // 7. Draw Flying Projectile
    if (state.projectile != null) {
      _drawProjectile(canvas, state.projectile!);
    }

    // 8. Draw Next Bubble Reserve Holder
    _drawNextBubbleReserve(canvas);

    // 9. Draw Brass Side Bumper Walls
    _drawWalls(canvas);

    // 10. Draw Cannon Chassis, Carriage and Barrel
    _drawCannon(canvas);

    canvas.restore();
  }

  void _drawBackdrop(Canvas canvas, Rect rect) {
    final bgGradient = const RadialGradient(
      center: Alignment(0.0, -0.2),
      radius: 1.15,
      colors: [
        Color(0xFF2E2018),
        Color(0xFF1B1310),
        Color(0xFF0F0B09),
      ],
      stops: [0.0, 0.55, 1.0],
    );
    final bgPaint = Paint()..shader = bgGradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Ambient background faint gear
    _drawFaintGear(canvas, const Offset(80, 260), 85, state.cannon.gearRotation * 0.4);
    _drawFaintGear(canvas, const Offset(340, 360), 110, -state.cannon.gearRotation * 0.3);
  }

  void _drawCeiling(Canvas canvas) {
    final ceilingY = GameConstants.ceilingBaseY + state.board.gridOffsetY;
    final beamRect = Rect.fromLTRB(
      GameConstants.wallMarginLeft,
      ceilingY - 14.0,
      GameConstants.wallMarginRight,
      ceilingY,
    );

    final beamGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFF9C4),
        Color(0xFFFFD54F),
        Color(0xFFB8860B),
        Color(0xFF4E342E),
      ],
      stops: [0.0, 0.25, 0.7, 1.0],
    );

    final beamPaint = Paint()..shader = beamGradient.createShader(beamRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(beamRect, const Radius.circular(4.0)),
      beamPaint,
    );

    // Rivets
    final rivetPaint = Paint()..color = const Color(0xFF271A15);
    for (double x = GameConstants.wallMarginLeft + 18; x < GameConstants.wallMarginRight; x += 32) {
      canvas.drawCircle(Offset(x, ceilingY - 7.0), 2.2, rivetPaint);
    }
  }

  void _drawDangerLine(Canvas canvas) {
    const dangerY = GameConstants.dangerLineY;
    final dangerPaint = Paint()
      ..color = const Color(0xFFEF5350).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double curX = GameConstants.wallMarginLeft;
    while (curX < GameConstants.wallMarginRight) {
      canvas.drawLine(
        Offset(curX, dangerY),
        Offset(curX + dashWidth, dangerY),
        dangerPaint,
      );
      curX += dashWidth + dashSpace;
    }
  }

  void _drawWalls(Canvas canvas) {
    // Left brass bumper wall
    _drawSingleWall(canvas, 0, GameConstants.wallMarginLeft, true);
    // Right brass bumper wall
    _drawSingleWall(canvas, GameConstants.wallMarginRight, GameConstants.virtualWidth, false);
  }

  void _drawSingleWall(Canvas canvas, double left, double right, bool isLeft) {
    final wallRect = Rect.fromLTRB(left, 0, right, GameConstants.virtualHeight);
    final wallPaint = Paint()
      ..shader = LinearGradient(
        begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        colors: const [
          Color(0xFF3E2723),
          Color(0xFF8D6E63),
          Color(0xFFD4AF37),
          Color(0xFF4E342E),
        ],
        stops: const [0.0, 0.35, 0.85, 1.0],
      ).createShader(wallRect);
    canvas.drawRect(wallRect, wallPaint);

    final rivetPaint = Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.7);
    final rivetX = isLeft ? 7.0 : GameConstants.virtualWidth - 7.0;
    for (double y = 45.0; y < GameConstants.virtualHeight - 40; y += 42.0) {
      canvas.drawCircle(Offset(rivetX, y), 2.0, rivetPaint);
    }
  }

  void _drawTrajectory(Canvas canvas) {
    final bubbleColor = state.cannon.loadedBubble.primaryColor;
    final glowColor = state.cannon.loadedBubble.glowColor;

    for (int i = 0; i < state.trajectory.length; i++) {
      final pt = state.trajectory[i];
      final progress = i / state.trajectory.length;
      final alpha = (1.0 - progress * 0.4).clamp(0.25, 1.0);
      final r = pt.isWallBounce ? 4.5 : 3.2;

      // Glow behind dot
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: (alpha * 0.55).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
      canvas.drawCircle(Offset(pt.x, pt.y), r + 2.0, glowPaint);

      // Inner dot
      final dotPaint = Paint()
        ..color = bubbleColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pt.x, pt.y), r, dotPaint);

      // Core white sparkle
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: (alpha * 0.85).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pt.x, pt.y), r * 0.45, corePaint);
    }
  }

  void _drawBubble(Canvas canvas, BubbleEntity bubble) {
    final r = GameConstants.bubbleRadius * bubble.scale;
    if (r <= 0.5) return;

    final center = Offset(bubble.x, bubble.y);
    final alpha = bubble.alpha;

    // 1. Outer Brass Rim ring
    final rimPaint = Paint()
      ..color = SteampunkTheme.polishedBrass.withValues(alpha: (0.55 * alpha).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(center, r - 0.5, rimPaint);

    // 2. Soft outer jewel glow
    final glowPaint = Paint()
      ..color = bubble.type.glowColor.withValues(alpha: (0.35 * alpha).clamp(0.0, 1.0))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(center, r - 1.0, glowPaint);

    // 3. Multi-stop 3D Spherical Radial Gradient
    final sphereGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.88,
      colors: [
        bubble.type.gradientColors[0].withValues(alpha: alpha.clamp(0.0, 1.0)),
        bubble.type.gradientColors[1].withValues(alpha: alpha.clamp(0.0, 1.0)),
        bubble.type.gradientColors[2].withValues(alpha: alpha.clamp(0.0, 1.0)),
        bubble.type.gradientColors[3].withValues(alpha: alpha.clamp(0.0, 1.0)),
      ],
      stops: const [0.0, 0.45, 0.82, 1.0],
    );

    final spherePaint = Paint()
      ..shader = sphereGradient.createShader(
        Rect.fromCircle(center: center, radius: r - 1.5),
      );
    canvas.drawCircle(center, r - 1.5, spherePaint);

    // 4. Primary Specular Gloss Highlight (upper-left glossy curved reflection)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.80 * alpha).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    final highlightOffset = Offset(center.dx - r * 0.32, center.dy - r * 0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: highlightOffset,
        width: r * 0.58,
        height: r * 0.35,
      ),
      highlightPaint,
    );

    // 5. Secondary subtle bottom-right reflection
    final bouncePaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.24 * alpha).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    final bounceOffset = Offset(center.dx + r * 0.28, center.dy + r * 0.32);
    canvas.drawCircle(bounceOffset, r * 0.18, bouncePaint);

    // 6. Center clockwork rune circle
    final cogCorePaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: (0.42 * alpha).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, r * 0.36, cogCorePaint);
  }

  void _drawProjectile(Canvas canvas, ProjectileEntity proj) {
    final bubble = BubbleEntity(
      id: 'proj',
      type: proj.type,
      x: proj.x,
      y: proj.y,
    );
    _drawBubble(canvas, bubble);
  }

  void _drawNextBubbleReserve(Canvas canvas) {
    final holderCenter = const Offset(GameConstants.cannonX - 74.0, GameConstants.cannonY + 8.0);
    const holderR = 21.0;

    // Brass Bezel Ring
    final bezelPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFD4AF37),
          Color(0xFF8B6508),
          Color(0xFFFFE082),
          Color(0xFFB8860B),
          Color(0xFFD4AF37),
        ],
      ).createShader(Rect.fromCircle(center: holderCenter, radius: holderR + 4));
    canvas.drawCircle(holderCenter, holderR + 3.5, bezelPaint);

    // Dark inset well
    final wellPaint = Paint()..color = const Color(0xFF1E140A);
    canvas.drawCircle(holderCenter, holderR, wellPaint);

    // Mini Bubble inside reserve
    const nextR = 15.0;
    final bubbleGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.88,
      colors: state.cannon.nextBubble.gradientColors,
      stops: const [0.0, 0.45, 0.82, 1.0],
    );
    final bubblePaint = Paint()
      ..shader = bubbleGradient.createShader(
        Rect.fromCircle(center: holderCenter, radius: nextR),
      );
    canvas.drawCircle(holderCenter, nextR, bubblePaint);

    // Highlight
    final hlPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(holderCenter.dx - 4, holderCenter.dy - 4),
        width: 8,
        height: 5,
      ),
      hlPaint,
    );

    // Swap curved arrows
    final swapIconPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawArc(
      Rect.fromCircle(center: holderCenter, radius: holderR + 7.5),
      -pi / 4,
      pi / 2,
      false,
      swapIconPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: holderCenter, radius: holderR + 7.5),
      3 * pi / 4,
      pi / 2,
      false,
      swapIconPaint,
    );
  }

  void _drawCannon(Canvas canvas) {
    const center = Offset(GameConstants.cannonX, GameConstants.cannonY + 8.0);

    // 1. Heavy carriage chassis brackets
    final bracketPaint = Paint()..color = const Color(0xFF3E2723);
    final leftBracket = Path()
      ..moveTo(center.dx - 36, center.dy + 30)
      ..lineTo(center.dx - 12, center.dy + 10)
      ..lineTo(center.dx - 10, center.dy + 30)
      ..close();
    final rightBracket = Path()
      ..moveTo(center.dx + 36, center.dy + 30)
      ..lineTo(center.dx + 12, center.dy + 10)
      ..lineTo(center.dx + 10, center.dy + 30)
      ..close();
    canvas.drawPath(leftBracket, bracketPaint);
    canvas.drawPath(rightBracket, bracketPaint);

    // 2. Large Steampunk Spoked Brass Wheel on Carriage
    final wheelCenter = Offset(center.dx, center.dy + 22.0);
    const wheelR = 24.0;
    final rimPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD54F), Color(0xFF8B6508), Color(0xFF5D4037)],
      ).createShader(Rect.fromCircle(center: wheelCenter, radius: wheelR))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawCircle(wheelCenter, wheelR, rimPaint);

    final hubPaint = Paint()..color = const Color(0xFFD4AF37);
    canvas.drawCircle(wheelCenter, 7.0, hubPaint);

    final spokePaint = Paint()
      ..color = const Color(0xFFB8860B)
      ..strokeWidth = 2.5;
    for (int i = 0; i < 6; i++) {
      final angle = state.cannon.gearRotation + (i * pi / 3);
      canvas.drawLine(
        wheelCenter,
        Offset(wheelCenter.dx + cos(angle) * wheelR, wheelCenter.dy + sin(angle) * wheelR),
        spokePaint,
      );
    }

    // 3. Rotating Barrel Assembly
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(state.cannon.aimAngle + pi / 2); // Rotate to aim angle

    // Apply recoil translation
    canvas.translate(0, state.cannon.recoilOffset);

    // Swivel gear base
    final gearBasePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFD54F), Color(0xFF8B5A2B), Color(0xFF3E2723)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 22));
    canvas.drawCircle(Offset.zero, 20.0, gearBasePaint);

    // Brass Cannon Barrel
    final barrelPath = Path()
      ..moveTo(-16, -6)
      ..lineTo(-12, -48)
      ..lineTo(-15, -48)
      ..lineTo(-15, -54)
      ..lineTo(15, -54)
      ..lineTo(15, -48)
      ..lineTo(12, -48)
      ..lineTo(16, -6)
      ..close();

    final barrelGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF5D4037),
        Color(0xFFD4AF37),
        Color(0xFFFFF8E1),
        Color(0xFFB8860B),
        Color(0xFF3E2723),
      ],
      stops: [0.0, 0.3, 0.5, 0.75, 1.0],
    ).createShader(const Rect.fromLTRB(-18, -55, 18, 0));

    final barrelPaint = Paint()..shader = barrelGradient;
    canvas.drawPath(barrelPath, barrelPaint);

    // Reinforcing brass rings
    final ringPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawLine(const Offset(-14, -20), const Offset(14, -20), ringPaint);
    canvas.drawLine(const Offset(-13, -34), const Offset(13, -34), ringPaint);

    // Loaded Bubble in Cannon Breech
    final bubbleCenter = const Offset(0, -4);
    const loadedR = GameConstants.bubbleRadius * 0.82;
    final loadedGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.88,
      colors: state.cannon.loadedBubble.gradientColors,
      stops: const [0.0, 0.45, 0.82, 1.0],
    );
    final loadedPaint = Paint()
      ..shader = loadedGradient.createShader(
        Rect.fromCircle(center: bubbleCenter, radius: loadedR),
      );
    canvas.drawCircle(bubbleCenter, loadedR, loadedPaint);

    final loadedHlPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(-4, -8),
        width: loadedR * 0.65,
        height: loadedR * 0.4,
      ),
      loadedHlPaint,
    );

    // 4. Diamond Energy Muzzle Cone (from reference image!)
    if (state.cannon.muzzleFlashAlpha > 0.05) {
      final alpha = state.cannon.muzzleFlashAlpha.clamp(0.0, 1.0);
      final flashPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawCircle(const Offset(0, -56), 24.0 * alpha, flashPaint);

      // Diamond energy cone
      final conePath = Path()
        ..moveTo(0, -96)
        ..lineTo(-18, -56)
        ..lineTo(18, -56)
        ..close();
      final conePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFFFFE082).withValues(alpha: alpha),
            Colors.transparent,
          ],
        ).createShader(const Rect.fromLTRB(-18, -96, 18, -56));
      canvas.drawPath(conePath, conePaint);
    }

    canvas.restore();
  }

  void _drawFaintGear(Canvas canvas, Offset center, double radius, double angle) {
    final gearPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(center, radius, gearPaint);
    canvas.drawCircle(center, radius * 0.35, gearPaint);

    const int teeth = 12;
    for (int i = 0; i < teeth; i++) {
      final a = angle + (i * 2 * pi / teeth);
      final p1 = Offset(center.dx + cos(a) * (radius - 5), center.dy + sin(a) * (radius - 5));
      final p2 = Offset(center.dx + cos(a) * (radius + 8), center.dy + sin(a) * (radius + 8));
      canvas.drawLine(p1, p2, gearPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) => true;
}
