import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class TrajectoryPoint extends Equatable {
  final double x;
  final double y;
  final bool isWallBounce;

  const TrajectoryPoint({
    required this.x,
    required this.y,
    this.isWallBounce = false,
  });

  @override
  List<Object?> get props => [x, y, isWallBounce];
}
