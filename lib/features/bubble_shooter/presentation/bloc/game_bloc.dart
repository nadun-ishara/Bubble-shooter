import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/audio_helper.dart';
import '../../domain/usecases/aim_cannon_usecase.dart';
import '../../domain/usecases/fire_bubble_usecase.dart';
import '../../domain/usecases/get_high_score_usecase.dart';
import '../../domain/usecases/initialize_game_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../domain/usecases/swap_bubble_usecase.dart';
import '../../domain/usecases/update_physics_usecase.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final InitializeGameUseCase initializeGameUseCase;
  final AimCannonUseCase aimCannonUseCase;
  final FireBubbleUseCase fireBubbleUseCase;
  final SwapBubbleUseCase swapBubbleUseCase;
  final UpdatePhysicsUseCase updatePhysicsUseCase;
  final GetHighScoreUseCase getHighScoreUseCase;
  final SaveHighScoreUseCase saveHighScoreUseCase;

  GameBloc({
    required this.initializeGameUseCase,
    required this.aimCannonUseCase,
    required this.fireBubbleUseCase,
    required this.swapBubbleUseCase,
    required this.updatePhysicsUseCase,
    required this.getHighScoreUseCase,
    required this.saveHighScoreUseCase,
  }) : super(const GameState()) {
    on<StartGameEvent>(_onStartGame);
    on<AimEvent>(_onAim);
    on<CancelAimEvent>(_onCancelAim);
    on<FireEvent>(_onFire);
    on<SwapBubbleEvent>(_onSwapBubble);
    on<TickEvent>(_onTick);
    on<PauseGameEvent>(_onPauseGame);
    on<ResumeGameEvent>(_onResumeGame);
    on<RestartGameEvent>(_onRestartGame);
    on<ToggleSoundEvent>(_onToggleSound);
    on<ToggleAimLineEvent>(_onToggleAimLine);
  }

  Future<void> _onStartGame(StartGameEvent event, Emitter<GameState> emit) async {
    final currentHigh = await getHighScoreUseCase(const NoParams());
    final initData = initializeGameUseCase(InitializeGameParams(
      level: event.level,
      currentHighScore: currentHigh,
    ));

    emit(state.copyWith(
      status: GameStatus.playing,
      board: initData.board,
      cannon: initData.cannon,
      stats: initData.stats,
      clearProjectile: true,
      trajectory: const [],
    ));
  }

  void _onAim(AimEvent event, Emitter<GameState> emit) {
    if (!state.isInteractive) return;

    final result = aimCannonUseCase(AimCannonParams(
      cannon: state.cannon,
      board: state.board,
      targetX: event.targetX,
      targetY: event.targetY,
    ));

    emit(state.copyWith(
      cannon: result.updatedCannon,
      trajectory: state.aimLineEnabled ? result.trajectory : const [],
    ));
  }

  void _onCancelAim(CancelAimEvent event, Emitter<GameState> emit) {
    if (!state.isInteractive) return;
    emit(state.copyWith(
      cannon: state.cannon.copyWith(isAiming: false),
      trajectory: const [],
    ));
  }

  void _onFire(FireEvent event, Emitter<GameState> emit) {
    if (!state.isInteractive || state.hasActiveProjectile) return;

    final result = fireBubbleUseCase(FireBubbleParams(
      cannon: state.cannon,
      board: state.board,
    ));

    emit(state.copyWith(
      cannon: result.updatedCannon,
      projectile: result.projectile,
      trajectory: const [],
    ));
  }

  void _onSwapBubble(SwapBubbleEvent event, Emitter<GameState> emit) {
    if (!state.isInteractive || state.hasActiveProjectile) return;

    final updatedCannon = swapBubbleUseCase(state.cannon);
    emit(state.copyWith(cannon: updatedCannon));
  }

  void _onTick(TickEvent event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing) return;

    // Advance ambient cannon effects (recoil recovery, flash fade, gear spin)
    var updatedCannon = state.cannon;
    final newRecoil = max(0.0, updatedCannon.recoilOffset - event.dt * 65.0);
    final newFlash = max(0.0, updatedCannon.muzzleFlashAlpha - event.dt * 6.0);
    final newGearRot = updatedCannon.gearRotation + event.dt * 0.4;

    updatedCannon = updatedCannon.copyWith(
      recoilOffset: newRecoil,
      muzzleFlashAlpha: newFlash,
      gearRotation: newGearRot,
    );

    // Advance board and projectile physics
    final physicsResult = updatePhysicsUseCase(UpdatePhysicsParams(
      board: state.board,
      projectile: state.projectile,
      cannon: updatedCannon,
      stats: state.stats,
      dt: event.dt,
    ));

    GameStatus nextStatus = state.status;
    if (physicsResult.isGameOver) {
      nextStatus = GameStatus.gameOver;
      saveHighScoreUseCase(physicsResult.updatedStats.highScore);
    } else if (physicsResult.isVictory) {
      nextStatus = GameStatus.victory;
      saveHighScoreUseCase(physicsResult.updatedStats.highScore);
    }

    emit(state.copyWith(
      status: nextStatus,
      cannon: updatedCannon,
      board: physicsResult.updatedBoard,
      projectile: physicsResult.updatedProjectile,
      clearProjectile: physicsResult.updatedProjectile == null,
      stats: physicsResult.updatedStats,
    ));
  }

  void _onPauseGame(PauseGameEvent event, Emitter<GameState> emit) {
    if (state.status == GameStatus.playing) {
      emit(state.copyWith(status: GameStatus.paused));
    }
  }

  void _onResumeGame(ResumeGameEvent event, Emitter<GameState> emit) {
    if (state.status == GameStatus.paused) {
      emit(state.copyWith(status: GameStatus.playing));
    }
  }

  Future<void> _onRestartGame(RestartGameEvent event, Emitter<GameState> emit) async {
    final currentHigh = await getHighScoreUseCase(const NoParams());
    final initData = initializeGameUseCase(InitializeGameParams(
      level: state.stats.level,
      currentHighScore: currentHigh,
    ));

    emit(state.copyWith(
      status: GameStatus.playing,
      board: initData.board,
      cannon: initData.cannon,
      stats: initData.stats,
      clearProjectile: true,
      trajectory: const [],
    ));
  }

  void _onToggleSound(ToggleSoundEvent event, Emitter<GameState> emit) {
    final nextSound = !state.soundEnabled;
    AudioHelper.soundEnabled = nextSound;
    emit(state.copyWith(soundEnabled: nextSound));
  }

  void _onToggleAimLine(ToggleAimLineEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(aimLineEnabled: !state.aimLineEnabled));
  }
}
