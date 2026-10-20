import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'bubble_type.dart';
import 'grid_position.dart';

enum BubbleLifeCycle {
  idle,
  popping,
  falling,
}

@immutable
class BubbleEntity extends Equatable {
  final String id;
  final BubbleType type;
  final GridPosition? gridPosition;
  final double x;
  final double y;
  final BubbleLifeCycle lifeCycle;
  final double scale;
  final double alpha;
  final double velocityX;
  final double velocityY;

  const BubbleEntity({
    required this.id,
    required this.type,
    this.gridPosition,
    required this.x,
    required this.y,
    this.lifeCycle = BubbleLifeCycle.idle,
    this.scale = 1.0,
    this.alpha = 1.0,
    this.velocityX = 0.0,
    this.velocityY = 0.0,
  });

  BubbleEntity copyWith({
    String? id,
    BubbleType? type,
    GridPosition? gridPosition,
    double? x,
    double? y,
    BubbleLifeCycle? lifeCycle,
    double? scale,
    double? alpha,
    double? velocityX,
    double? velocityY,
  }) {
    return BubbleEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      gridPosition: gridPosition ?? this.gridPosition,
      x: x ?? this.x,
      y: y ?? this.y,
      lifeCycle: lifeCycle ?? this.lifeCycle,
      scale: scale ?? this.scale,
      alpha: alpha ?? this.alpha,
      velocityX: velocityX ?? this.velocityX,
      velocityY: velocityY ?? this.velocityY,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        gridPosition,
        x,
        y,
        lifeCycle,
        scale,
        alpha,
        velocityX,
        velocityY,
      ];
}
