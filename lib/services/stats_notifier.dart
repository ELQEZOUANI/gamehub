import 'package:flutter/widgets.dart';
import 'stats_service.dart';
import '../models/game_stats.dart';

/// Reactive wrapper for StatsService that provides instant UI updates
/// Uses ChangeNotifier to automatically rebuild widgets when stats change
class StatsNotifier extends ChangeNotifier {
  final StatsService _statsService = StatsService();
  
  // Singleton instance
  static final StatsNotifier _instance = StatsNotifier._internal();
  factory StatsNotifier() => _instance;
  StatsNotifier._internal() {
    // Listen to StatsService changes
    _statsService.addListener(_onStatsChanged);
  }

  void _onStatsChanged() {
    // Propagate changes to UI
    notifyListeners();
  }

  /// Initialize the stats system
  Future<void> initialize() async {
    await _statsService.initialize();
    notifyListeners();
  }

  /// Record a game result with automatic UI updates
  Future<void> recordGameResult({
    required String gameID,
    required int score,
  }) async {
    await _statsService.recordGameResult(gameID: gameID, score: score);
    // StatsService will automatically notify listeners
  }

  /// Get statistics for a specific game
  GameStats? getStats({required String gameID}) {
    return _statsService.getStats(gameID: gameID);
  }

  /// Get all stored statistics
  List<GameStats> getAllStats() {
    return _statsService.getAllStats();
  }

  /// Get best score for a specific game
  int getBestScore({required String gameID}) {
    return _statsService.getBestScore(gameID: gameID);
  }

  /// Get games played count for a specific game
  int getGamesPlayed({required String gameID}) {
    return _statsService.getGamesPlayed(gameID: gameID);
  }

  /// Get average score for a specific game
  double getAverageScore({required String gameID}) {
    return _statsService.getAverageScore(gameID: gameID);
  }

  /// Get total games played across all games
  int get totalGamesPlayed => _statsService.totalGamesPlayed;

  /// Check if a game has any recorded statistics
  bool hasStats({required String gameID}) {
    return _statsService.hasStats(gameID: gameID);
  }

  /// Get top performing games
  List<GameStats> getTopGames({int limit = 5}) {
    return _statsService.getTopGames(limit: limit);
  }

  /// Get most played games
  List<GameStats> getMostPlayedGames({int limit = 5}) {
    return _statsService.getMostPlayedGames(limit: limit);
  }

  /// Get games with best average performance
  List<GameStats> getBestAverageGames({int limit = 5}) {
    return _statsService.getBestAverageGames(limit: limit);
  }

  /// Reset statistics for a specific game
  Future<void> resetGameStats({required String gameID}) async {
    await _statsService.resetGameStats(gameID: gameID);
  }

  /// Reset all statistics
  Future<void> resetAllStats() async {
    await _statsService.resetAllStats();
  }

  // Legacy compatibility methods
  Future<int> getBest2048(int gridSize) => _statsService.getBest2048(gridSize);
  Future<void> setBest2048(int gridSize, int score) => _statsService.setBest2048(gridSize, score);

  // User profile methods
  Future<String> getUserAvatarEmoji() => _statsService.getUserAvatarEmoji();
  Future<void> setUserAvatarEmoji(String emoji) => _statsService.setUserAvatarEmoji(emoji);
  Future<String> getUserName() => _statsService.getUserName();
  Future<void> setUserName(String name) => _statsService.setUserName(name);

  @override
  void dispose() {
    _statsService.removeListener(_onStatsChanged);
    super.dispose();
  }
}

/// Widget that automatically rebuilds when stats change
/// Usage: StatsBuilder(
///   builder: (context, stats) => YourWidget(stats: stats),
/// )
class StatsBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, StatsNotifier stats) builder;

  const StatsBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StatsNotifier(),
      builder: (context, child) {
        return builder(context, StatsNotifier());
      },
    );
  }
}

/// Widget that rebuilds when a specific game's stats change
/// More efficient than StatsBuilder for single-game widgets
class GameStatsBuilder extends StatelessWidget {
  final String gameID;
  final Widget Function(BuildContext context, GameStats? stats) builder;

  const GameStatsBuilder({
    super.key,
    required this.gameID,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StatsBuilder(
      builder: (context, statsNotifier) {
        final stats = statsNotifier.getStats(gameID: gameID);
        return builder(context, stats);
      },
    );
  }
}

/// Mixin for StatefulWidgets that need to listen to stats changes
/// Usage: class MyWidget extends StatefulWidget with StatsListenerMixin
mixin StatsListenerMixin<T extends StatefulWidget> on State<T> {
  late StatsNotifier _statsNotifier;

  @override
  void initState() {
    super.initState();
    _statsNotifier = StatsNotifier();
    _statsNotifier.addListener(_onStatsChanged);
  }

  @override
  void dispose() {
    _statsNotifier.removeListener(_onStatsChanged);
    super.dispose();
  }

  void _onStatsChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild
      });
    }
  }

  /// Access to the stats notifier
  StatsNotifier get statsNotifier => _statsNotifier;
}

/// Provider-style widget for dependency injection
class StatsProvider extends InheritedNotifier<StatsNotifier> {
  const StatsProvider({
    super.key,
    required super.child,
    required StatsNotifier super.notifier,
  });

  static StatsNotifier? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StatsProvider>()?.notifier;
  }

  static StatsNotifier of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<StatsProvider>()!.notifier!;
    } else {
      return (context.getElementForInheritedWidgetOfExactType<StatsProvider>()!.widget as StatsProvider).notifier!;
    }
  }
}
