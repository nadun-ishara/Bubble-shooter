import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class GameStats extends Equatable {
  final int score;
  final int highScore;
  final int level;
  final int popsCount;
  final int orphansCount;
  final int comboStreak;

  const GameStats({
    this.score = 0,
    this.highScore = 0,
    this.level = 1,
    this.popsCount = 0,
    this.orphansCount = 0,
    this.comboStreak = 0,
  });

  GameStats copyWith({
    int? score,
    int? highScore,
    int? level,
    int? popsCount,
    int? orphansCount,
    int? comboStreak,
  }) {
    return GameStats(
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      level: level ?? this.level,
      popsCount: popsCount ?? this.popsCount,
      orphansCount: orphansCount ?? this.orphansCount,
      comboStreak: comboStreak ?? this.comboStreak,
    );
  }

  @override
  List<Object?> get props => [
        score,
        highScore,
        level,
        popsCount,
        orphansCount,
        comboStreak,
      ];
}
