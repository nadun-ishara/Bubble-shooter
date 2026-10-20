import '../../../../core/usecases/usecase.dart';
import '../entities/cannon_entity.dart';
import '../entities/game_board.dart';
import '../entities/trajectory_point.dart';
import '../repositories/game_repository.dart';

class AimCannonParams {
  final CannonEntity cannon;
  final GameBoard board;
  final double targetX;
  final double targetY;

  const AimCannonParams({
    required this.cannon,
    required this.board,
    required this.targetX,
    required this.targetY,
  });
}

class AimCannonResult {
  final CannonEntity updatedCannon;
  final List<TrajectoryPoint> trajectory;

  const AimCannonResult({
    required this.updatedCannon,
    required this.trajectory,
  });
}

class AimCannonUseCase implements UseCase<AimCannonResult, AimCannonParams> {
  final GameRepository repository;

  AimCannonUseCase(this.repository);

  @override
  AimCannonResult call(AimCannonParams params) {
    final (cannon, trajectory) = repository.calculateAim(
      cannon: params.cannon,
      board: params.board,
      targetX: params.targetX,
      targetY: params.targetY,
    );

    return AimCannonResult(
      updatedCannon: cannon,
      trajectory: trajectory,
    );
  }
}
