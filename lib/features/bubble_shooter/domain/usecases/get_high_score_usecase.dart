import '../../../../core/usecases/usecase.dart';
import '../repositories/score_repository.dart';

class GetHighScoreUseCase implements UseCase<Future<int>, NoParams> {
  final ScoreRepository repository;

  GetHighScoreUseCase(this.repository);

  @override
  Future<int> call(NoParams params) {
    return repository.getHighScore();
  }
}
