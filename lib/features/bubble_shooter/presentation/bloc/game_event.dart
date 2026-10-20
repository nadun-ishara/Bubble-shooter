import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class StartGameEvent extends GameEvent {
  final int level;
  const StartGameEvent({this.level = 1});

  @override
  List<Object?> get props => [level];
}

class AimEvent extends GameEvent {
  final double targetX;
  final double targetY;
  const AimEvent(this.targetX, this.targetY);

  @override
  List<Object?> get props => [targetX, targetY];
}

class CancelAimEvent extends GameEvent {
  const CancelAimEvent();
}

class FireEvent extends GameEvent {
  const FireEvent();
}

class SwapBubbleEvent extends GameEvent {
  const SwapBubbleEvent();
}

class TickEvent extends GameEvent {
  final double dt;
  const TickEvent(this.dt);

  @override
  List<Object?> get props => [dt];
}

class PauseGameEvent extends GameEvent {
  const PauseGameEvent();
}

class ResumeGameEvent extends GameEvent {
  const ResumeGameEvent();
}

class RestartGameEvent extends GameEvent {
  const RestartGameEvent();
}

class ToggleSoundEvent extends GameEvent {
  const ToggleSoundEvent();
}

class ToggleAimLineEvent extends GameEvent {
  const ToggleAimLineEvent();
}
