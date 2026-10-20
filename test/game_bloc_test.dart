import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_shooter/features/bubble_shooter/data/datasources/game_local_datasource.dart';
import 'package:bubble_shooter/features/bubble_shooter/data/repositories/game_repository_impl.dart';
import 'package:bubble_shooter/features/bubble_shooter/data/repositories/score_repository_impl.dart';
import 'package:bubble_shooter/features/bubble_shooter/domain/usecases/aim_cannon_usecase.dart';
import 'package:bubble_shooter/features/bubble_shooter/domain/usecases/fire_bubble_usecase.dart';
import 'package:bubble_shooter/features/bubble_shooter/domain/usecases/get_high_score_usecase.dart';
import 'package:bubble_shooter/features/bubble_shooter/domain/usecases/initialize_game_usecase.dart';
import 'package:bubble_shooter/features/bubble_shooter/domain/usecases/save_high_score_usecase.dart';
import 'package:bubble_shooter/features/bubble_shooter/domain/usecases/swap_bubble_usecase.dart';
import 'package:bubble_shooter/features/bubble_shooter/domain/usecases/update_physics_usecase.dart';
import 'package:bubble_shooter/features/bubble_shooter/presentation/bloc/game_bloc.dart';
import 'package:bubble_shooter/features/bubble_shooter/presentation/bloc/game_event.dart';
import 'package:bubble_shooter/features/bubble_shooter/presentation/bloc/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameBloc gameBloc;

  setUp(() {
    final localDataSource = GameLocalDataSourceImpl();
    final gameRepository = GameRepositoryImpl();
    final scoreRepository = ScoreRepositoryImpl(localDataSource);

    gameBloc = GameBloc(
      initializeGameUseCase: InitializeGameUseCase(gameRepository),
      aimCannonUseCase: AimCannonUseCase(gameRepository),
      fireBubbleUseCase: FireBubbleUseCase(gameRepository),
      swapBubbleUseCase: SwapBubbleUseCase(gameRepository),
      updatePhysicsUseCase: UpdatePhysicsUseCase(gameRepository),
      getHighScoreUseCase: GetHighScoreUseCase(scoreRepository),
      saveHighScoreUseCase: SaveHighScoreUseCase(scoreRepository),
    );
  });

  tearDown(() {
    gameBloc.close();
  });

  test('Initial GameBloc state is initial with 0 score', () {
    expect(gameBloc.state.status, GameStatus.initial);
    expect(gameBloc.state.stats.score, 0);
  });

  test('StartGameEvent initializes the board and transitions state to playing', () async {
    final futureExpect = expectLater(
      gameBloc.stream,
      emits(predicate<GameState>((state) {
        return state.status == GameStatus.playing && state.board.bubbles.isNotEmpty;
      })),
    );
    gameBloc.add(const StartGameEvent(level: 1));
    await futureExpect;
  });

  test('AimEvent calculates trajectory points and updates cannon aim angle', () async {
    gameBloc.add(const StartGameEvent(level: 1));
    await gameBloc.stream.firstWhere((s) => s.status == GameStatus.playing);

    final futureExpect = expectLater(
      gameBloc.stream,
      emits(predicate<GameState>((state) {
        return state.cannon.isAiming && state.trajectory.isNotEmpty;
      })),
    );
    gameBloc.add(const AimEvent(210, 200));
    await futureExpect;
  });

  test('SwapBubbleUseCase swaps current and next bubbles in cannon deterministically', () {
    const cannon = CannonEntity(
      loadedBubble: BubbleType.ruby,
      nextBubble: BubbleType.emerald,
    );
    final swapped = gameBloc.swapBubbleUseCase(cannon);
    expect(swapped.loadedBubble, BubbleType.emerald);
    expect(swapped.nextBubble, BubbleType.ruby);
  });

  test('PauseGameEvent and ResumeGameEvent toggle paused state properly', () async {
    gameBloc.add(const StartGameEvent(level: 1));
    await gameBloc.stream.firstWhere((s) => s.status == GameStatus.playing);

    final pauseExpect = expectLater(
      gameBloc.stream,
      emits(predicate<GameState>((state) => state.status == GameStatus.paused)),
    );
    gameBloc.add(const PauseGameEvent());
    await pauseExpect;

    final resumeExpect = expectLater(
      gameBloc.stream,
      emits(predicate<GameState>((state) => state.status == GameStatus.playing)),
    );
    gameBloc.add(const ResumeGameEvent());
    await resumeExpect;
  });
}
