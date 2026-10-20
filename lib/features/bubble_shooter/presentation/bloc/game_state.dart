import 'dart:math';
import 'package:equatable/equatable.dart';
import '../../domain/entities/bubble_type.dart';
import '../../domain/entities/cannon_entity.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/entities/game_stats.dart';
import '../../domain/entities/projectile_entity.dart';
import '../../domain/entities/trajectory_point.dart';

enum GameStatus {
  initial,
  playing,
  paused,
  gameOver,
  victory,
}

class GameState extends Equatable {
  final GameStatus status;
  final GameBoard board;
  final CannonEntity cannon;
  final ProjectileEntity? projectile;
  final List<TrajectoryPoint> trajectory;
  final GameStats stats;
  final bool soundEnabled;
  final bool aimLineEnabled;

  const GameState({
    this.status = GameStatus.initial,
    this.board = const GameBoard(),
    this.cannon = const CannonEntity(
      aimAngle: -pi / 2,
      loadedBubble: BubbleType.ruby,
      nextBubble: BubbleType.emerald,
    ),
    this.projectile,
    this.trajectory = const [],
    this.stats = const GameStats(),
    this.soundEnabled = true,
    this.aimLineEnabled = true,
  });

  bool get isInteractive => status == GameStatus.playing;
  bool get hasActiveProjectile => projectile != null;

  GameState copyWith({
    GameStatus? status,
    GameBoard? board,
    CannonEntity? cannon,
    ProjectileEntity? projectile,
    bool clearProjectile = false,
    List<TrajectoryPoint>? trajectory,
    GameStats? stats,
    bool? soundEnabled,
    bool? aimLineEnabled,
  }) {
    return GameState(
      status: status ?? this.status,
      board: board ?? this.board,
      cannon: cannon ?? this.cannon,
      projectile: clearProjectile ? null : (projectile ?? this.projectile),
      trajectory: trajectory ?? this.trajectory,
      stats: stats ?? this.stats,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      aimLineEnabled: aimLineEnabled ?? this.aimLineEnabled,
    );
  }

  @override
  List<Object?> get props => [
        status,
        board,
        cannon,
        projectile,
        trajectory,
        stats,
        soundEnabled,
        aimLineEnabled,
      ];
}
