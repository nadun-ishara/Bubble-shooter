import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_config.dart';
import '../models/bubble_type.dart';
import 'bubble_component.dart';
import 'bubble_grid_component.dart';

class ShooterComponent extends PositionComponent {
  final BubbleGridComponent gridComponent;

  // Aim angle (radians from horizontal right: -pi/2 is straight up)
  double aimAngle = -pi / 2;
  bool isAiming = false;
  bool isReloading = false;

  late BubbleType currentBubbleType;
  late BubbleType nextBubbleType;

  // Recoil animation state
  double _recoilOffset = 0.0;
  double _gearRotation = 0.0;
  double _muzzleFlashAlpha = 0.0;

  // Callback to fire projectile
  void Function(BubbleComponent projectile)? onFireBubble;
  void Function(bool aiming, Vector2 muzzlePos, Vector2 aimDir, BubbleType type)? onAimChanged;

  ShooterComponent({
    required this.gridComponent,
    this.onFireBubble,
    this.onAimChanged,
  }) : super(
          position: Vector2(GameConfig.cannonX, GameConfig.cannonY),
          size: Vector2(160, 140),
          anchor: Anchor.center,
        );

  @override
  void onLoad() {
    super.onLoad();
    _initBubbles();
  }

  void _initBubbles() {
    final available = gridComponent.getAvailableBubbleTypes();
    currentBubbleType = BubbleType.random(null, available);
    nextBubbleType = BubbleType.random(null, available);
  }

  /// Sets the aim target using a world coordinate
  void aimAt(Vector2 targetPos) {
    final diff = targetPos - position;
    // Calculate angle: in screen coords, -Y is up.
    double angle = atan2(diff.y, diff.x);

    // Clamp angle so cannon only points upward (between -165° and -15°)
    const minAngle = -165.0 * (pi / 180.0);
    const maxAngle = -15.0 * (pi / 180.0);

    if (angle > 0) {
      // Aiming downwards: clamp to closest side
      angle = (diff.x < 0) ? minAngle : maxAngle;
    } else {
      angle = angle.clamp(minAngle, maxAngle);
    }

    aimAngle = angle;
    isAiming = true;

    final dir = Vector2(cos(aimAngle), sin(aimAngle));
    final muzzlePos = position + dir * 48.0;
    onAimChanged?.call(true, muzzlePos, dir, currentBubbleType);
  }

  void cancelAim() {
    isAiming = false;
    final dir = Vector2(cos(aimAngle), sin(aimAngle));
    final muzzlePos = position + dir * 48.0;
    onAimChanged?.call(false, muzzlePos, dir, currentBubbleType);
  }

  /// Fire the loaded bubble
  bool fire() {
    if (isReloading) return false;

    isAiming = false;
    _recoilOffset = 14.0; // Trigger recoil
    _muzzleFlashAlpha = 1.0; // Trigger muzzle burst flash

    final dir = Vector2(cos(aimAngle), sin(aimAngle));
    final muzzlePos = position + dir * 46.0;

    final projectile = BubbleComponent(
      bubbleType: currentBubbleType,
      position: muzzlePos,
      state: BubbleState.flying,
    );
    projectile.velocity = dir * GameConfig.projectileSpeed;

    onFireBubble?.call(projectile);

    // Cancel trajectory
    onAimChanged?.call(false, muzzlePos, dir, currentBubbleType);

    // Reload sequence
    isReloading = true;
    currentBubbleType = nextBubbleType;
    final available = gridComponent.getAvailableBubbleTypes();
    nextBubbleType = BubbleType.random(null, available);

    // Brief cooldown
    Future.delayed(const Duration(milliseconds: 250), () {
      isReloading = false;
    });

    return true;
  }

  /// Swap current and next bubble
  void swapBubbles() {
    if (isReloading) return;
    final temp = currentBubbleType;
    currentBubbleType = nextBubbleType;
    nextBubbleType = temp;

    if (isAiming) {
      final dir = Vector2(cos(aimAngle), sin(aimAngle));
      final muzzlePos = position + dir * 48.0;
      onAimChanged?.call(true, muzzlePos, dir, currentBubbleType);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Recoil recovery
    if (_recoilOffset > 0) {
      _recoilOffset = max(0.0, _recoilOffset - dt * 60.0);
    }
    // Muzzle flash fade
    if (_muzzleFlashAlpha > 0) {
      _muzzleFlashAlpha = max(0.0, _muzzleFlashAlpha - dt * 6.0);
    }
    // Slow gear ambient rotation
    _gearRotation += dt * 0.4;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2 + 10);

    // 1. Draw Next Bubble Reserve Bezel (on the left side)
    _renderNextBubbleHolder(canvas, center);

    // 2. Draw Antique Wheeled Carriage & Clockwork Chassis
    _renderCannonChassis(canvas, center);

    // 3. Draw Rotating Cannon Barrel & Loaded Bubble
    _renderCannonBarrel(canvas, center);
  }

  void _renderNextBubbleHolder(Canvas canvas, Offset center) {
    final holderCenter = Offset(center.dx - 64.0, center.dy + 8.0);
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

    // Render Mini Next Bubble
    final nextR = 15.0;
    final gradientColors = nextBubbleType.gradientColors;
    final bubbleGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.88,
      colors: gradientColors,
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

    // "SWAP" icon / arrows arc around holder
    final swapIconPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawArc(
      Rect.fromCircle(center: holderCenter, radius: holderR + 7.0),
      -pi / 4,
      pi / 2,
      false,
      swapIconPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: holderCenter, radius: holderR + 7.0),
      3 * pi / 4,
      pi / 2,
      false,
      swapIconPaint,
    );
  }

  void _renderCannonChassis(Canvas canvas, Offset center) {
    // Large Steampunk Spoked Brass Wheel on Carriage
    final wheelCenter = Offset(center.dx, center.dy + 22.0);
    const wheelR = 24.0;

    // Wheel rim
    final rimPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD54F), Color(0xFF8B6508), Color(0xFF5D4037)],
      ).createShader(Rect.fromCircle(center: wheelCenter, radius: wheelR))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawCircle(wheelCenter, wheelR, rimPaint);

    // Inner axle hub
    final hubPaint = Paint()..color = const Color(0xFFD4AF37);
    canvas.drawCircle(wheelCenter, 7.0, hubPaint);

    // Gear spokes
    final spokePaint = Paint()
      ..color = const Color(0xFFB8860B)
      ..strokeWidth = 2.5;
    for (int i = 0; i < 6; i++) {
      final angle = _gearRotation + (i * pi / 3);
      canvas.drawLine(
        wheelCenter,
        Offset(wheelCenter.dx + cos(angle) * wheelR, wheelCenter.dy + sin(angle) * wheelR),
        spokePaint,
      );
    }

    // Heavy carriage brackets (left and right wood/iron supports)
    final bracketPaint = Paint()..color = const Color(0xFF3E2723);
    final leftBracket = Path()
      ..moveTo(center.dx - 32, center.dy + 28)
      ..lineTo(center.dx - 12, center.dy + 8)
      ..lineTo(center.dx - 10, center.dy + 28)
      ..close();
    final rightBracket = Path()
      ..moveTo(center.dx + 32, center.dy + 28)
      ..lineTo(center.dx + 12, center.dy + 8)
      ..lineTo(center.dx + 10, center.dy + 28)
      ..close();
    canvas.drawPath(leftBracket, bracketPaint);
    canvas.drawPath(rightBracket, bracketPaint);
  }

  void _renderCannonBarrel(Canvas canvas, Offset center) {
    canvas.save();
    // Translate to pivot and rotate barrel
    canvas.translate(center.dx, center.dy);
    canvas.rotate(aimAngle + pi / 2); // default upright

    // Apply recoil
    canvas.translate(0, _recoilOffset);

    // 1. Swivel Gear Base
    final gearBasePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFD54F), Color(0xFF8B5A2B), Color(0xFF3E2723)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 22));
    canvas.drawCircle(Offset.zero, 20.0, gearBasePaint);

    // 2. Brass Cannon Barrel
    // Tapered barrel path
    final barrelPath = Path()
      ..moveTo(-16, -6)
      ..lineTo(-12, -48)
      ..lineTo(-15, -48) // muzzle flare step
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

    // Barrel reinforcing rings
    final ringPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawLine(const Offset(-14, -20), const Offset(14, -20), ringPaint);
    canvas.drawLine(const Offset(-13, -34), const Offset(13, -34), ringPaint);

    // 3. Loaded Bubble (visible inside the glowing breech/muzzle chamber)
    if (!isReloading) {
      final bubbleCenter = const Offset(0, -4);
      final r = GameConfig.bubbleRadius * 0.82;
      final grad = currentBubbleType.gradientColors;

      final loadedBubbleShader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 0.88,
        colors: grad,
        stops: const [0.0, 0.45, 0.82, 1.0],
      ).createShader(Rect.fromCircle(center: bubbleCenter, radius: r));

      final bubblePaint = Paint()..shader = loadedBubbleShader;
      canvas.drawCircle(bubbleCenter, r, bubblePaint);

      // Specular highlight
      final hlPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(bubbleCenter.dx - 4, bubbleCenter.dy - 4),
          width: r * 0.65,
          height: r * 0.4,
        ),
        hlPaint,
      );
    }

    // 4. Muzzle Burst Flash (on firing)
    if (_muzzleFlashAlpha > 0.05) {
      final flashPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: _muzzleFlashAlpha.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawCircle(const Offset(0, -56), 24.0 * _muzzleFlashAlpha, flashPaint);

      // Diamond energy cone (from reference image!)
      final conePath = Path()
        ..moveTo(0, -90)
        ..lineTo(-18, -56)
        ..lineTo(18, -56)
        ..close();
      final conePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFFFFE082).withValues(alpha: _muzzleFlashAlpha.clamp(0.0, 1.0)),
            Colors.transparent,
          ],
        ).createShader(const Rect.fromLTRB(-18, -90, 18, -56));
      canvas.drawPath(conePath, conePaint);
    }

    canvas.restore();
  }
}
