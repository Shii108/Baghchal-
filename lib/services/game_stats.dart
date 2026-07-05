import 'package:shared_preferences/shared_preferences.dart';

class GameStats {
  static const String keyTotalGames = 'total_games';
  static const String keyTigerWins = 'tiger_wins';
  static const String keyGoatWins = 'goat_wins';
  static const String keyTotalCaptures = 'total_captures';

  static Future<void> saveStats({
    required int totalGames,
    required int tigerWins,
    required int goatWins,
    required int totalCaptures,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyTotalGames, totalGames);
    await prefs.setInt(keyTigerWins, tigerWins);
    await prefs.setInt(keyGoatWins, goatWins);
    await prefs.setInt(keyTotalCaptures, totalCaptures);
  }

  static Future<Map<String, int>> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'totalGames': prefs.getInt(keyTotalGames) ?? 0,
      'tigerWins': prefs.getInt(keyTigerWins) ?? 0,
      'goatWins': prefs.getInt(keyGoatWins) ?? 0,
      'totalCaptures': prefs.getInt(keyTotalCaptures) ?? 0,
    };
  }

  static Future<void> incrementTotalGames() async {
    final stats = await loadStats();
    await saveStats(
      totalGames: stats['totalGames']! + 1,
      tigerWins: stats['tigerWins']!,
      goatWins: stats['goatWins']!,
      totalCaptures: stats['totalCaptures']!,
    );
  }

  static Future<void> incrementTigerWins() async {
    final stats = await loadStats();
    await saveStats(
      totalGames: stats['totalGames']!,
      tigerWins: stats['tigerWins']! + 1,
      goatWins: stats['goatWins']!,
      totalCaptures: stats['totalCaptures']!,
    );
  }

  static Future<void> incrementGoatWins() async {
    final stats = await loadStats();
    await saveStats(
      totalGames: stats['totalGames']!,
      tigerWins: stats['tigerWins']!,
      goatWins: stats['goatWins']! + 1,
      totalCaptures: stats['totalCaptures']!,
    );
  }

  static Future<void> addCaptures(int count) async {
    final stats = await loadStats();
    await saveStats(
      totalGames: stats['totalGames']!,
      tigerWins: stats['tigerWins']!,
      goatWins: stats['goatWins']!,
      totalCaptures: stats['totalCaptures']! + count,
    );
  }
}
