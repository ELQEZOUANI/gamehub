// lib/services/stats_service.dart

import 'package:shared_preferences/shared_preferences.dart';

/// Centralized persistent stats helper.
/// Keeps the code clean in UI layers and makes it easy to extend.
class StatsService {
  // 2048
  static String _bestKey(int gridSize) => 'bestScore${gridSize}x$gridSize';

  static Future<int> getBest2048(int gridSize) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestKey(gridSize)) ?? 0;
    }

  static Future<void> setBest2048(int gridSize, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_bestKey(gridSize)) ?? 0;
    if (score > current) {
      await prefs.setInt(_bestKey(gridSize), score);
    }
  }

  // TicTacToe
  static const String _tttWinsX = 'ttt_wins_x';
  static const String _tttWinsO = 'ttt_wins_o';
  static const String _tttDraws = 'ttt_draws';

  static Future<Map<String, int>> getTttStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'x': prefs.getInt(_tttWinsX) ?? 0,
      'o': prefs.getInt(_tttWinsO) ?? 0,
      'draw': prefs.getInt(_tttDraws) ?? 0,
    };
  }

  static Future<void> incTttWinX() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_tttWinsX) ?? 0;
    await prefs.setInt(_tttWinsX, v + 1);
  }

  static Future<void> incTttWinO() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_tttWinsO) ?? 0;
    await prefs.setInt(_tttWinsO, v + 1);
  }

  static Future<void> incTttDraw() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_tttDraws) ?? 0;
    await prefs.setInt(_tttDraws, v + 1);
  }

  // Rock-Paper-Scissors
  static const String _rpsWins = 'rps_wins';
  static const String _rpsLosses = 'rps_losses';
  static const String _rpsDraws = 'rps_draws';

  static Future<Map<String, int>> getRpsStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'win': prefs.getInt(_rpsWins) ?? 0,
      'loss': prefs.getInt(_rpsLosses) ?? 0,
      'draw': prefs.getInt(_rpsDraws) ?? 0,
    };
  }

  static Future<void> incRpsWin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_rpsWins, (prefs.getInt(_rpsWins) ?? 0) + 1);
  }

  static Future<void> incRpsLoss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_rpsLosses, (prefs.getInt(_rpsLosses) ?? 0) + 1);
  }

  static Future<void> incRpsDraw() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_rpsDraws, (prefs.getInt(_rpsDraws) ?? 0) + 1);
  }

  // Quick Reaction
  static const String _qrBestScore = 'qr_best_score';
  static const String _qrGamesPlayed = 'qr_games_played';

  static Future<Map<String, int>> getQuickReactionStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'bestScore': prefs.getInt(_qrBestScore) ?? 0,
      'gamesPlayed': prefs.getInt(_qrGamesPlayed) ?? 0,
    };
  }

  static Future<void> setQuickReactionBest(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_qrBestScore) ?? 0;
    if (score > current) {
      await prefs.setInt(_qrBestScore, score);
    }
  }

  static Future<void> incQuickReactionGames() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_qrGamesPlayed) ?? 0;
    await prefs.setInt(_qrGamesPlayed, current + 1);
  }

  // Memory Match
  static const String _memoryBestScore = 'memory_best_score';
  static const String _memoryGamesPlayed = 'memory_games_played';

  static Future<Map<String, int>> getMemoryStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'bestScore': prefs.getInt(_memoryBestScore) ?? 0,
      'gamesPlayed': prefs.getInt(_memoryGamesPlayed) ?? 0,
    };
  }

  static Future<void> setMemoryBest(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_memoryBestScore) ?? 0;
    if (score > current) {
      await prefs.setInt(_memoryBestScore, score);
    }
  }

  static Future<void> incMemoryGames() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_memoryGamesPlayed) ?? 0;
    await prefs.setInt(_memoryGamesPlayed, current + 1);
  }

  // Simon Says
  static const String _simonBestLevel = 'simon_best_level';
  static const String _simonGamesPlayed = 'simon_games_played';

  static Future<Map<String, int>> getSimonStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'bestLevel': prefs.getInt(_simonBestLevel) ?? 0,
      'gamesPlayed': prefs.getInt(_simonGamesPlayed) ?? 0,
    };
  }

  static Future<void> setSimonBest(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_simonBestLevel) ?? 0;
    if (level > current) {
      await prefs.setInt(_simonBestLevel, level);
    }
  }

  static Future<void> incSimonGames() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_simonGamesPlayed) ?? 0;
    await prefs.setInt(_simonGamesPlayed, current + 1);
  }

  // Tower Builder
  static const String _towerBestHeight = 'tower_best_height';
  static const String _towerGamesPlayed = 'tower_games_played';

  static Future<Map<String, int>> getTowerStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'bestHeight': prefs.getInt(_towerBestHeight) ?? 0,
      'gamesPlayed': prefs.getInt(_towerGamesPlayed) ?? 0,
    };
  }

  static Future<void> setTowerBest(int height) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_towerBestHeight) ?? 0;
    if (height > current) {
      await prefs.setInt(_towerBestHeight, height);
    }
  }

  static Future<void> incTowerGames() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_towerGamesPlayed) ?? 0;
    await prefs.setInt(_towerGamesPlayed, current + 1);
  }

  // Word Guess
  static const String _wordGuessBestScore = 'word_guess_best_score';
  static const String _wordGuessGamesPlayed = 'word_guess_games_played';

  static Future<Map<String, int>> getWordGuessStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'bestScore': prefs.getInt(_wordGuessBestScore) ?? 0,
      'gamesPlayed': prefs.getInt(_wordGuessGamesPlayed) ?? 0,
    };
  }

  static Future<void> setWordGuessBest(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_wordGuessBestScore) ?? 0;
    if (score > current) {
      await prefs.setInt(_wordGuessBestScore, score);
    }
  }

  static Future<void> incWordGuessGames() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_wordGuessGamesPlayed) ?? 0;
    await prefs.setInt(_wordGuessGamesPlayed, current + 1);
  }

  // Sketch It! (just track games played for now)
  static const String _sketchGamesPlayed = 'sketch_games_played';

  static Future<int> getSketchGames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sketchGamesPlayed) ?? 0;
  }

  static Future<void> incSketchGames() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_sketchGamesPlayed) ?? 0;
    await prefs.setInt(_sketchGamesPlayed, current + 1);
  }

  // User name
  static const String _userName = 'user_name';
  static const String _userAvatarEmoji = 'user_avatar_emoji';

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userName) ?? 'Player';
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userName, name);
  }

  // User avatar (emoji)
  static Future<String> getUserAvatarEmoji() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userAvatarEmoji) ?? '🙂';
  }

  static Future<void> setUserAvatarEmoji(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userAvatarEmoji, emoji);
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tttWinsX);
    await prefs.remove(_tttWinsO);
    await prefs.remove(_tttDraws);
    await prefs.remove(_rpsWins);
    await prefs.remove(_rpsLosses);
    await prefs.remove(_rpsDraws);
    await prefs.remove(_qrBestScore);
    await prefs.remove(_qrGamesPlayed);
    await prefs.remove(_memoryBestScore);
    await prefs.remove(_memoryGamesPlayed);
    await prefs.remove(_simonBestLevel);
    await prefs.remove(_simonGamesPlayed);
    await prefs.remove(_towerBestHeight);
    await prefs.remove(_towerGamesPlayed);
    await prefs.remove(_wordGuessBestScore);
    await prefs.remove(_wordGuessGamesPlayed);
    await prefs.remove(_sketchGamesPlayed);
    await prefs.remove(_userName);
    await prefs.remove(_userAvatarEmoji);
    // Keep 2048 bests; they're per grid size and managed elsewhere.
  }
}


