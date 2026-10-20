import '../../domain/repositories/score_repository.dart';
import '../datasources/game_local_datasource.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  final GameLocalDataSource localDataSource;

  ScoreRepositoryImpl(this.localDataSource);

  @override
  Future<int> getHighScore() {
    return localDataSource.getHighScore();
  }

  @override
  Future<void> saveHighScore(int score) {
    return localDataSource.saveHighScore(score);
  }
}
