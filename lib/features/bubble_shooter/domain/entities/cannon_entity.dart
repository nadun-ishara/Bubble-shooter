import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'bubble_type.dart';

@immutable
class CannonEntity extends Equatable {
  final double aimAngle; // Radians, -pi/2 is straight up
  final bool isAiming;
  final BubbleType loadedBubble;
  final BubbleType nextBubble;
  final double recoilOffset;
  final double muzzleFlashAlpha;
  final double gearRotation;

  const CannonEntity({
    this.aimAngle = -pi / 2,
    this.isAiming = false,
    required this.loadedBubble,
    required this.nextBubble,
    this.recoilOffset = 0.0,
    this.muzzleFlashAlpha = 0.0,
    this.gearRotation = 0.0,
  });

  CannonEntity copyWith({
    double? aimAngle,
    bool? isAiming,
    BubbleType? loadedBubble,
    BubbleType? nextBubble,
    double? recoilOffset,
    double? muzzleFlashAlpha,
    double? gearRotation,
  }) {
    return CannonEntity(
      aimAngle: aimAngle ?? this.aimAngle,
      isAiming: isAiming ?? this.isAiming,
      loadedBubble: loadedBubble ?? this.loadedBubble,
      nextBubble: nextBubble ?? this.nextBubble,
      recoilOffset: recoilOffset ?? this.recoilOffset,
      muzzleFlashAlpha: muzzleFlashAlpha ?? this.muzzleFlashAlpha,
      gearRotation: gearRotation ?? this.gearRotation,
    );
  }

  @override
  List<Object?> get props => [
        aimAngle,
        isAiming,
        loadedBubble,
        nextBubble,
        recoilOffset,
        muzzleFlashAlpha,
        gearRotation,
      ];
}
