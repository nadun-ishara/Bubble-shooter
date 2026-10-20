import '../../../../core/usecases/usecase.dart';
import '../entities/cannon_entity.dart';
import '../repositories/game_repository.dart';

class SwapBubbleUseCase implements UseCase<CannonEntity, CannonEntity> {
  final GameRepository repository;

  SwapBubbleUseCase(this.repository);

  @override
  CannonEntity call(CannonEntity cannon) {
    return repository.swapBubbles(cannon);
  }
}
