import 'package:equatable/equatable.dart';

class ScoreModel extends Equatable {
  final int score;
  final DateTime recordedAt;

  const ScoreModel({
    required this.score,
    required this.recordedAt,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      score: (json['score'] as num?)?.toInt() ?? 0,
      recordedAt: json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [score, recordedAt];
}
