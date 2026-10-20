import '../../../../core/usecases/usecase.dart';
import '../entities/cannon_entity.dart';
import '../entities/game_board.dart';
import '../entities/game_stats.dart';
import '../repositories/game_repository.dart';

class InitializeGameParams {
  final int level;
  final int currentHighScore;
  const InitializeGameParams({this.level = 1, this.currentHighScore = 0});
}

class InitializedGameData {
  final GameBoard board;
  final CannonEntity cannon;
  final GameStats stats;

  const InitializedGameData({
    required this.board,
    required this.cannon,
    required this.stats,
  });
}

class InitializeGameUseCase implements UseCase<InitializedGameData, InitializeGameParams> {
  final GameRepository repository;

  InitializeGameUseCase(this.repository);

  @override
  InitializedGameData call(InitializeGameParams params) {
    final board = repository.createInitialBoard(level: params.level);
    final cannon = repository.createInitialCannon(board);
    final stats = GameStats(
      score: 0,
      highScore: params.currentHighScore,
      level: params.level,
    );

    return InitializedGameData(
      board: board,
      cannon: cannon,
      stats: stats,
    );
  }
}
