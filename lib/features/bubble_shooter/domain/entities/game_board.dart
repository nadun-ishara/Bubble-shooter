import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/game_constants.dart';
import 'bubble_entity.dart';
import 'bubble_type.dart';
import 'grid_position.dart';

@immutable
class GameBoard extends Equatable {
  final Map<GridPosition, BubbleEntity> bubbles;
  final List<BubbleEntity> dynamicBubbles; // Popping or falling animations
  final double gridOffsetY;
  final int foulCount;
  final int maxFouls;

  const GameBoard({
    this.bubbles = const {},
    this.dynamicBubbles = const [],
    this.gridOffsetY = 0.0,
    this.foulCount = 0,
    this.maxFouls = GameConstants.maxFoulsBeforeDrop,
  });

  GameBoard copyWith({
    Map<GridPosition, BubbleEntity>? bubbles,
    List<BubbleEntity>? dynamicBubbles,
    double? gridOffsetY,
    int? foulCount,
    int? maxFouls,
  }) {
    return GameBoard(
      bubbles: bubbles ?? this.bubbles,
      dynamicBubbles: dynamicBubbles ?? this.dynamicBubbles,
      gridOffsetY: gridOffsetY ?? this.gridOffsetY,
      foulCount: foulCount ?? this.foulCount,
      maxFouls: maxFouls ?? this.maxFouls,
    );
  }

  /// Get distinct types of bubbles currently on the active grid
  List<BubbleType> getAvailableTypes() {
    final types = bubbles.values
        .where((b) => b.lifeCycle == BubbleLifeCycle.idle)
        .map((b) => b.type)
        .toSet()
        .toList();
    return types.isNotEmpty ? types : BubbleType.values;
  }

  /// Check if any bubble has reached the danger threshold
  bool isDangerCrossed() {
    const r = GameConstants.bubbleRadius;
    for (final b in bubbles.values) {
      if (b.lifeCycle == BubbleLifeCycle.idle && b.y + r >= GameConstants.dangerLineY) {
        return true;
      }
    }
    return false;
  }

  /// Check if the board is completely cleared (victory)
  bool isCleared() {
    return bubbles.isEmpty && dynamicBubbles.isEmpty;
  }

  @override
  List<Object?> get props => [
        bubbles,
        dynamicBubbles,
        gridOffsetY,
        foulCount,
        maxFouls,
      ];
}
