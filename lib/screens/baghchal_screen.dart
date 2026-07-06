import 'dart:math';
import 'dart:ui' as ui;

import 'package:baghchal_app/baghchal_ai.dart';
import 'package:baghchal_app/baghchal_rules.dart';
import 'package:baghchal_app/models/ai_difficulty.dart';
import 'package:baghchal_app/services/game_stats.dart';
import 'package:baghchal_app/services/sound_manager.dart';
import 'package:baghchal_app/theme/app_theme.dart';
import 'package:baghchal_app/widgets/board_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  ui.Image? tigerImage;
  ui.Image? goatImage;
  bool aiEnabled = false;
  bool aiThinking = false;
  bool showHints = false;
  String infoMessage = 'Place goats · Tap reserve, then board';

  // ─── Last move tracking ──────────────────────────────────
  int? lastMoveFrom;
  int? lastMoveTo;

  // ─── Anti‑loop tracking ──────────────────────────────────
  Map<int, Map<String, int>> pieceLastMove = {};

  void _updatePieceLastMove(int pieceIndex, int from, int to) {
    final previous = pieceLastMove[pieceIndex];
    final nextMove =
        previous != null && previous['from'] == to && previous['to'] == from
            ? {
                'from': from,
                'to': to,
                'count': (previous['count'] ?? 0) + 1,
              }
            : {'from': from, 'to': to, 'count': 1};

    pieceLastMove.remove(pieceIndex);
    pieceLastMove[to] = nextMove;
  }

  bool _isIllegalLoop(int pieceIndex, int from, int to) {
    final previous = pieceLastMove[pieceIndex];
    if (previous == null) return false;
    if (previous['from'] == to && previous['to'] == from) {
      final count = (previous['count'] ?? 0) + 1;
      if (count >= 3) return true;
    }
    return false;
  }

  void _clearPieceHistory(int pieceIndex) {
    pieceLastMove.remove(pieceIndex);
  }

  // ─── Adjacency ──────────────────────────────────────────
  final List<List<int>> adjacency = List.generate(boardSize, (_) => []);

  void buildAdjacency() {
    final edges = <String>{};
    for (final seg in BaghchalRules.lineSegments) {
      for (int i = 0; i < seg.length - 1; i++) {
        final a = seg[i], b = seg[i + 1];
        final key = '${min(a, b)}-${max(a, b)}';
        if (!edges.contains(key)) {
          edges.add(key);
          adjacency[a].add(b);
          adjacency[b].add(a);
        }
      }
    }
  }

  List<int> getNeighbors(int idx) => adjacency[idx];

  // ─── Tiger moves ────────────────────────────────────────
  List<Map<String, dynamic>> getTigerMoves(int idx) {
    return BaghchalRules.tigerMoves(
      board: board,
      adjacency: adjacency,
      from: idx,
    );
  }

  // ─── Goat moves ─────────────────────────────────────────
  List<Map<String, dynamic>> getGoatMoves(int idx) {
    return BaghchalRules.goatMoves(
      board: board,
      adjacency: adjacency,
      from: idx,
    );
  }

  bool anyTigerHasMoves() {
    for (final ti in tigerIndices) {
      for (final move in getTigerMoves(ti)) {
        if (!_isIllegalLoop(ti, ti, move['to'] as int)) return true;
      }
    }
    return false;
  }

  // ─── AI ──────────────────────────────────────────────────
  List<Map<String, dynamic>> _selectAIMoves() {
    List<Map<String, dynamic>> allMoves = [];
    for (final ti in tigerIndices) {
      final moves = getTigerMoves(ti);
      for (final m in moves) {
        if (_isIllegalLoop(ti, ti, m['to'])) continue;
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

    return BaghchalAi.chooseHardTigerMove(
      board: board,
      adjacency: adjacency,
      tigerIndices: tigerIndices,
      goatIndices: goatIndices,
      phase: phase,
      goatsPlaced: goatsPlaced,
      goatsCaptured: goatsCaptured,
      pieceLastMove: pieceLastMove,
    );
  }

  // ─── Execute moves ──────────────────────────────────────
  void executeTigerMove(int from, int to, int? capture) {
    final isLegalMove = getTigerMoves(from).any(
      (move) => move['to'] == to && move['capture'] == capture,
    );
    if (!isLegalMove) {
      infoMessage = 'Invalid tiger move';
      setState(() {});
      return;
    }

    if (capture != null) {
      if (board[capture] != 2 || board[to] != 0) {
        infoMessage = 'Invalid capture';
        setState(() {});
        return;
      }
      if (!getNeighbors(from).contains(capture) ||
          !getNeighbors(capture).contains(to)) {
        infoMessage = 'Capture not along a line';
        setState(() {});
        return;
      }
    } else {
      if (!getNeighbors(from).contains(to)) {
        infoMessage = 'Not adjacent';
        setState(() {});
        return;
      }
    }

    if (_isIllegalLoop(from, from, to)) {
      infoMessage = 'Cannot move back & forth more than twice (anti‑loop)';
      setState(() {});
      return;
    }

    bool tigerWon = false;
    bool goatWon = false;

    setState(() {
      board[to] = 1;
      board[from] = 0;
      final idx = tigerIndices.indexOf(from);
      if (idx != -1) tigerIndices[idx] = to;
      _updatePieceLastMove(from, from, to);
      lastMoveFrom = from;
      lastMoveTo = to;

      if (capture != null) {
        board[capture] = 0;
        goatsCaptured++;
        final gi = goatIndices.indexOf(capture);
        if (gi != -1) {
          goatIndices.removeAt(gi);
          _clearPieceHistory(capture);
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
        tigerWon = true;
        GameStats.incrementTigerWins();
        GameStats.incrementTotalGames();
      } else if (!anyTigerHasMoves()) {
        turn = 'gameover_goat';
        infoMessage = '🏆 Goat wins! All tigers trapped';
        goatWon = true;
        GameStats.incrementGoatWins();
        GameStats.incrementTotalGames();
      } else if (phase == 'placement' && goatsPlaced == maxGoats) {
        phase = 'movement';
        if (!anyTigerHasMoves()) {
          turn = 'gameover_goat';
          infoMessage = '🏆 Goat wins! All tigers trapped';
          goatWon = true;
          GameStats.incrementGoatWins();
          GameStats.incrementTotalGames();
        } else {
          turn = 'goat';
          infoMessage = '';
        }
      } else {
        turn = 'goat';
        infoMessage = '';
      }
    });
    HapticFeedback.lightImpact();
    if (tigerWon) {
      SoundManager.playTigerWin();
    } else if (goatWon) {
      SoundManager.playGoatWin();
    } else if (capture != null) {
      SoundManager.playTiger();
    } else {
      SoundManager.playMove();
    }
  }

  void executeGoatMove(int from, int to) {
    final isLegalMove = getGoatMoves(from).any((move) => move['to'] == to);
    if (!isLegalMove) {
      infoMessage = 'Invalid goat move';
      setState(() {});
      return;
    }

    if (_isIllegalLoop(from, from, to)) {
      infoMessage = 'Cannot move back & forth more than twice (anti‑loop)';
      setState(() {});
      return;
    }

    bool goatWon = false;

    setState(() {
      board[to] = 2;
      board[from] = 0;
      final idx = goatIndices.indexOf(from);
      if (idx != -1) goatIndices[idx] = to;
      _updatePieceLastMove(from, from, to);
      lastMoveFrom = from;
      lastMoveTo = to;

      selectedGoat = null;
      selectedTiger = null;
      selectedGoatFromReserve = false;
      showHints = false;
      if (!anyTigerHasMoves()) {
        turn = 'gameover_goat';
        infoMessage = '🏆 Goat wins! All tigers trapped';
        goatWon = true;
        GameStats.incrementGoatWins();
        GameStats.incrementTotalGames();
      } else {
        turn = 'tiger';
        infoMessage = '';
      }
    });
    HapticFeedback.lightImpact();
    if (goatWon) {
      SoundManager.playGoatWin();
    } else {
      SoundManager.playMove();
    }
    _scheduleAIMoveIfNeeded();
  }

  void placeGoat(int idx) {
    if (turn != 'goat' || goatsPlaced >= maxGoats || board[idx] != 0) return;
    bool goatWon = false;

    setState(() {
      board[idx] = 2;
      goatIndices.add(idx);
      goatsPlaced++;
      selectedGoatFromReserve = false;
      showHints = false;
      lastMoveFrom = null;
      lastMoveTo = idx;

      if (!anyTigerHasMoves()) {
        turn = 'gameover_goat';
        infoMessage = '🏆 Goat wins! All tigers trapped';
        goatWon = true;
        GameStats.incrementGoatWins();
        GameStats.incrementTotalGames();
      } else if (goatsPlaced == maxGoats) {
        phase = 'movement';
        turn = 'tiger';
        infoMessage = '';
      } else {
        turn = 'tiger';
        infoMessage = '';
      }
    });
    HapticFeedback.lightImpact();
    if (goatWon) {
      SoundManager.playGoatWin();
    } else {
      SoundManager.playMove();
    }
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
      setState(() {
        turn = 'gameover_goat';
        infoMessage = '🏆 Goat wins! All tigers trapped';
        GameStats.incrementGoatWins();
        GameStats.incrementTotalGames();
      });
      SoundManager.playGoatWin();
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
      pieceLastMove.clear();
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
              _ruleText('Anti‑Loop Rule'),
              _ruleText(
                  '• A piece cannot move back and forth on the same edge more than twice consecutively.'),
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
    buildAdjacency();
    resetGame();
    _loadPieceImages();
  }

  Future<void> _loadPieceImages() async {
    final tiger = await _loadUiImage('assets/icon/tiger.jpg');
    final goat = await _loadUiImage('assets/icon/goat.jpeg');
    if (!mounted) return;
    setState(() {
      tigerImage = tiger;
      goatImage = goat;
    });
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
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
                                    ? ClipOval(
                                        child: Image.asset(
                                          'assets/icon/goat.jpeg',
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                        ),
                                      )
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
    final message = isTigerWin ? 'Tiger Wins!' : 'Goat Wins!';
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
              tigerImage: tigerImage,
              goatImage: goatImage,
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
          if (_isIllegalLoop(selectedGoat!, selectedGoat!, idx)) {
            infoMessage =
                'Cannot move back & forth more than twice (anti‑loop)';
            setState(() {});
            return;
          }
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
          if (_isIllegalLoop(selectedTiger!, selectedTiger!, idx)) {
            infoMessage =
                'Cannot move back & forth more than twice (anti‑loop)';
            setState(() {});
            return;
          }
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
