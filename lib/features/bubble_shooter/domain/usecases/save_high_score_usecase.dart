import '../../../../core/usecases/usecase.dart';
import '../repositories/score_repository.dart';

class SaveHighScoreUseCase implements UseCase<Future<void>, int> {
  final ScoreRepository repository;

  SaveHighScoreUseCase(this.repository);

  @override
  Future<void> call(int score) {
    return repository.saveHighScore(score);
  }
}
