import 'dart:async';
import 'dart:math';

import 'package:baghchal_app/baghchal_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const BaghchalApp());

// ─── Sound Manager ─────────────────────────────────────────
class SoundManager {
  static bool _muted = false;
  static void toggleMute() => _muted = !_muted;
  static bool isMuted() => _muted;

  static void playTap() {
    if (_muted) return;
    unawaited(SystemSound.play(SystemSoundType.click));
  }

  static void playCapture() {
    if (_muted) return;
    unawaited(SystemSound.play(SystemSoundType.alert));
  }
}

// ─── Statistics Manager ──────────────────────────────────
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

// ─── AI Difficulty ─────────────────────────────────────────
enum AIDifficulty { easy, medium, hard }

// ─── Theme definitions ────────────────────────────────────
enum AppTheme { green, blue, brown, purple, dark, wood, stone, gold }

class ThemeColors {
  final Color boardBg;
  final Color lineColor;
  final Color dotColor;
  final Color boardShadow;
  final Color tigerColor;
  final Color goatColor;
  final Color goatBorder;
  final Color tigerBorder;
  final Color selectedGlow;

  const ThemeColors({
    required this.boardBg,
    required this.lineColor,
    required this.dotColor,
    required this.boardShadow,
    required this.tigerColor,
    required this.goatColor,
    required this.goatBorder,
    required this.tigerBorder,
    required this.selectedGlow,
  });

  static const Map<AppTheme, ThemeColors> _map = {
    AppTheme.green: ThemeColors(
      boardBg: Color(0xFF2d5a27),
      lineColor: Color(0xFFdcc29e),
      dotColor: Color(0xFFdcc29e),
      boardShadow: Color(0xFF8a7a5a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.blue: ThemeColors(
      boardBg: Color(0xFF1a4a6b),
      lineColor: Color(0xFFb0d4f1),
      dotColor: Color(0xFFb0d4f1),
      boardShadow: Color(0xFF2a5a7a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.brown: ThemeColors(
      boardBg: Color(0xFF6b4c3b),
      lineColor: Color(0xFFe8d5b5),
      dotColor: Color(0xFFe8d5b5),
      boardShadow: Color(0xFF5a3b2a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.purple: ThemeColors(
      boardBg: Color(0xFF3a2a5a),
      lineColor: Color(0xFFc9b8e8),
      dotColor: Color(0xFFc9b8e8),
      boardShadow: Color(0xFF2a1a4a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.dark: ThemeColors(
      boardBg: Color(0xFF1a1a1a),
      lineColor: Color(0xFF888888),
      dotColor: Color(0xFF888888),
      boardShadow: Color(0xFF0a0a0a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFCCCCCC),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.wood: ThemeColors(
      boardBg: Color(0xFFb58a5a),
      lineColor: Color(0xFF5a3a1a),
      dotColor: Color(0xFF5a3a1a),
      boardShadow: Color(0xFF7a5a2a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.stone: ThemeColors(
      boardBg: Color(0xFF4a4a4a),
      lineColor: Color(0xFFaaaaaa),
      dotColor: Color(0xFFaaaaaa),
      boardShadow: Color(0xFF1a1a1a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFCCCCCC),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.gold: ThemeColors(
      boardBg: Color(0xFFc9a84c),
      lineColor: Color(0xFF8a6a2a),
      dotColor: Color(0xFF8a6a2a),
      boardShadow: Color(0xFF8a6a2a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
  };

  static ThemeColors of(AppTheme theme) => _map[theme]!;
}

// ─── Main App ─────────────────────────────────────────────
class BaghchalApp extends StatefulWidget {
  const BaghchalApp({super.key});

  @override
  State<BaghchalApp> createState() => _BaghchalAppState();
}

class _BaghchalAppState extends State<BaghchalApp> {
  AppTheme _currentTheme = AppTheme.green;
  AIDifficulty _difficulty = AIDifficulty.medium;

  void _changeTheme() {
    final values = AppTheme.values;
    final currentIndex = values.indexOf(_currentTheme);
    final nextIndex = (currentIndex + 1) % values.length;
    setState(() => _currentTheme = values[nextIndex]);
  }

  void _changeDifficulty() {
    final values = AIDifficulty.values;
    final currentIndex = values.indexOf(_difficulty);
    final nextIndex = (currentIndex + 1) % values.length;
    setState(() => _difficulty = values[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baghchal',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f1f13),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a2e1f),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFf7f0dc),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
      home: BaghchalScreen(
        key: ValueKey(_currentTheme),
        theme: _currentTheme,
        onThemeChange: _changeTheme,
        difficulty: _difficulty,
        onDifficultyChange: _changeDifficulty,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─── Main Game Screen ─────────────────────────────────────
class BaghchalScreen extends StatefulWidget {
  final AppTheme theme;
  final VoidCallback onThemeChange;
  final AIDifficulty difficulty;
  final VoidCallback onDifficultyChange;

  const BaghchalScreen({
    super.key,
    required this.theme,
    required this.onThemeChange,
    required this.difficulty,
    required this.onDifficultyChange,
  });

  @override
  State<BaghchalScreen> createState() => _BaghchalScreenState();
}

class _BaghchalScreenState extends State<BaghchalScreen> {
  // ─── Constants ──────────────────────────────────────────
  static const int boardSize = BaghchalRules.boardSize;
  static const int maxGoats = BaghchalRules.maxGoats;

  // ─── Game state ──────────────────────────────────────────
  List<int> board = List.filled(boardSize, 0);
  String turn = 'goat';
  String phase = 'placement';
  int goatsPlaced = 0;
  int goatsCaptured = 0;
  int? selectedTiger;
  int? selectedGoat;
  bool selectedGoatFromReserve = false;
  List<int> tigerIndices = [];
  List<int> goatIndices = [];
  bool aiEnabled = false;
  bool aiThinking = false;
  bool showHints = false;
  String infoMessage = 'Place goats · Tap reserve, then board';

  // ─── Last move tracking ──────────────────────────────────
  int? lastMoveFrom;
  int? lastMoveTo;

  // ─── Repetition tracking ─────────────────────────────────
  final Set<String> positionHistory = <String>{};

  // ─── Adjacency ──────────────────────────────────────────
  final List<List<int>> adjacency = BaghchalRules.buildAdjacency();

  String _positionKey(List<int> state, String nextTurn, String nextPhase) {
    return '$nextPhase|$nextTurn|${state.join(',')}';
  }

  bool _wouldRepeatPosition({
    required List<int> state,
    required int piece,
    required int from,
    required int to,
    required String nextTurn,
    int? capture,
  }) {
    if (phase != 'movement') return false;

    final nextBoard = List<int>.from(state);
    nextBoard[from] = BaghchalRules.empty;
    nextBoard[to] = piece;
    if (capture != null) {
      nextBoard[capture] = BaghchalRules.empty;
    }

    return positionHistory.contains(
      _positionKey(nextBoard, nextTurn, 'movement'),
    );
  }

  void _recordCurrentPosition() {
    if (phase != 'movement') return;
    if (turn != 'goat' && turn != 'tiger') return;

    positionHistory.add(_positionKey(board, turn, phase));
  }

  bool _matchesMove(Map<String, dynamic> move, int to, int? capture) {
    return move['to'] == to && move['capture'] == capture;
  }

  // ─── Tiger moves ────────────────────────────────────────
  List<Map<String, dynamic>> getTigerMoves(int idx) {
    return _getTigerMovesForBoard(idx, board);
  }

  List<Map<String, dynamic>> _getTigerMovesForBoard(
    int idx,
    List<int> state, {
    bool enforceRepetition = true,
  }) {
    final moves = BaghchalRules.tigerMoves(
      board: state,
      adjacency: adjacency,
      from: idx,
    );

    if (!enforceRepetition || phase != 'movement') return moves;

    return moves.where((move) {
      return !_wouldRepeatPosition(
        state: state,
        piece: BaghchalRules.tiger,
        from: idx,
        to: move['to'] as int,
        capture: move['capture'] as int?,
        nextTurn: 'goat',
      );
    }).toList();
  }

  // ─── Goat moves ─────────────────────────────────────────
  List<Map<String, dynamic>> getGoatMoves(int idx) {
    if (phase != 'movement') return const [];

    final moves = BaghchalRules.goatMoves(
      board: board,
      adjacency: adjacency,
      from: idx,
    );

    return moves.where((move) {
      return !_wouldRepeatPosition(
        state: board,
        piece: BaghchalRules.goat,
        from: idx,
        to: move['to'] as int,
        nextTurn: 'tiger',
      );
    }).toList();
  }

  bool anyTigerHasMoves() {
    for (final ti in tigerIndices) {
      if (getTigerMoves(ti).isNotEmpty) return true;
    }
    return false;
  }

  // ─── AI ──────────────────────────────────────────────────
  List<Map<String, dynamic>> _selectAIMoves() {
    List<Map<String, dynamic>> allMoves = [];
    for (final ti in tigerIndices) {
      final moves = getTigerMoves(ti);
      for (final m in moves) {
        allMoves.add({'from': ti, 'to': m['to'], 'capture': m['capture']});
      }
    }
    return allMoves;
  }

  Map<String, dynamic>? _chooseAIMove(List<Map<String, dynamic>> moves) {
    if (moves.isEmpty) return null;

    if (widget.difficulty == AIDifficulty.easy) {
      return moves[Random().nextInt(moves.length)];
    }

    if (widget.difficulty == AIDifficulty.medium) {
      final captures = moves.where((m) => m['capture'] != null).toList();
      if (captures.isNotEmpty) {
        return captures[Random().nextInt(captures.length)];
      }
      return moves[Random().nextInt(moves.length)];
    }

    // Hard
    Map<String, dynamic> bestMove = moves[0];
    int bestScore = -9999;
    for (final move in moves) {
      int score = 0;
      if (move['capture'] != null) score += 10;

      List<int> simBoard = List.from(board);
      simBoard[move['to']] = 1;
      simBoard[move['from']] = 0;
      if (move['capture'] != null) simBoard[move['capture']] = 0;

      final futureMoves = getTigerMovesSim(move['to'], simBoard);
      score += futureMoves.length * 2;

      final int toIndex = move['to'] as int;
      final distFromCenter = (toIndex ~/ 5 - 2).abs() + (toIndex % 5 - 2).abs();
      score -= distFromCenter * 3;

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  List<Map<String, dynamic>> getTigerMovesSim(int idx, List<int> simBoard) {
    return _getTigerMovesForBoard(
      idx,
      simBoard,
      enforceRepetition: false,
    );
  }

  // ─── Execute moves ──────────────────────────────────────
  void executeTigerMove(int from, int to, int? capture) {
    final legalMoves = getTigerMoves(from);
    final isLegalMove = legalMoves.any(
      (move) => _matchesMove(move, to, capture),
    );

    if (board[from] != BaghchalRules.tiger ||
        board[to] != BaghchalRules.empty ||
        !isLegalMove) {
      final rawMoves = _getTigerMovesForBoard(
        from,
        board,
        enforceRepetition: false,
      );
      final isRepeatOnly = rawMoves.any(
        (move) => _matchesMove(move, to, capture),
      );

      infoMessage = isRepeatOnly
          ? 'That move repeats a previous board position'
          : 'Invalid tiger move';
      setState(() {});
      return;
    }

    setState(() {
      board[to] = 1;
      board[from] = 0;
      final idx = tigerIndices.indexOf(from);
      if (idx != -1) tigerIndices[idx] = to;
      lastMoveFrom = from;
      lastMoveTo = to;

      if (capture != null) {
        board[capture] = 0;
        goatsCaptured++;
        final gi = goatIndices.indexOf(capture);
        if (gi != -1) {
          goatIndices.removeAt(gi);
        }
        GameStats.addCaptures(1);
      }

      selectedTiger = null;
      selectedGoat = null;
      selectedGoatFromReserve = false;
      showHints = false;

      if (goatsCaptured >= 5) {
        turn = 'gameover_tiger';
        infoMessage = '🏆 Tiger wins! 5 goats eaten';
        GameStats.incrementTigerWins();
        GameStats.incrementTotalGames();
      } else if (phase == 'movement' && !anyTigerHasMoves()) {
        turn = 'gameover_goat';
        infoMessage = '🏆 Goat wins! All tigers trapped';
        GameStats.incrementGoatWins();
        GameStats.incrementTotalGames();
      } else if (phase == 'placement' && goatsPlaced == maxGoats) {
        phase = 'movement';
        if (!anyTigerHasMoves()) {
          turn = 'gameover_goat';
          infoMessage = '🏆 Goat wins! All tigers trapped';
          GameStats.incrementGoatWins();
          GameStats.incrementTotalGames();
        } else {
          turn = 'goat';
          infoMessage = '';
          _recordCurrentPosition();
        }
      } else {
        turn = 'goat';
        infoMessage = '';
        _recordCurrentPosition();
      }
    });
    HapticFeedback.lightImpact();
    if (capture == null) {
      SoundManager.playTap();
    } else {
      SoundManager.playCapture();
    }
  }

  void executeGoatMove(int from, int to) {
    final legalMoves = getGoatMoves(from);
    final isLegalMove = legalMoves.any(
      (move) => _matchesMove(move, to, null),
    );

    if (board[from] != BaghchalRules.goat ||
        board[to] != BaghchalRules.empty ||
        !isLegalMove) {
      final rawMoves = BaghchalRules.goatMoves(
        board: board,
        adjacency: adjacency,
        from: from,
      );
      final isRepeatOnly = rawMoves.any(
        (move) => _matchesMove(move, to, null),
      );

      infoMessage = isRepeatOnly
          ? 'That move repeats a previous board position'
          : 'Invalid goat move';
      setState(() {});
      return;
    }

    setState(() {
      board[to] = 2;
      board[from] = 0;
      final idx = goatIndices.indexOf(from);
      if (idx != -1) goatIndices[idx] = to;
      lastMoveFrom = from;
      lastMoveTo = to;

      selectedGoat = null;
      selectedTiger = null;
      selectedGoatFromReserve = false;
      showHints = false;
      if (!anyTigerHasMoves()) {
        turn = 'gameover_goat';
        infoMessage = '🏆 Goat wins! All tigers trapped';
        GameStats.incrementGoatWins();
        GameStats.incrementTotalGames();
      } else {
        turn = 'tiger';
        infoMessage = '';
        _recordCurrentPosition();
      }
    });
    HapticFeedback.lightImpact();
    SoundManager.playTap();
    _scheduleAIMoveIfNeeded();
  }

  void placeGoat(int idx) {
    if (turn != 'goat' || goatsPlaced >= maxGoats || board[idx] != 0) return;
    setState(() {
      board[idx] = 2;
      goatIndices.add(idx);
      goatsPlaced++;
      selectedGoatFromReserve = false;
      showHints = false;
      lastMoveFrom = null;
      lastMoveTo = idx;

      if (goatsPlaced == maxGoats) {
        phase = 'movement';
        if (!anyTigerHasMoves()) {
          turn = 'gameover_goat';
          infoMessage = '🏆 Goat wins! All tigers trapped';
          GameStats.incrementGoatWins();
          GameStats.incrementTotalGames();
        } else {
          turn = 'tiger';
          infoMessage = '';
          _recordCurrentPosition();
        }
      } else {
        turn = 'tiger';
        infoMessage = '';
      }
    });
    HapticFeedback.lightImpact();
    SoundManager.playTap();
    _scheduleAIMoveIfNeeded();
  }

  // ─── AI scheduling ──────────────────────────────────────
  void _scheduleAIMoveIfNeeded() {
    if (aiEnabled &&
        turn == 'tiger' &&
        !aiThinking &&
        turn != 'gameover_tiger' &&
        turn != 'gameover_goat') {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && aiEnabled && turn == 'tiger' && !aiThinking) {
          _aiMove();
        }
      });
    }
  }

  void _aiMove() {
    if (aiThinking || !aiEnabled) return;
    if (turn == 'gameover_tiger' || turn == 'gameover_goat') return;
    if (turn != 'tiger') return;

    final allMoves = _selectAIMoves();
    if (allMoves.isEmpty) {
      if (phase == 'placement') {
        setState(() {
          turn = 'goat';
          infoMessage = 'No tiger moves, switching to goat';
        });
      } else {
        setState(() {
          turn = 'gameover_goat';
          infoMessage = 'All tigers trapped! Goats win!';
          GameStats.incrementGoatWins();
          GameStats.incrementTotalGames();
        });
      }
      return;
    }

    final chosen = _chooseAIMove(allMoves);
    if (chosen == null) return;

    aiThinking = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      aiThinking = false;
      if (mounted) {
        final moves = getTigerMoves(chosen['from']);
        bool stillValid = false;
        for (final m in moves) {
          if (m['to'] == chosen['to'] && m['capture'] == chosen['capture']) {
            stillValid = true;
            break;
          }
        }
        if (stillValid) {
          executeTigerMove(chosen['from'], chosen['to'], chosen['capture']);
        } else {
          if (aiEnabled && turn == 'tiger' && mounted) {
            _scheduleAIMoveIfNeeded();
          }
        }
        if (aiEnabled && turn == 'tiger' && mounted) {
          _scheduleAIMoveIfNeeded();
        }
      }
    });
  }

  // ─── Reset ──────────────────────────────────────────────
  void resetGame() {
    setState(() {
      board = List.filled(boardSize, 0);
      tigerIndices.clear();
      goatIndices.clear();
      goatsPlaced = 0;
      goatsCaptured = 0;
      phase = 'placement';
      turn = 'goat';
      selectedTiger = null;
      selectedGoat = null;
      selectedGoatFromReserve = false;
      showHints = false;
      aiThinking = false;
      infoMessage = 'Place goats · Tap reserve, then board';
      positionHistory.clear();
      lastMoveFrom = null;
      lastMoveTo = null;
      final corners = [0, 4, 20, 24];
      for (final c in corners) {
        board[c] = 1;
        tigerIndices.add(c);
      }
    });
  }

  // ─── Dialogs ────────────────────────────────────────────
  void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a2e1f),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Baghchal Rules',
          style:
              TextStyle(color: Color(0xFFf7f0dc), fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ruleText('Phase 1 – Placement'),
              _ruleText('• Goats place one by one from reserve.'),
              _ruleText(
                  '• After each goat, tigers move (and may capture if possible).'),
              _ruleText('• Goats cannot move yet.'),
              const SizedBox(height: 10),
              _ruleText('Phase 2 – Movement'),
              _ruleText(
                  '• Goats move one step to adjacent empty intersection.'),
              _ruleText('• Tigers can walk or capture (jump over a goat).'),
              const SizedBox(height: 10),
              _ruleText('Capture Rules (Tiger)'),
              _ruleText(
                  '• Tiger jumps over exactly one goat to an empty spot on the other side.'),
              _ruleText(
                  '• The jump must be along a straight line on the board.'),
              _ruleText(
                  '• Cannot jump over two goats, a tiger, or land off‑line.'),
              const SizedBox(height: 10),
              _ruleText('Repetition Rule'),
              _ruleText(
                  '• After all goats are placed, a move cannot recreate a previous board position.'),
              const SizedBox(height: 10),
              _ruleText('Winning'),
              _ruleText('• Tiger wins after capturing 5 goats.'),
              _ruleText('• Goats win if all tigers are trapped (no moves).'),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF3d5a3a)),
              const SizedBox(height: 8),
              const Text(
                'Developed by Laxman Dhungana',
                style: TextStyle(
                  color: Color(0xFFdcc29e),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                '© 2025 All rights reserved',
                style: TextStyle(
                  color: Color(0xFF8a9a7a),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Close', style: TextStyle(color: Color(0xFFf7f0dc))),
          ),
        ],
      ),
    );
  }

  Widget _ruleText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFdcc29e), fontSize: 13),
      ),
    );
  }

  void showStatsDialog(BuildContext context) async {
    final stats = await GameStats.loadStats();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a2e1f),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Game Statistics',
          style:
              TextStyle(color: Color(0xFFf7f0dc), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statText('Total Games', stats['totalGames']!),
            _statText('Tiger Wins', stats['tigerWins']!),
            _statText('Goat Wins', stats['goatWins']!),
            _statText('Total Goats Captured', stats['totalCaptures']!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Close', style: TextStyle(color: Color(0xFFf7f0dc))),
          ),
        ],
      ),
    );
  }

  Widget _statText(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFFdcc29e), fontSize: 14)),
          Text(value.toString(),
              style: const TextStyle(
                  color: Color(0xFFf7f0dc),
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ─── Lifecycle ──────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    resetGame();
  }

  // ─── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final themeColors = ThemeColors.of(widget.theme);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bagh', style: TextStyle(color: Colors.orange.shade700)),
            const Text('chal'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens, color: Color(0xFFdcc29e)),
            onPressed: widget.onThemeChange,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFFdcc29e)),
            onPressed: () => showInfoDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Color(0xFFdcc29e)),
            onPressed: () => showStatsDialog(context),
          ),
          IconButton(
            icon: Icon(
              SoundManager.isMuted() ? Icons.volume_off : Icons.volume_up,
              color: Color(0xFFdcc29e),
            ),
            onPressed: () {
              setState(() {
                SoundManager.toggleMute();
              });
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2d4a33),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4a7a4a)),
            ),
            child: Text(
              phase == 'placement' ? '● PLACEMENT' : '▶ MOVEMENT',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFaacf9e),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1a2e1f),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF3d5a3a)),
            ),
            child: Text(
              _statusText(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFdcc29e),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeColors.boardShadow,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 8),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: _buildBoard(themeColors),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: const Color(0xFF1a2e1f),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: maxGoats,
                        itemBuilder: (context, index) {
                          final remaining = maxGoats - goatsPlaced;
                          final isAvailable = index < remaining;
                          return GestureDetector(
                            onTap: () {
                              if (isAvailable && turn == 'goat') {
                                setState(() {
                                  selectedGoat = null;
                                  selectedTiger = null;
                                  selectedGoatFromReserve =
                                      !selectedGoatFromReserve;
                                  showHints = false;
                                  infoMessage = '';
                                });
                                HapticFeedback.lightImpact();
                                SoundManager.playTap();
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAvailable
                                    ? themeColors.goatColor
                                    : const Color(0xFF1a1a1a),
                                border: Border.all(
                                  color: isAvailable
                                      ? themeColors.goatBorder
                                      : const Color(0xFF1a1a1a),
                                  width: 2.5,
                                ),
                                boxShadow: isAvailable
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: isAvailable
                                    ? (selectedGoatFromReserve
                                        ? Icon(Icons.circle,
                                            size: 18,
                                            color: themeColors.goatBorder)
                                        : Icon(Icons.circle,
                                            size: 18,
                                            color: themeColors.goatBorder))
                                    : const Icon(Icons.circle,
                                        size: 18, color: Color(0xFF1a1a1a)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildButton(
                            '↻ New', () => resetGame(), Colors.brown.shade700),
                        const SizedBox(width: 8),
                        _buildButton('✦ Hint', () {
                          setState(() {
                            if (!showHints) {
                              if (turn == 'goat') {
                                if (selectedGoat == null &&
                                    !selectedGoatFromReserve) {
                                  for (final gi in goatIndices) {
                                    if (getGoatMoves(gi).isNotEmpty) {
                                      selectedGoat = gi;
                                      selectedTiger = null;
                                      selectedGoatFromReserve = false;
                                      break;
                                    }
                                  }
                                  if (selectedGoat == null &&
                                      goatsPlaced < maxGoats) {
                                    selectedGoatFromReserve = true;
                                  }
                                  if (selectedGoat == null &&
                                      !selectedGoatFromReserve) {
                                    infoMessage =
                                        'No goat can move and no reserve left';
                                    return;
                                  }
                                }
                              } else if (turn == 'tiger') {
                                if (selectedTiger == null) {
                                  for (final ti in tigerIndices) {
                                    if (getTigerMoves(ti).isNotEmpty) {
                                      selectedTiger = ti;
                                      selectedGoat = null;
                                      selectedGoatFromReserve = false;
                                      break;
                                    }
                                  }
                                  if (selectedTiger == null) {
                                    infoMessage = 'No tiger can move';
                                    return;
                                  }
                                }
                              }
                            }
                            showHints = !showHints;
                            infoMessage = showHints
                                ? 'Hints ON — tap highlighted circles'
                                : '';
                          });
                          HapticFeedback.lightImpact();
                          SoundManager.playTap();
                        }, Colors.grey.shade700),
                        const SizedBox(width: 8),
                        _buildAIToggleButton(),
                        const SizedBox(width: 8),
                        _buildDifficultyButton(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      infoMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8a9a7a),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (turn == 'gameover_tiger' || turn == 'gameover_goat')
            _buildWinOverlay(),
        ],
      ),
    );
  }

  Widget _buildWinOverlay() {
    final isTigerWin = turn == 'gameover_tiger';
    final message = isTigerWin ? '🐅 Tiger Wins!' : '🐐 Goat Wins!';
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(10, (index) {
                return const Text(
                  '⭐',
                  style: TextStyle(
                    fontSize: 40,
                    shadows: [
                      Shadow(
                        color: Colors.amber,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                shadows: [
                  Shadow(
                    color: Colors.white,
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Play Again', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildAIToggleButton() {
    final bool isOn = aiEnabled;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          aiEnabled = !aiEnabled;
          if (aiEnabled) {
            selectedTiger = null;
            selectedGoat = null;
            selectedGoatFromReserve = false;
            showHints = false;
            if (turn == 'tiger' &&
                turn != 'gameover_tiger' &&
                turn != 'gameover_goat') {
              _scheduleAIMoveIfNeeded();
            }
          }
        });
        HapticFeedback.lightImpact();
        SoundManager.playTap();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isOn ? Colors.red.shade700 : Colors.green.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOn ? Icons.smart_toy : Icons.smart_toy_outlined,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isOn ? 'AI: ON' : 'AI: OFF',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton() {
    final label = widget.difficulty.name.toUpperCase();
    return ElevatedButton(
      onPressed: widget.onDifficultyChange,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _statusText() {
    if (turn == 'goat') {
      final remaining = maxGoats - goatsPlaced;
      return 'Goat (${phase == 'placement' ? 'place $remaining' : 'move'})';
    } else if (turn == 'tiger') {
      return 'Tiger (captured $goatsCaptured)';
    } else if (turn == 'gameover_tiger') {
      return '🏆 Tiger wins! 5 goats eaten';
    } else if (turn == 'gameover_goat') {
      return '🏆 Goat wins! All tigers trapped';
    }
    return '';
  }

  // ─── Board widget ────────────────────────────────────────
  Widget _buildBoard(ThemeColors themeColors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth;
        final margin = boardSize * 0.1;
        final step = (boardSize - 2 * margin) / 4;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final local = details.localPosition;
            const double hitRadius = 30.0;
            for (int i = 0; i < 25; i++) {
              final row = i ~/ 5;
              final col = i % 5;
              final pos = Offset(margin + col * step, margin + row * step);
              final dx = local.dx - pos.dx;
              final dy = local.dy - pos.dy;
              if (dx * dx + dy * dy <= hitRadius * hitRadius) {
                _handleTap(i);
                return;
              }
            }
          },
          child: CustomPaint(
            painter: BoardPainter(
              board: board,
              tigerIndices: tigerIndices,
              goatIndices: goatIndices,
              selectedTiger: selectedTiger,
              selectedGoat: selectedGoat,
              selectedGoatFromReserve: selectedGoatFromReserve,
              phase: phase,
              turn: turn,
              aiEnabled: aiEnabled,
              showHints: showHints,
              lastMoveFrom: lastMoveFrom,
              lastMoveTo: lastMoveTo,
              getTigerMoves: getTigerMoves,
              getGoatMoves: getGoatMoves,
              themeColors: themeColors,
            ),
            size: Size(boardSize, boardSize),
          ),
        );
      },
    );
  }

  // ─── Tap handler ────────────────────────────────────────
  void _handleTap(int idx) {
    if (aiEnabled && turn == 'tiger') {
      infoMessage = 'AI controls tigers';
      setState(() {});
      return;
    }
    if (turn == 'gameover_tiger' || turn == 'gameover_goat') return;

    // Case: reserve selected → place goat
    if (selectedGoatFromReserve && turn == 'goat' && goatsPlaced < maxGoats) {
      if (board[idx] == 0) {
        placeGoat(idx);
      } else {
        infoMessage = 'That room is occupied';
        setState(() {});
      }
      return;
    }

    // Case: board goat selected → move (only in movement phase)
    if (selectedGoat != null && turn == 'goat') {
      if (phase != 'movement') {
        infoMessage = 'Goats cannot move in placement phase';
        setState(() {});
        return;
      }
      final moves = getGoatMoves(selectedGoat!);
      for (final m in moves) {
        if (m['to'] == idx) {
          executeGoatMove(selectedGoat!, idx);
          return;
        }
      }
      // Clicked on invalid spot: deselect
      setState(() {
        selectedGoat = null;
        showHints = false;
        infoMessage = '';
      });
      return;
    }

    // Case: tiger selected (only if AI off)
    if (selectedTiger != null && turn == 'tiger' && !aiEnabled) {
      final moves = getTigerMoves(selectedTiger!);
      for (final m in moves) {
        if (m['to'] == idx) {
          executeTigerMove(selectedTiger!, idx, m['capture']);
          return;
        }
      }
      // Clicked on invalid spot: deselect
      setState(() {
        selectedTiger = null;
        showHints = false;
        infoMessage = '';
      });
      return;
    }

    // If nothing selected, try to select a piece
    if (turn == 'goat') {
      if (board[idx] == 2) {
        if (phase != 'movement') {
          infoMessage = 'Goats cannot move in placement phase';
          setState(() {});
          return;
        }
        if (getGoatMoves(idx).isEmpty) {
          infoMessage = '⚠️ This goat has no moves';
          setState(() {});
          return;
        }
        setState(() {
          selectedGoat = idx;
          selectedTiger = null;
          selectedGoatFromReserve = false;
          showHints = false;
          infoMessage = '';
        });
      } else if (board[idx] == 1) {
        infoMessage = 'It\'s goat\'s turn';
        setState(() {});
      } else {
        infoMessage = 'Select a goat or reserve first';
        setState(() {});
      }
    } else if (turn == 'tiger' && !aiEnabled) {
      if (board[idx] == 1) {
        if (getTigerMoves(idx).isEmpty) {
          infoMessage = '⚠️ This tiger has no moves';
          setState(() {});
          return;
        }
        setState(() {
          selectedTiger = idx;
          selectedGoat = null;
          selectedGoatFromReserve = false;
          showHints = false;
          infoMessage = '';
        });
      } else if (board[idx] == 2) {
        infoMessage = 'Tigers cannot select goats';
        setState(() {});
      } else {
        infoMessage = 'Select a tiger first';
        setState(() {});
      }
    }
  }
}

// ─── Board Painter ────────────────────────────────────────
class BoardPainter extends CustomPainter {
  final List<int> board;
  final List<int> tigerIndices;
  final List<int> goatIndices;
  final int? selectedTiger;
  final int? selectedGoat;
  final bool selectedGoatFromReserve;
  final String phase;
  final String turn;
  final bool aiEnabled;
  final bool showHints;
  final int? lastMoveFrom;
  final int? lastMoveTo;

  final List<Map<String, dynamic>> Function(int) getTigerMoves;
  final List<Map<String, dynamic>> Function(int) getGoatMoves;
  final ThemeColors themeColors;

  const BoardPainter({
    required this.board,
    required this.tigerIndices,
    required this.goatIndices,
    required this.selectedTiger,
    required this.selectedGoat,
    required this.selectedGoatFromReserve,
    required this.phase,
    required this.turn,
    required this.aiEnabled,
    required this.showHints,
    required this.lastMoveFrom,
    required this.lastMoveTo,
    required this.getTigerMoves,
    required this.getGoatMoves,
    required this.themeColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = size.width;
    final margin = boardSize * 0.1;
    final step = (boardSize - 2 * margin) / 4;

    Offset getPosPx(int index) {
      final row = index ~/ 5;
      final col = index % 5;
      return Offset(margin + col * step, margin + row * step);
    }

    // ── Background ──
    final bgPaint = Paint()..color = themeColors.boardBg;
    canvas.drawRect(Rect.fromLTWH(0, 0, boardSize, boardSize), bgPaint);

    // ── Lines ──
    final linePaint = Paint()
      ..color = themeColors.lineColor.withOpacity(0.85)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final drawn = <String>{};
    for (final seg in BaghchalRules.lineSegments) {
      for (int i = 0; i < seg.length - 1; i++) {
        final a = seg[i], b = seg[i + 1];
        final key = '${min(a, b)}-${max(a, b)}';
        if (!drawn.contains(key)) {
          drawn.add(key);
          final p1 = getPosPx(a);
          final p2 = getPosPx(b);
          canvas.drawLine(p1, p2, linePaint);
        }
      }
    }

    // ── Dots ──
    final dotPaint = Paint()..color = themeColors.dotColor.withOpacity(0.7);
    for (int i = 0; i < 25; i++) {
      final pos = getPosPx(i);
      canvas.drawCircle(pos, 5, dotPaint);
    }

    // ── Last move highlight ──
    if (lastMoveFrom != null && lastMoveTo != null) {
      final p1 = getPosPx(lastMoveFrom!);
      final p2 = getPosPx(lastMoveTo!);
      final paint = Paint()
        ..color = Colors.yellow.withOpacity(0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p1, 20, paint);
      canvas.drawCircle(p2, 20, paint);
    }

    // ── Highlights (only if showHints) ──
    if (showHints) {
      if (selectedTiger != null && turn == 'tiger' && !aiEnabled) {
        final moves = getTigerMoves(selectedTiger!);
        for (final m in moves) {
          final pos = getPosPx(m['to']);
          final color = m['capture'] != null
              ? const Color(0xFFE74C3C).withOpacity(0.5)
              : const Color(0xFF2ECC71).withOpacity(0.45);
          final paint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 18, paint);
          final borderPaint = Paint()
            ..color = themeColors.lineColor.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawCircle(pos, 18, borderPaint);
        }
      }

      if (selectedGoat != null && turn == 'goat' && phase == 'movement') {
        final moves = getGoatMoves(selectedGoat!);
        for (final m in moves) {
          final pos = getPosPx(m['to']);
          final paint = Paint()
            ..color = const Color(0xFF3498DB).withOpacity(0.45)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 18, paint);
          final borderPaint = Paint()
            ..color = themeColors.lineColor.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawCircle(pos, 18, borderPaint);
        }
      }

      if (selectedGoatFromReserve && turn == 'goat' && phase == 'placement') {
        for (int i = 0; i < 25; i++) {
          if (board[i] == 0) {
            final pos = getPosPx(i);
            final paint = Paint()
              ..color = const Color(0xFF2ECC71).withOpacity(0.25)
              ..style = PaintingStyle.fill;
            canvas.drawCircle(pos, 16, paint);
            final borderPaint = Paint()
              ..color = themeColors.lineColor.withOpacity(0.15)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1;
            canvas.drawCircle(pos, 16, borderPaint);
          }
        }
      }
    }

    // ── Pieces ──
    for (int i = 0; i < 25; i++) {
      if (board[i] == 0) continue;
      final pos = getPosPx(i);
      final isTiger = board[i] == 1;
      final double r = isTiger ? 22 : 19;

      // Shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(pos + const Offset(0, 4), r, shadowPaint);

      // Base circle – tiger: plain orange, goat: white
      final fillColor =
          isTiger ? themeColors.tigerColor : themeColors.goatColor;
      final strokeColor =
          isTiger ? themeColors.tigerBorder : themeColors.goatBorder;
      final Paint piecePaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      final Paint strokePaint = Paint()
        ..color = strokeColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, r, piecePaint);
      canvas.drawCircle(pos, r, strokePaint);

      // No stripes – removed as requested.

      // Selection glow
      if (isTiger && selectedTiger == i && !aiEnabled) {
        final glowPaint = Paint()
          ..color = themeColors.selectedGlow.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawCircle(pos, r + 6, glowPaint);
      }
      if (!isTiger && selectedGoat == i) {
        final glowPaint = Paint()
          ..color = const Color(0xFF3498DB).withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawCircle(pos, r + 5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) => true;
}
