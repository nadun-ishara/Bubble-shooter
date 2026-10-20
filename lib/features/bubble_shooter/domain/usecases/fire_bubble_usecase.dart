import '../../../../core/usecases/usecase.dart';
import '../entities/cannon_entity.dart';
import '../entities/game_board.dart';
import '../entities/projectile_entity.dart';
import '../repositories/game_repository.dart';

class FireBubbleParams {
  final CannonEntity cannon;
  final GameBoard board;

  const FireBubbleParams({
    required this.cannon,
    required this.board,
  });
}

class FireBubbleResult {
  final CannonEntity updatedCannon;
  final ProjectileEntity projectile;

  const FireBubbleResult({
    required this.updatedCannon,
    required this.projectile,
  });
}

class FireBubbleUseCase implements UseCase<FireBubbleResult, FireBubbleParams> {
  final GameRepository repository;

  FireBubbleUseCase(this.repository);

  @override
  FireBubbleResult call(FireBubbleParams params) {
    final (cannon, projectile) = repository.fireBubble(
      cannon: params.cannon,
      board: params.board,
    );

    return FireBubbleResult(
      updatedCannon: cannon,
      projectile: projectile,
    );
  }
}
