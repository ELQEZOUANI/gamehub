import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_stats.dart';

/// Centralized singleton service for managing all game statistics
/// Provides instant updates across the app with disk persistence
class StatsService extends ChangeNotifier {
  // Singleton instance
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  // Private storage
  Map<String, GameStats> _stats = {};
  bool _isInitialized = false;
  
  // File path for persistent storage
  static const String _statsFileName = 'game_statistics.json';
  
  // Game ID constants for consistency
  static const String game2048 = 'game_2048';
  static const String gameTicTacToe = 'tic_tac_toe';
  static const String gameRockPaperScissors = 'rock_paper_scissors';
  static const String gameMemoryMatch = 'memory_match';
  static const String gameQuickReaction = 'quick_reaction';
  static const String gameSketchIt = 'sketch_it';
  static const String gameSimonSays = 'simon_says';

  static const String gameWordGuess = 'word_guess';

  /// Initialize the service - must be called before using
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadStatsFromDisk();
    _isInitialized = true;
    debugPrint('📊 StatsService initialized with ${_stats.length} games');
  }

  /// Private function to load statistics from disk
  Future<void> _loadStatsFromDisk() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_statsFileName');
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        _stats = GameStatsCollection.decodeStatsMap(jsonString);
        debugPrint('📂 Loaded ${_stats.length} game statistics from disk');
      } else {
        _stats = {};
        debugPrint('📂 No existing statistics file found, starting fresh');
      }
    } catch (e) {
      debugPrint('❌ Error loading stats from disk: $e');
      _stats = {};
    }
  }

  /// Private function to save statistics to disk
  Future<void> _saveStatsToDisk() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_statsFileName');
      
      final jsonString = GameStatsCollection.encodeStatsMap(_stats);
      await file.writeAsString(jsonString);
      
      debugPrint('💾 Saved ${_stats.length} game statistics to disk');
    } catch (e) {
      debugPrint('❌ Error saving stats to disk: $e');
    }
  }

  /// Main function to record a game result
  /// This is the core function that updates all statistics
  Future<void> recordGameResult({
    required String gameID,
    required int score,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Get existing stats or create new ones
    GameStats gameStats = _stats[gameID] ?? GameStats(gameID: gameID);
    
    // Update the statistics
    gameStats.recordGameResult(score);
    
    // Store back in the map
    _stats[gameID] = gameStats;
    
    // Persist to disk
    await _saveStatsToDisk();
    
    // Notify listeners for instant UI updates
    notifyListeners();
    
    debugPrint('🎯 Recorded result for $gameID: score=$score, games=${gameStats.gamesPlayed}, best=${gameStats.bestScore}');
  }

  /// Get statistics for a specific game
  GameStats? getStats({required String gameID}) {
    return _stats[gameID];
  }

  /// Get all stored statistics
  List<GameStats> getAllStats() {
    return _stats.values.toList();
  }

  /// Get statistics as a map (gameID -> GameStats)
  Map<String, GameStats> getStatsMap() {
    return Map.from(_stats);
  }

  /// Check if a game has any recorded statistics
  bool hasStats({required String gameID}) {
    return _stats.containsKey(gameID) && _stats[gameID]!.hasBeenPlayed;
  }

  /// Get total games played across all games
  int get totalGamesPlayed {
    return _stats.values.fold(0, (sum, stats) => sum + stats.gamesPlayed);
  }

  /// Get best score for a specific game
  int getBestScore({required String gameID}) {
    return _stats[gameID]?.bestScore ?? 0;
  }

  /// Get games played count for a specific game
  int getGamesPlayed({required String gameID}) {
    return _stats[gameID]?.gamesPlayed ?? 0;
  }

  /// Get average score for a specific game
  double getAverageScore({required String gameID}) {
    return _stats[gameID]?.averageScore ?? 0.0;
  }

  /// Reset statistics for a specific game
  Future<void> resetGameStats({required String gameID}) async {
    if (_stats.containsKey(gameID)) {
      _stats[gameID]!.reset();
      await _saveStatsToDisk();
      notifyListeners();
      debugPrint('🔄 Reset statistics for $gameID');
    }
  }

  /// Reset all statistics
  Future<void> resetAllStats() async {
    _stats.clear();
    await _saveStatsToDisk();
    notifyListeners();
    debugPrint('🔄 Reset all game statistics');
  }

  /// Get top performing games (by best score)
  List<GameStats> getTopGames({int limit = 5}) {
    final allStats = getAllStats();
    allStats.sort((a, b) => b.bestScore.compareTo(a.bestScore));
    return allStats.take(limit).toList();
  }

  /// Get most played games
  List<GameStats> getMostPlayedGames({int limit = 5}) {
    final allStats = getAllStats();
    allStats.sort((a, b) => b.gamesPlayed.compareTo(a.gamesPlayed));
    return allStats.take(limit).toList();
  }

  /// Get games with best average performance
  List<GameStats> getBestAverageGames({int limit = 5}) {
    final allStats = getAllStats().where((stats) => stats.hasBeenPlayed).toList();
    allStats.sort((a, b) => b.averageScore.compareTo(a.averageScore));
    return allStats.take(limit).toList();
  }

  // MARK: - Legacy Compatibility Methods
  // These methods maintain compatibility with existing code

  /// Legacy: Get 2048 best score
  Future<int> getBest2048(int gridSize) async {
    if (!_isInitialized) await initialize();
    return getBestScore(gameID: '${game2048}_${gridSize}x$gridSize');
  }

  /// Legacy: Set 2048 best score
  Future<void> setBest2048(int gridSize, int score) async {
    await recordGameResult(
      gameID: '${game2048}_${gridSize}x$gridSize',
      score: score,
    );
  }

  /// Legacy: Get Tic-Tac-Toe stats
  Future<Map<String, int>> getTttStats() async {
    if (!_isInitialized) await initialize();
    final stats = getStats(gameID: gameTicTacToe);
    return {
      'wins': stats?.bestScore ?? 0,
      'games': stats?.gamesPlayed ?? 0,
      'winRate': stats?.hasBeenPlayed == true 
          ? ((stats!.bestScore / stats.gamesPlayed) * 100).round()
          : 0,
    };
  }

  /// Legacy: Record Tic-Tac-Toe result
  Future<void> recordTttResult({required bool isWin}) async {
    await recordGameResult(
      gameID: gameTicTacToe,
      score: isWin ? 1 : 0,
    );
  }

  /// Legacy: Get Memory Match stats
  Future<Map<String, int>> getMemoryStats() async {
    if (!_isInitialized) await initialize();
    final stats = getStats(gameID: gameMemoryMatch);
    return {
      'bestScore': stats?.bestScore ?? 0,
      'gamesPlayed': stats?.gamesPlayed ?? 0,
      'averageScore': stats?.averageScore.round() ?? 0,
    };
  }

  /// Legacy: Set Memory Match best score
  Future<void> setMemoryBest(int score) async {
    await recordGameResult(gameID: gameMemoryMatch, score: score);
  }

  /// Legacy: Increment Memory Match games
  Future<void> incMemoryGames() async {
    // This will be handled automatically by recordGameResult
    // Keeping for compatibility but games should use recordGameResult directly
  }

  /// Legacy: Get Quick Reaction stats
  Future<Map<String, int>> getQuickReactionStats() async {
    if (!_isInitialized) await initialize();
    final stats = getStats(gameID: gameQuickReaction);
    return {
      'bestScore': stats?.bestScore ?? 0,
      'gamesPlayed': stats?.gamesPlayed ?? 0,
      'averageScore': stats?.averageScore.round() ?? 0,
    };
  }

  /// Legacy: Set Quick Reaction best score
  Future<void> setQuickReactionBest(int score) async {
    await recordGameResult(gameID: gameQuickReaction, score: score);
  }

  /// Legacy: Get Word Guess stats
  Future<Map<String, int>> getWordGuessStats() async {
    if (!_isInitialized) await initialize();
    final stats = getStats(gameID: gameWordGuess);
    return {
      'bestScore': stats?.bestScore ?? 0,
      'gamesPlayed': stats?.gamesPlayed ?? 0,
      'averageScore': stats?.averageScore.round() ?? 0,
    };
  }

  /// Legacy: Set Word Guess best score
  Future<void> setWordGuessBest(int score) async {
    await recordGameResult(gameID: gameWordGuess, score: score);
  }

  /// Legacy: Increment Word Guess games
  Future<void> incWordGuessGames() async {
    // This will be handled automatically by recordGameResult
  }

  // MARK: - User Profile Integration

  /// Get user avatar emoji (moved from old implementation)
  static const String _userAvatarEmoji = 'user_avatar_emoji';
  
  Future<String> getUserAvatarEmoji() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userAvatarEmoji) ?? '😊';
  }

  Future<void> setUserAvatarEmoji(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userAvatarEmoji, emoji);
    notifyListeners(); // Notify for profile updates
  }

  /// Get user name
  static const String _userNameKey = 'user_name';

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Player';
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    notifyListeners();
  }

  // MARK: - Debug and Maintenance

  /// Get detailed information about stored statistics
  Map<String, dynamic> getDebugInfo() {
    return {
      'totalGames': _stats.length,
      'totalGamesPlayed': totalGamesPlayed,
      'isInitialized': _isInitialized,
      'statsBreakdown': _stats.map((key, value) => MapEntry(key, {
        'gamesPlayed': value.gamesPlayed,
        'bestScore': value.bestScore,
        'averageScore': value.averageScore,
      })),
    };
  }

  /// Print debug information
  void printDebugInfo() {
    final info = getDebugInfo();
    debugPrint('📊 === STATS SERVICE DEBUG INFO ===');
    debugPrint('📱 Total Games: ${info['totalGames']}');
    debugPrint('🎮 Total Games Played: ${info['totalGamesPlayed']}');
    debugPrint('✅ Initialized: ${info['isInitialized']}');
    debugPrint('📋 Game Breakdown:');
    
    final breakdown = info['statsBreakdown'] as Map<String, dynamic>;
    breakdown.forEach((gameID, stats) {
      debugPrint('  🎯 $gameID: ${stats['gamesPlayed']} games, best: ${stats['bestScore']}, avg: ${(stats['averageScore'] as double).toStringAsFixed(2)}');
    });
    debugPrint('================================');
  }
}
