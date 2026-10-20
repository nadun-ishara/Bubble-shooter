import 'dart:convert';
import 'dart:io';

abstract class GameLocalDataSource {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  static const String _fileName = 'bubble_shooter_save.json';
  int _memoryHighScore = 0;

  File _getFile() {
    return File(_fileName);
  }

  @override
  Future<int> getHighScore() async {
    try {
      final file = _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final map = jsonDecode(content) as Map<String, dynamic>;
        _memoryHighScore = (map['high_score'] as num?)?.toInt() ?? _memoryHighScore;
      }
    } catch (_) {
      // In web or restricted sandbox, retain memory cache
    }
    return _memoryHighScore;
  }

  @override
  Future<void> saveHighScore(int score) async {
    if (score <= _memoryHighScore) return;
    _memoryHighScore = score;
    try {
      final file = _getFile();
      final map = {'high_score': _memoryHighScore};
      await file.writeAsString(jsonEncode(map));
    } catch (_) {
      // In web or restricted sandbox, retain memory cache
    }
  }
}
