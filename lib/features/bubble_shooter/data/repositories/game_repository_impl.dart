import 'dart:collection';
import 'dart:math';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/utils/audio_helper.dart';
import '../../domain/entities/bubble_entity.dart';
import '../../domain/entities/bubble_type.dart';
import '../../domain/entities/cannon_entity.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/entities/game_stats.dart';
import '../../domain/entities/grid_position.dart';
import '../../domain/entities/projectile_entity.dart';
import '../../domain/entities/trajectory_point.dart';
import '../../domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final Random _rng = Random();

  @override
  GameBoard createInitialBoard({int rows = 5, int level = 1}) {
    final bubbles = <GridPosition, BubbleEntity>{};
    // Pick subset of bubble types (e.g. 5 colors for initial levels)
    final availableTypes = BubbleType.values.take(5).toList();

    for (int r = 0; r < rows; r++) {
      final maxCols = (r % 2 == 0) ? GameConstants.columnsEven : GameConstants.columnsOdd;
      for (int c = 0; c < maxCols; c++) {
        final pos = GridPosition(r, c);
        final type = availableTypes[_rng.nextInt(availableTypes.length)];
        final (x, y) = pos.toWorldCoordinates(0.0);

        bubbles[pos] = BubbleEntity(
          id: 'bubble_${r}_$c',
          type: type,
          gridPosition: pos,
          x: x,
          y: y,
          lifeCycle: BubbleLifeCycle.idle,
        );
      }
    }

    return GameBoard(
      bubbles: bubbles,
      dynamicBubbles: const [],
      gridOffsetY: 0.0,
      foulCount: 0,
      maxFouls: GameConstants.maxFoulsBeforeDrop,
    );
  }

  @override
  CannonEntity createInitialCannon(GameBoard board) {
    final pool = board.getAvailableTypes();
    return CannonEntity(
      aimAngle: -pi / 2,
      isAiming: false,
      loadedBubble: BubbleType.random(_rng, pool),
      nextBubble: BubbleType.random(_rng, pool),
      recoilOffset: 0.0,
      muzzleFlashAlpha: 0.0,
      gearRotation: 0.0,
    );
  }

  @override
  (CannonEntity, List<TrajectoryPoint>) calculateAim({
    required CannonEntity cannon,
    required GameBoard board,
    required double targetX,
    required double targetY,
  }) {
    final diffX = targetX - GameConstants.cannonX;
    final diffY = targetY - GameConstants.cannonY;

    double angle = atan2(diffY, diffX);

    // Clamp angle so cannon only points upward
    if (angle > 0) {
      angle = (diffX < 0) ? GameConstants.minAimAngle : GameConstants.maxAimAngle;
    } else {
      angle = angle.clamp(GameConstants.minAimAngle, GameConstants.maxAimAngle);
    }

    final updatedCannon = cannon.copyWith(
      aimAngle: angle,
      isAiming: true,
    );

    // Calculate predictive trajectory line with wall bounces
    final points = <TrajectoryPoint>[];
    const r = GameConstants.bubbleRadius;
    const leftBound = GameConstants.wallMarginLeft + r;
    const rightBound = GameConstants.wallMarginRight - r;
    final ceilingY = GameConstants.ceilingBaseY + board.gridOffsetY + r;
    const collisionDist = GameConstants.bubbleDiameter * 0.94;

    var curX = GameConstants.cannonX + cos(angle) * 48.0;
    var curY = GameConstants.cannonY + sin(angle) * 48.0;
    var dirX = cos(angle);
    var dirY = sin(angle);

    const double stepSize = 14.0;
    const int maxSteps = 45;

    for (int step = 0; step < maxSteps; step++) {
      curX += dirX * stepSize;
      curY += dirY * stepSize;

      bool bounced = false;
      if (curX <= leftBound) {
        curX = leftBound;
        dirX = -dirX;
        bounced = true;
      } else if (curX >= rightBound) {
        curX = rightBound;
        dirX = -dirX;
        bounced = true;
      }

      points.add(TrajectoryPoint(x: curX, y: curY, isWallBounce: bounced));

      // Stop if hitting ceiling
      if (curY <= ceilingY) break;

      // Stop if hitting an idle bubble on the board
      bool hitBubble = false;
      for (final bubble in board.bubbles.values) {
        if (bubble.lifeCycle != BubbleLifeCycle.idle) continue;
        final dx = curX - bubble.x;
        final dy = curY - bubble.y;
        if (sqrt(dx * dx + dy * dy) <= collisionDist) {
          hitBubble = true;
          break;
        }
      }
      if (hitBubble) break;
    }

    return (updatedCannon, points);
  }

  @override
  (CannonEntity, ProjectileEntity) fireBubble({
    required CannonEntity cannon,
    required GameBoard board,
  }) {
    AudioHelper.playFire();

    final dirX = cos(cannon.aimAngle);
    final dirY = sin(cannon.aimAngle);
    final muzzleX = GameConstants.cannonX + dirX * 46.0;
    final muzzleY = GameConstants.cannonY + dirY * 46.0;

    final projectile = ProjectileEntity(
      type: cannon.loadedBubble,
      x: muzzleX,
      y: muzzleY,
      vx: dirX * GameConstants.projectileSpeed,
      vy: dirY * GameConstants.projectileSpeed,
    );

    final pool = board.getAvailableTypes();
    final updatedCannon = cannon.copyWith(
      isAiming: false,
      loadedBubble: cannon.nextBubble,
      nextBubble: BubbleType.random(_rng, pool),
      recoilOffset: 14.0,
      muzzleFlashAlpha: 1.0,
    );

    return (updatedCannon, projectile);
  }

  @override
  CannonEntity swapBubbles(CannonEntity cannon) {
    AudioHelper.playSwap();
    return cannon.copyWith(
      loadedBubble: cannon.nextBubble,
      nextBubble: cannon.loadedBubble,
    );
  }

  @override
  (
    GameBoard updatedBoard,
    ProjectileEntity? updatedProjectile,
    GameStats updatedStats,
    bool isGameOver,
    bool isVictory,
  ) updatePhysicsTick({
    required GameBoard board,
    required ProjectileEntity? projectile,
    required CannonEntity cannon,
    required GameStats stats,
    required double dt,
  }) {
    var newBoard = board;
    var newProjectile = projectile;
    var newStats = stats;

    // 1. Advance dynamic bubbles (popping fade & orphan falling)
    final survivingDynamics = <BubbleEntity>[];
    for (final dynamicBubble in board.dynamicBubbles) {
      if (dynamicBubble.lifeCycle == BubbleLifeCycle.popping) {
        final newScale = max(0.0, dynamicBubble.scale - dt * 5.0);
        final newAlpha = max(0.0, dynamicBubble.alpha - dt * 4.5);
        if (newScale > 0.05 && newAlpha > 0.05) {
          survivingDynamics.add(dynamicBubble.copyWith(
            scale: newScale,
            alpha: newAlpha,
          ));
        }
      } else if (dynamicBubble.lifeCycle == BubbleLifeCycle.falling) {
        const gravity = 1400.0;
        final newVy = dynamicBubble.velocityY + gravity * dt;
        final newX = dynamicBubble.x + dynamicBubble.velocityX * dt;
        final newY = dynamicBubble.y + newVy * dt;
        if (newY < GameConstants.virtualHeight + 80.0) {
          survivingDynamics.add(dynamicBubble.copyWith(
            x: newX,
            y: newY,
            velocityY: newVy,
          ));
        }
      }
    }
    newBoard = newBoard.copyWith(dynamicBubbles: survivingDynamics);

    // 2. Advance projectile physics and collision
    if (newProjectile != null) {
      var projX = newProjectile.x + newProjectile.vx * dt;
      var projY = newProjectile.y + newProjectile.vy * dt;
      var projVx = newProjectile.vx;
      var projVy = newProjectile.vy;

      const r = GameConstants.bubbleRadius;
      const leftBound = GameConstants.wallMarginLeft + r;
      const rightBound = GameConstants.wallMarginRight - r;

      // Wall bounce
      if (projX <= leftBound) {
        projX = leftBound;
        projVx = -projVx;
        AudioHelper.playBounce();
      } else if (projX >= rightBound) {
        projX = rightBound;
        projVx = -projVx;
        AudioHelper.playBounce();
      }

      final ceilingY = GameConstants.ceilingBaseY + newBoard.gridOffsetY + r;
      const collisionDist = GameConstants.bubbleDiameter * 0.93;

      bool hit = false;
      GridPosition? hitNeighborRef;

      if (projY <= ceilingY) {
        hit = true;
      } else {
        for (final entry in newBoard.bubbles.entries) {
          final bubble = entry.value;
          if (bubble.lifeCycle != BubbleLifeCycle.idle) continue;

          final dx = projX - bubble.x;
          final dy = projY - bubble.y;
          if (sqrt(dx * dx + dy * dy) <= collisionDist) {
            hit = true;
            hitNeighborRef = entry.key;
            break;
          }
        }
      }

      if (hit) {
        // Snap projectile to closest valid hexagonal slot
        final snappedSlot = _findBestGridSlot(
          projX: projX,
          projY: projY,
          hitRef: hitNeighborRef,
          board: newBoard,
        );

        final (slotX, slotY) = snappedSlot.toWorldCoordinates(newBoard.gridOffsetY);
        final attachedBubble = BubbleEntity(
          id: 'bubble_${snappedSlot.row}_${snappedSlot.col}_${DateTime.now().microsecondsSinceEpoch}',
          type: newProjectile.type,
          gridPosition: snappedSlot,
          x: slotX,
          y: slotY,
          lifeCycle: BubbleLifeCycle.idle,
        );

        final updatedBubbles = Map<GridPosition, BubbleEntity>.from(newBoard.bubbles);
        updatedBubbles[snappedSlot] = attachedBubble;
        newBoard = newBoard.copyWith(bubbles: updatedBubbles);
        newProjectile = null; // Projectile resolved

        // Run BFS Match-3 evaluation
        final (postMatchBoard, earnedScore, poppedCount, orphanCount) =
            _evaluateMatchesAndOrphans(
          root: snappedSlot,
          targetType: attachedBubble.type,
          board: newBoard,
        );

        newBoard = postMatchBoard;

        if (poppedCount >= 3) {
          AudioHelper.playPop();
          final newScore = newStats.score + earnedScore;
          final newHighScore = max(newStats.highScore, newScore);
          newStats = newStats.copyWith(
            score: newScore,
            highScore: newHighScore,
            popsCount: newStats.popsCount + poppedCount,
            orphansCount: newStats.orphansCount + orphanCount,
            comboStreak: newStats.comboStreak + 1,
          );
        } else {
          // Missed match: increment fouls and potentially drop ceiling
          int nextFouls = newBoard.foulCount + 1;
          double nextOffsetY = newBoard.gridOffsetY;

          if (nextFouls >= newBoard.maxFouls) {
            nextFouls = 0;
            nextOffsetY += GameConstants.rowHeight;
            // Shift all grid bubbles down by rowHeight
            final shifted = <GridPosition, BubbleEntity>{};
            for (final entry in newBoard.bubbles.entries) {
              final (bx, by) = entry.key.toWorldCoordinates(nextOffsetY);
              shifted[entry.key] = entry.value.copyWith(x: bx, y: by);
            }
            newBoard = newBoard.copyWith(
              bubbles: shifted,
              gridOffsetY: nextOffsetY,
              foulCount: nextFouls,
            );
          } else {
            newBoard = newBoard.copyWith(foulCount: nextFouls);
          }

          newStats = newStats.copyWith(comboStreak: 0);
        }
      } else {
        newProjectile = newProjectile.copyWith(
          x: projX,
          y: projY,
          vx: projVx,
          vy: projVy,
        );
      }
    }

    // 3. Victory and Game Over checks
    final isGameOver = newBoard.isDangerCrossed();
    final isVictory = newBoard.isCleared();

    if (isGameOver) {
      AudioHelper.playDefeat();
    } else if (isVictory) {
      AudioHelper.playVictory();
    }

    return (newBoard, newProjectile, newStats, isGameOver, isVictory);
  }

  GridPosition _findBestGridSlot({
    required double projX,
    required double projY,
    required GridPosition? hitRef,
    required GameBoard board,
  }) {
    final candidates = <GridPosition>{};

    if (hitRef != null) {
      for (final n in hitRef.getNeighbors()) {
        if (n.isValid() && !board.bubbles.containsKey(n)) {
          candidates.add(n);
        }
      }
    }

    // Check row 0 near ceiling
    if (candidates.isEmpty ||
        (projY - GameConstants.ceilingBaseY - board.gridOffsetY).abs() < GameConstants.rowHeight * 1.5) {
      for (int c = 0; c < GameConstants.columnsEven; c++) {
        final pos = GridPosition(0, c);
        if (!board.bubbles.containsKey(pos)) {
          candidates.add(pos);
        }
      }
    }

    // Expand search if needed
    if (candidates.isEmpty) {
      for (final pos in board.bubbles.keys) {
        for (final n in pos.getNeighbors()) {
          if (n.isValid() && !board.bubbles.containsKey(n)) {
            candidates.add(n);
          }
        }
      }
    }

    GridPosition? bestSlot;
    double minDistance = double.infinity;

    for (final pos in candidates) {
      final (slotX, slotY) = pos.toWorldCoordinates(board.gridOffsetY);
      final dx = projX - slotX;
      final dy = projY - slotY;
      final dist = dx * dx + dy * dy;
      if (dist < minDistance) {
        minDistance = dist;
        bestSlot = pos;
      }
    }

    return bestSlot ?? const GridPosition(0, 0);
  }

  (GameBoard, int earnedScore, int poppedCount, int orphanCount) _evaluateMatchesAndOrphans({
    required GridPosition root,
    required BubbleType targetType,
    required GameBoard board,
  }) {
    final matchingCluster = <GridPosition>{};
    final queue = Queue<GridPosition>()..add(root);
    final visited = <GridPosition>{root};

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final bubble = board.bubbles[current];

      if (bubble != null && bubble.type == targetType && bubble.lifeCycle == BubbleLifeCycle.idle) {
        matchingCluster.add(current);

        for (final neighbor in current.getNeighbors()) {
          if (!visited.contains(neighbor) && board.bubbles.containsKey(neighbor)) {
            visited.add(neighbor);
            queue.add(neighbor);
          }
        }
      }
    }

    if (matchingCluster.length < 3) {
      return (board, 0, 0, 0);
    }

    // MATCH FOUND: Convert matched bubbles into popping dynamic entities
    final updatedBubbles = Map<GridPosition, BubbleEntity>.from(board.bubbles);
    final newDynamics = List<BubbleEntity>.from(board.dynamicBubbles);

    for (final pos in matchingCluster) {
      final popped = updatedBubbles.remove(pos);
      if (popped != null) {
        newDynamics.add(popped.copyWith(lifeCycle: BubbleLifeCycle.popping));
      }
    }

    // Check for severed orphan bubbles
    final connectedToCeiling = <GridPosition>{};
    final ceilingQueue = Queue<GridPosition>();

    for (final entry in updatedBubbles.entries) {
      if (entry.key.row == 0 && entry.value.lifeCycle == BubbleLifeCycle.idle) {
        connectedToCeiling.add(entry.key);
        ceilingQueue.add(entry.key);
      }
    }

    while (ceilingQueue.isNotEmpty) {
      final current = ceilingQueue.removeFirst();
      for (final neighbor in current.getNeighbors()) {
        if (!connectedToCeiling.contains(neighbor) &&
            updatedBubbles.containsKey(neighbor) &&
            updatedBubbles[neighbor]!.lifeCycle == BubbleLifeCycle.idle) {
          connectedToCeiling.add(neighbor);
          ceilingQueue.add(neighbor);
        }
      }
    }

    final orphans = <GridPosition>{};
    for (final pos in updatedBubbles.keys) {
      if (!connectedToCeiling.contains(pos)) {
        orphans.add(pos);
      }
    }

    for (final pos in orphans) {
      final orphan = updatedBubbles.remove(pos);
      if (orphan != null) {
        final vx = (_rng.nextDouble() - 0.5) * 180.0;
        final vy = -60.0 - _rng.nextDouble() * 120.0;
        newDynamics.add(orphan.copyWith(
          lifeCycle: BubbleLifeCycle.falling,
          velocityX: vx,
          velocityY: vy,
        ));
      }
    }

    final popPoints = matchingCluster.length * GameConstants.pointsPerBubblePop;
    final orphanPoints = orphans.length * GameConstants.pointsPerOrphanDrop;
    final total = popPoints + orphanPoints;

    final resultBoard = board.copyWith(
      bubbles: updatedBubbles,
      dynamicBubbles: newDynamics,
    );

    return (resultBoard, total, matchingCluster.length, orphans.length);
  }
}
