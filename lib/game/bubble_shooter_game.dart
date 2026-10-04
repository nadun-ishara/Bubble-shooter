import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/background_component.dart';
import 'components/bubble_component.dart';
import 'components/bubble_grid_component.dart';
import 'components/shooter_component.dart';
import 'components/trajectory_component.dart';
import 'game_config.dart';

class BubbleShooterGame extends FlameGame {
  late final BackgroundComponent background;
  late final BubbleGridComponent bubbleGrid;
  late final ShooterComponent shooter;
  late final TrajectoryComponent trajectory;

  BubbleComponent? activeProjectile;

  // Observable state for Flutter HUD Overlays
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> missNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isGameOverNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isVictoryNotifier = ValueNotifier<bool>(false);

  int score = 0;
  bool isPausedGame = false;

  @override
  Color backgroundColor() => const Color(0xFF191310);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Add Steampunk Backdrop
    background = BackgroundComponent();
    await add(background);

    // 2. Add Hexagonal Bubble Grid
    bubbleGrid = BubbleGridComponent(
      onScoreEarned: (points, poppedCount, orphanCount) {
        score += points;
        scoreNotifier.value = score;
      },
      onMissCountChanged: (currentMisses, maxMisses) {
        missNotifier.value = currentMisses;
      },
      onGameOver: () {
        isGameOverNotifier.value = true;
        pauseEngine();
      },
      onVictory: () {
        isVictoryNotifier.value = true;
        pauseEngine();
      },
    );
    await add(bubbleGrid);

    // 3. Add Predictive Trajectory Line
    trajectory = TrajectoryComponent(gridComponent: bubbleGrid);
    await add(trajectory);

    // 4. Add Steampunk Cannon Shooter
    shooter = ShooterComponent(
      gridComponent: bubbleGrid,
      onFireBubble: (projectile) {
        activeProjectile = projectile;
        add(projectile);
      },
      onAimChanged: (aiming, muzzlePos, aimDir, type) {
        trajectory.updateAim(
          aiming: aiming,
          newOrigin: muzzlePos,
          newDirection: aimDir,
          bubbleType: type,
        );
      },
    );
    await add(shooter);
  }

  @override
  void update(double dt) {
    if (isPausedGame) return;
    super.update(dt);

    // Check collision for flying projectile
    if (activeProjectile != null && activeProjectile!.state == BubbleState.flying) {
      final hit = bubbleGrid.handleProjectileCollision(activeProjectile!);
      if (hit) {
        activeProjectile = null;
      }
    }
  }

  // --- External Input Handlers (bridged from Flutter GestureDetector) ---

  void handleTapDown(Vector2 screenPos) {
    if (isGameOverNotifier.value || isVictoryNotifier.value || isPausedGame) return;
    final worldPos = _toGameCoordinates(screenPos);

    // Check if player tapped the Next Bubble Reserve to swap
    final swapTarget = Vector2(GameConfig.cannonX - 64.0, GameConfig.cannonY + 8.0);
    if (worldPos.distanceTo(swapTarget) <= 30.0) {
      shooter.swapBubbles();
      return;
    }

    shooter.aimAt(worldPos);
  }

  void handleTapUp(Vector2 screenPos) {
    if (isGameOverNotifier.value || isVictoryNotifier.value || isPausedGame) return;
    final worldPos = _toGameCoordinates(screenPos);

    // Don't fire if tapped the swap button
    final swapTarget = Vector2(GameConfig.cannonX - 64.0, GameConfig.cannonY + 8.0);
    if (worldPos.distanceTo(swapTarget) <= 30.0) return;

    if (activeProjectile == null) {
      shooter.aimAt(worldPos);
      shooter.fire();
    }
  }

  void handleDragStart(Vector2 screenPos) {
    if (isGameOverNotifier.value || isVictoryNotifier.value || isPausedGame) return;
    final worldPos = _toGameCoordinates(screenPos);
    shooter.aimAt(worldPos);
  }

  void handleDragUpdate(Vector2 screenPos) {
    if (isGameOverNotifier.value || isVictoryNotifier.value || isPausedGame) return;
    final worldPos = _toGameCoordinates(screenPos);
    shooter.aimAt(worldPos);
  }

  void handleDragEnd() {
    if (isGameOverNotifier.value || isVictoryNotifier.value || isPausedGame) return;
    if (activeProjectile == null && shooter.isAiming) {
      shooter.fire();
    } else {
      shooter.cancelAim();
    }
  }

  /// Converts screen widget coordinates to fixed virtual game coordinates
  Vector2 _toGameCoordinates(Vector2 screenPos) {
    final scaleX = size.x / GameConfig.gameWidth;
    final scaleY = size.y / GameConfig.gameHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.x - GameConfig.gameWidth * scale) / 2;
    final offsetY = (size.y - GameConfig.gameHeight * scale) / 2;

    final gameX = (screenPos.x - offsetX) / scale;
    final gameY = (screenPos.y - offsetY) / scale;

    return Vector2(gameX, gameY);
  }

  /// Restart current level
  void restartLevel() {
    score = 0;
    scoreNotifier.value = 0;
    isGameOverNotifier.value = false;
    isVictoryNotifier.value = false;
    activeProjectile?.removeFromParent();
    activeProjectile = null;

    bubbleGrid.initializeGrid();
    shooter.cancelAim();
    resumeEngine();
  }

  /// Toggle pause
  void togglePause() {
    isPausedGame = !isPausedGame;
    if (isPausedGame) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }
}
