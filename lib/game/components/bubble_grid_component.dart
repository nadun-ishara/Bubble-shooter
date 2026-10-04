import 'dart:collection';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_config.dart';
import '../models/bubble_type.dart';
import '../models/grid_position.dart';
import 'bubble_component.dart';
import 'effects/pop_particles.dart';

class BubbleGridComponent extends PositionComponent {
  final Map<GridPosition, BubbleComponent> grid = {};
  double gridOffsetY = 0.0;
  int missCount = 0;

  // Callbacks to game controller
  void Function(int points, int poppedCount, int orphanCount)? onScoreEarned;
  void Function(int currentMisses, int maxMisses)? onMissCountChanged;
  void Function()? onGameOver;
  void Function()? onVictory;

  BubbleGridComponent({
    this.onScoreEarned,
    this.onMissCountChanged,
    this.onGameOver,
    this.onVictory,
  });

  @override
  void onLoad() {
    super.onLoad();
    initializeGrid();
  }

  /// Initialize the board with starting rows
  void initializeGrid() {
    // Clear any existing children
    for (final b in grid.values) {
      b.removeFromParent();
    }
    grid.clear();
    missCount = 0;
    gridOffsetY = 0.0;
    onMissCountChanged?.call(missCount, GameConfig.missesBeforeCeilingDrop);

    final rng = Random();
    // Choose a subset of colors for the level to make matching fun and achievable
    final activeTypes = BubbleType.values.take(5).toList();

    for (int r = 0; r < GameConfig.initialRows; r++) {
      final maxCols = (r % 2 == 0) ? GameConfig.columnsEven : GameConfig.columnsOdd;
      for (int c = 0; c < maxCols; c++) {
        final pos = GridPosition(r, c);
        final type = activeTypes[rng.nextInt(activeTypes.length)];
        _addBubbleToGrid(pos, type);
      }
    }
  }

  void _addBubbleToGrid(GridPosition pos, BubbleType type) {
    final worldPos = pos.toWorldPosition(gridOffsetY);
    final bubble = BubbleComponent(
      bubbleType: type,
      gridPosition: pos,
      position: worldPos,
      state: BubbleState.idle,
    );
    grid[pos] = bubble;
    add(bubble);
  }

  /// Returns list of active bubble types present on the grid
  List<BubbleType> getAvailableBubbleTypes() {
    final types = grid.values.map((b) => b.bubbleType).toSet().toList();
    return types.isNotEmpty ? types : BubbleType.values;
  }

  /// Check projectile collision against all bubbles and ceiling
  bool handleProjectileCollision(BubbleComponent projectile) {
    if (projectile.state != BubbleState.flying) return false;

    final projPos = projectile.position;
    final r = GameConfig.bubbleRadius;
    final collisionDist = GameConfig.bubbleDiameter * 0.92;

    bool hit = false;
    GridPosition? hitNeighborRef;

    // 1. Collision with ceiling
    if (projPos.y - r <= GameConfig.ceilingY + gridOffsetY) {
      hit = true;
    } else {
      // 2. Collision with any grid bubble
      for (final entry in grid.entries) {
        final bubble = entry.value;
        if (bubble.state != BubbleState.idle) continue;

        final dist = projPos.distanceTo(bubble.position);
        if (dist <= collisionDist) {
          hit = true;
          hitNeighborRef = entry.key;
          break;
        }
      }
    }

    if (hit) {
      _snapProjectileToGrid(projectile, hitNeighborRef);
      return true;
    }

    return false;
  }

  void _snapProjectileToGrid(BubbleComponent projectile, GridPosition? hitRef) {
    projectile.velocity = Vector2.zero();

    // Find the closest unoccupied valid grid slot
    GridPosition? bestSlot;
    double minDistance = double.infinity;

    final candidates = <GridPosition>{};

    if (hitRef != null) {
      // Prioritize neighbors of the impacted bubble
      for (final n in hitRef.getNeighbors()) {
        if (n.isValid() && !grid.containsKey(n)) {
          candidates.add(n);
        }
      }
    }

    // Also consider top row slots if near ceiling
    if (candidates.isEmpty || (projectile.position.y - GameConfig.ceilingY - gridOffsetY).abs() < GameConfig.rowHeight * 1.5) {
      for (int c = 0; c < GameConfig.columnsEven; c++) {
        final pos = GridPosition(0, c);
        if (!grid.containsKey(pos)) {
          candidates.add(pos);
        }
      }
    }

    // Expand search if needed
    if (candidates.isEmpty) {
      for (final entry in grid.keys) {
        for (final n in entry.getNeighbors()) {
          if (n.isValid() && !grid.containsKey(n)) {
            candidates.add(n);
          }
        }
      }
    }

    for (final pos in candidates) {
      final slotWorldPos = pos.toWorldPosition(gridOffsetY);
      final dist = projectile.position.distanceTo(slotWorldPos);
      if (dist < minDistance) {
        minDistance = dist;
        bestSlot = pos;
      }
    }

    bestSlot ??= const GridPosition(0, 0);

    // Attach to grid
    projectile.gridPosition = bestSlot;
    projectile.state = BubbleState.idle;
    projectile.position = bestSlot.toWorldPosition(gridOffsetY);
    grid[bestSlot] = projectile;

    // Run Match-3 BFS
    _evaluateMatches(bestSlot, projectile.bubbleType);
  }

  void _evaluateMatches(GridPosition root, BubbleType targetType) {
    final matchingCluster = <GridPosition>{};
    final queue = Queue<GridPosition>()..add(root);
    final visited = <GridPosition>{root};

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final bubble = grid[current];

      if (bubble != null && bubble.bubbleType == targetType && bubble.state == BubbleState.idle) {
        matchingCluster.add(current);

        for (final neighbor in current.getNeighbors()) {
          if (!visited.contains(neighbor) && grid.containsKey(neighbor)) {
            visited.add(neighbor);
            queue.add(neighbor);
          }
        }
      }
    }

    if (matchingCluster.length >= 3) {
      // MATCH SUCCESS: Pop all matching bubbles!
      for (final pos in matchingCluster) {
        final b = grid.remove(pos);
        if (b != null) {
          b.pop();
          parent?.add(PopParticleEmitter(
            position: b.position.clone(),
            color: b.bubbleType.primaryColor,
          ));
        }
      }

      // Check for orphan bubbles (not anchored to ceiling)
      final orphans = _findOrphanBubbles();
      for (final pos in orphans) {
        final b = grid.remove(pos);
        if (b != null) {
          b.fall();
          parent?.add(PopParticleEmitter(
            position: b.position.clone(),
            color: b.bubbleType.primaryColor,
            count: 6,
          ));
        }
      }

      // Calculate score
      final popPoints = matchingCluster.length * GameConfig.pointsPerBubblePop;
      final orphanPoints = orphans.length * GameConfig.pointsPerOrphanDrop;
      final total = popPoints + orphanPoints;
      onScoreEarned?.call(total, matchingCluster.length, orphans.length);

      // Check for Victory
      if (grid.isEmpty) {
        onVictory?.call();
        return;
      }
    } else {
      // MISSED MATCH: Increase miss counter
      missCount++;
      onMissCountChanged?.call(missCount, GameConfig.missesBeforeCeilingDrop);

      if (missCount >= GameConfig.missesBeforeCeilingDrop) {
        _dropCeiling();
      }
    }

    // Check for Game Over (bubbles crossed danger line)
    _checkGameOver();
  }

  /// BFS to find all bubbles connected to the ceiling (row 0)
  Set<GridPosition> _findOrphanBubbles() {
    final connectedToCeiling = <GridPosition>{};
    final queue = Queue<GridPosition>();

    // Seed with all bubbles in row 0
    for (final entry in grid.entries) {
      if (entry.key.row == 0 && entry.value.state == BubbleState.idle) {
        connectedToCeiling.add(entry.key);
        queue.add(entry.key);
      }
    }

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      for (final neighbor in current.getNeighbors()) {
        if (!connectedToCeiling.contains(neighbor) &&
            grid.containsKey(neighbor) &&
            grid[neighbor]!.state == BubbleState.idle) {
          connectedToCeiling.add(neighbor);
          queue.add(neighbor);
        }
      }
    }

    // Any bubble in grid not connected to ceiling is an orphan
    final orphans = <GridPosition>{};
    for (final pos in grid.keys) {
      if (!connectedToCeiling.contains(pos)) {
        orphans.add(pos);
      }
    }
    return orphans;
  }

  void _dropCeiling() {
    missCount = 0;
    gridOffsetY += GameConfig.rowHeight;
    onMissCountChanged?.call(missCount, GameConfig.missesBeforeCeilingDrop);

    // Update all bubble world positions
    for (final entry in grid.entries) {
      entry.value.position = entry.key.toWorldPosition(gridOffsetY);
    }
  }

  void _checkGameOver() {
    final r = GameConfig.bubbleRadius;
    for (final b in grid.values) {
      if (b.state == BubbleState.idle && b.position.y + r >= GameConfig.dangerY) {
        onGameOver?.call();
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the movable ceiling bar (steampunk brass beam)
    final ceilingTop = GameConfig.ceilingY + gridOffsetY;
    final beamRect = Rect.fromLTRB(
      GameConfig.wallMarginLeft,
      ceilingTop - 12.0,
      GameConfig.wallMarginRight,
      ceilingTop,
    );

    // Brass gradient for ceiling beam
    final beamGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFFFFD54F),
        Color(0xFFB8860B),
        Color(0xFF5D4037),
      ],
    );

    final beamPaint = Paint()
      ..shader = beamGradient.createShader(beamRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(beamRect, const Radius.circular(4.0)),
      beamPaint,
    );

    // Ceiling bolts/rivets
    final rivetPaint = Paint()..color = const Color(0xFF3E2723);
    for (double x = GameConfig.wallMarginLeft + 20; x < GameConfig.wallMarginRight; x += 35) {
      canvas.drawCircle(Offset(x, ceilingTop - 6.0), 2.5, rivetPaint);
    }
  }
}
