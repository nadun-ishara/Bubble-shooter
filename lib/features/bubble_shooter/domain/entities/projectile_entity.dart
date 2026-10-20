import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'bubble_type.dart';

@immutable
class ProjectileEntity extends Equatable {
  final BubbleType type;
  final double x;
  final double y;
  final double vx;
  final double vy;

  const ProjectileEntity({
    required this.type,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  });

  ProjectileEntity copyWith({
    BubbleType? type,
    double? x,
    double? y,
    double? vx,
    double? vy,
  }) {
    return ProjectileEntity(
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
    );
  }

  @override
  List<Object?> get props => [type, x, y, vx, vy];
}
