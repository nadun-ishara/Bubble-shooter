import '../entities/cannon_entity.dart';
import '../entities/game_board.dart';
import '../entities/game_stats.dart';
import '../entities/projectile_entity.dart';
import '../entities/trajectory_point.dart';

abstract class GameRepository {
  /// Generate a fresh board for a given level
  GameBoard createInitialBoard({int rows = 5, int level = 1});

  /// Generate a fresh cannon with randomized orbs
  CannonEntity createInitialCannon(GameBoard board);

  /// Calculate aim angle and trajectory points from touch target
  (CannonEntity, List<TrajectoryPoint>) calculateAim({
    required CannonEntity cannon,
    required GameBoard board,
    required double targetX,
    required double targetY,
  });

  /// Create a fired projectile from current cannon position and angle
  (CannonEntity, ProjectileEntity) fireBubble({
    required CannonEntity cannon,
    required GameBoard board,
  });

  /// Swap loaded bubble with next bubble in reserve
  CannonEntity swapBubbles(CannonEntity cannon);

  /// Update projectile and dynamic particles movement by dt seconds
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
  });
}
