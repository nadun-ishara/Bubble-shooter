import '../../../../core/usecases/usecase.dart';
import '../entities/cannon_entity.dart';
import '../entities/game_board.dart';
import '../entities/game_stats.dart';
import '../entities/projectile_entity.dart';
import '../repositories/game_repository.dart';

class UpdatePhysicsParams {
  final GameBoard board;
  final ProjectileEntity? projectile;
  final CannonEntity cannon;
  final GameStats stats;
  final double dt;

  const UpdatePhysicsParams({
    required this.board,
    required this.projectile,
    required this.cannon,
    required this.stats,
    required this.dt,
  });
}

class PhysicsStepResult {
  final GameBoard updatedBoard;
  final ProjectileEntity? updatedProjectile;
  final GameStats updatedStats;
  final bool isGameOver;
  final bool isVictory;

  const PhysicsStepResult({
    required this.updatedBoard,
    required this.updatedProjectile,
    required this.updatedStats,
    required this.isGameOver,
    required this.isVictory,
  });
}

class UpdatePhysicsUseCase implements UseCase<PhysicsStepResult, UpdatePhysicsParams> {
  final GameRepository repository;

  UpdatePhysicsUseCase(this.repository);

  @override
  PhysicsStepResult call(UpdatePhysicsParams params) {
    final (board, projectile, stats, isGameOver, isVictory) =
        repository.updatePhysicsTick(
      board: params.board,
      projectile: params.projectile,
      cannon: params.cannon,
      stats: params.stats,
      dt: params.dt,
    );

    return PhysicsStepResult(
      updatedBoard: board,
      updatedProjectile: projectile,
      updatedStats: stats,
      isGameOver: isGameOver,
      isVictory: isVictory,
    );
  }
}
