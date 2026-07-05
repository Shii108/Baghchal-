import 'dart:math';

import 'baghchal_rules.dart';

class BaghchalAi {
  static const int _tigerWinScore = 1000000;
  static const int _goatWinScore = -1000000;

  static Map<String, dynamic>? chooseHardTigerMove({
    required List<int> board,
    required List<List<int>> adjacency,
    required List<int> tigerIndices,
    required List<int> goatIndices,
    required String phase,
    required int goatsPlaced,
    required int goatsCaptured,
    Map<int, Map<String, int>> pieceLastMove = const {},
    int? searchDepth,
  }) {
    final state = _AiState(
      board: List<int>.from(board),
      adjacency: adjacency,
      tigerIndices: List<int>.from(tigerIndices),
      goatIndices: List<int>.from(goatIndices),
      phase: phase,
      goatsPlaced: goatsPlaced,
      goatsCaptured: goatsCaptured,
      tigerTurn: true,
      history: _copyHistory(pieceLastMove),
    );

    final moves = _orderedTigerMoves(state);
    if (moves.isEmpty) return null;

    final depth = searchDepth ?? _searchDepthFor(state);
    final budget = _SearchBudget(_nodeBudgetFor(state));
    final cache = <String, int>{};
    var alpha = _goatWinScore * 2;
    const beta = _tigerWinScore * 2;
    var bestScore = _goatWinScore * 2;
    var bestMove = moves.first;

    for (final move in moves) {
      final next = _applyTigerMove(state, move);
      final score = _minimax(next, depth - 1, alpha, beta, cache, budget) +
          _rootMoveBias(state, move);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
      alpha = max(alpha, bestScore);
    }

    return {
      'from': bestMove.from,
      'to': bestMove.to,
      'capture': bestMove.capture,
    };
  }

  static int _searchDepthFor(_AiState state) {
    if (state.phase == 'placement') {
      if (state.goatsPlaced < 10) return 4;
      if (state.goatsPlaced < 16) return 5;
      return 6;
    }

    final tigerBranching = _tigerMoves(state).length;
    final goatBranching = _goatMoves(state).length;
    final branching = max(tigerBranching, goatBranching);
    if (branching <= 8) return 8;
    if (branching <= 14) return 7;
    return 6;
  }

  static int _nodeBudgetFor(_AiState state) {
    if (state.phase == 'placement') {
      return state.goatsPlaced < 10 ? 70000 : 110000;
    }
    return 140000;
  }

  static int _minimax(
    _AiState state,
    int depth,
    int alpha,
    int beta,
    Map<String, int> cache,
    _SearchBudget budget,
  ) {
    if (!budget.consume()) return _evaluate(state);

    final terminal = _terminalScore(state, depth);
    if (terminal != null) return terminal;
    if (depth <= 0) return _evaluate(state);

    final cacheKey = '$depth|${state.cacheKey}';
    final cached = cache[cacheKey];
    if (cached != null) return cached;

    var fullySearched = true;
    if (state.tigerTurn) {
      var best = _goatWinScore * 2;
      final moves = _orderedTigerMoves(state);
      if (moves.isEmpty) return _goatWinScore - depth * 1000;

      for (final move in moves) {
        final score = _minimax(
          _applyTigerMove(state, move),
          depth - 1,
          alpha,
          beta,
          cache,
          budget,
        );
        best = max(best, score);
        alpha = max(alpha, best);
        if (beta <= alpha) {
          fullySearched = false;
          break;
        }
      }
      if (fullySearched && !budget.exhausted) cache[cacheKey] = best;
      return best;
    }

    var best = _tigerWinScore * 2;
    final moves = _orderedGoatMoves(state);
    if (moves.isEmpty) return _evaluate(state) + 2500;

    for (final move in moves) {
      final score = _minimax(
        _applyGoatMove(state, move),
        depth - 1,
        alpha,
        beta,
        cache,
        budget,
      );
      best = min(best, score);
      beta = min(beta, best);
      if (beta <= alpha) {
        fullySearched = false;
        break;
      }
    }
    if (fullySearched && !budget.exhausted) cache[cacheKey] = best;
    return best;
  }

  static int? _terminalScore(_AiState state, int depth) {
    if (state.goatsCaptured >= 5) {
      return _tigerWinScore + depth * 1000;
    }
    if (!_hasTigerMoves(state)) {
      return _goatWinScore - depth * 1000;
    }
    return null;
  }

  static int _evaluate(_AiState state) {
    final terminal = _terminalScore(state, 0);
    if (terminal != null) return terminal;

    var score = state.goatsCaptured * 1800;
    final tigerMoves = _tigerMoves(state);
    final captureMoves = tigerMoves.where((move) => move.capture != null);
    score += tigerMoves.length * 35;
    score += captureMoves.length * 260;

    for (final tiger in state.tigerIndices) {
      final moves = BaghchalRules.tigerMoves(
        board: state.board,
        adjacency: state.adjacency,
        from: tiger,
      ).where((move) {
        final to = move['to'] as int;
        return !_isIllegalLoop(state.history, tiger, tiger, to);
      }).toList();

      final mobility = moves.length;
      if (mobility == 0) {
        score -= 900;
      } else if (mobility == 1) {
        score -= 220;
      } else {
        score += mobility * 45;
      }

      final degree = state.adjacency[tiger].length;
      score += degree * 18;
      score += _emptyNeighborCount(state, tiger) * 25;
    }

    score += _spreadScore(state);
    score += _captureThreatScore(state);
    score -= _goatControlScore(state);

    if (state.phase == 'placement') {
      score += _placementShapeScore(state);
    }

    return score;
  }

  static int _rootMoveBias(_AiState state, _AiMove move) {
    var score = move.capture == null ? 0 : 80;
    final next = _applyTigerMove(state, move);
    if (!_hasTigerMoves(next)) score -= 50000;
    score += _spreadScore(next) ~/ 8;
    return score;
  }

  static int _spreadScore(_AiState state) {
    var score = 0;
    for (var i = 0; i < state.tigerIndices.length; i++) {
      for (var j = i + 1; j < state.tigerIndices.length; j++) {
        final a = state.tigerIndices[i];
        final b = state.tigerIndices[j];
        final distance = (a ~/ 5 - b ~/ 5).abs() + (a % 5 - b % 5).abs();
        score += distance * 24;
      }
    }
    return score;
  }

  static int _captureThreatScore(_AiState state) {
    var score = 0;
    final threatenedGoats = <int>{};
    for (final tiger in state.tigerIndices) {
      for (final move in BaghchalRules.tigerMoves(
        board: state.board,
        adjacency: state.adjacency,
        from: tiger,
      )) {
        final capture = move['capture'] as int?;
        if (capture != null) threatenedGoats.add(capture);
      }
    }
    score += threatenedGoats.length * 170;
    return score;
  }

  static int _goatControlScore(_AiState state) {
    var score = 0;
    for (final goat in state.goatIndices) {
      for (final neighbor in state.adjacency[goat]) {
        if (state.board[neighbor] == BaghchalRules.tiger) {
          score += 14;
        }
      }
    }
    return score;
  }

  static int _placementShapeScore(_AiState state) {
    var score = 0;
    for (final tiger in state.tigerIndices) {
      final row = tiger ~/ 5;
      final col = tiger % 5;
      final edgeDistance = [row, col, 4 - row, 4 - col].reduce(min);
      score += edgeDistance * 20;
    }
    return score;
  }

  static int _emptyNeighborCount(_AiState state, int point) {
    var count = 0;
    for (final neighbor in state.adjacency[point]) {
      if (state.board[neighbor] == BaghchalRules.empty) count++;
    }
    return count;
  }

  static List<_AiMove> _orderedTigerMoves(_AiState state) {
    final moves = _tigerMoves(state);
    moves.sort((a, b) {
      final aScore = _tigerMoveOrderScore(state, a);
      final bScore = _tigerMoveOrderScore(state, b);
      return bScore.compareTo(aScore);
    });
    return moves;
  }

  static int _tigerMoveOrderScore(_AiState state, _AiMove move) {
    final next = _applyTigerMove(state, move);
    var score = move.capture == null ? 0 : 10000;
    if (next.goatsCaptured >= 5) score += 100000;
    if (!_hasTigerMoves(next)) score -= 100000;
    score += _tigerMoves(next).length * 25;
    score += _spreadScore(next);
    return score;
  }

  static List<_AiMove> _orderedGoatMoves(_AiState state) {
    final moves = _goatMoves(state);
    moves.sort((a, b) {
      final aScore = _goatMoveOrderScore(state, a);
      final bScore = _goatMoveOrderScore(state, b);
      return aScore.compareTo(bScore);
    });
    return moves;
  }

  static int _goatMoveOrderScore(_AiState state, _AiMove move) {
    final next = _applyGoatMove(state, move);
    if (!_hasTigerMoves(next)) return _goatWinScore;
    return _evaluate(next);
  }

  static bool _hasTigerMoves(_AiState state) => _tigerMoves(state).isNotEmpty;

  static List<_AiMove> _tigerMoves(_AiState state) {
    final moves = <_AiMove>[];
    for (final tiger in state.tigerIndices) {
      if (state.board[tiger] != BaghchalRules.tiger) continue;
      for (final move in BaghchalRules.tigerMoves(
        board: state.board,
        adjacency: state.adjacency,
        from: tiger,
      )) {
        final to = move['to'] as int;
        if (_isIllegalLoop(state.history, tiger, tiger, to)) continue;
        moves.add(_AiMove(
          from: tiger,
          to: to,
          capture: move['capture'] as int?,
        ));
      }
    }
    return moves;
  }

  static List<_AiMove> _goatMoves(_AiState state) {
    final moves = <_AiMove>[];
    if (state.phase == 'placement' &&
        state.goatsPlaced < BaghchalRules.maxGoats) {
      for (var i = 0; i < BaghchalRules.boardSize; i++) {
        if (state.board[i] == BaghchalRules.empty) {
          moves.add(_AiMove(from: -1, to: i, isPlacement: true));
        }
      }
      return moves;
    }

    for (final goat in state.goatIndices) {
      if (state.board[goat] != BaghchalRules.goat) continue;
      for (final move in BaghchalRules.goatMoves(
        board: state.board,
        adjacency: state.adjacency,
        from: goat,
      )) {
        final to = move['to'] as int;
        if (_isIllegalLoop(state.history, goat, goat, to)) continue;
        moves.add(_AiMove(from: goat, to: to));
      }
    }
    return moves;
  }

  static _AiState _applyTigerMove(_AiState state, _AiMove move) {
    final nextBoard = List<int>.from(state.board);
    final nextTigers = List<int>.from(state.tigerIndices);
    final nextGoats = List<int>.from(state.goatIndices);
    final nextHistory = Map<int, _LoopRecord>.from(state.history);

    nextBoard[move.from] = BaghchalRules.empty;
    nextBoard[move.to] = BaghchalRules.tiger;
    final tigerIndex = nextTigers.indexOf(move.from);
    if (tigerIndex != -1) nextTigers[tigerIndex] = move.to;
    _updateHistory(nextHistory, move.from, move.from, move.to);

    var nextCaptured = state.goatsCaptured;
    if (move.capture != null) {
      nextBoard[move.capture!] = BaghchalRules.empty;
      nextGoats.remove(move.capture);
      nextHistory.remove(move.capture);
      nextCaptured++;
    }

    return state.copyWith(
      board: nextBoard,
      tigerIndices: nextTigers,
      goatIndices: nextGoats,
      goatsCaptured: nextCaptured,
      phase: state.goatsPlaced >= BaghchalRules.maxGoats
          ? 'movement'
          : state.phase,
      tigerTurn: false,
      history: nextHistory,
    );
  }

  static _AiState _applyGoatMove(_AiState state, _AiMove move) {
    final nextBoard = List<int>.from(state.board);
    final nextTigers = List<int>.from(state.tigerIndices);
    final nextGoats = List<int>.from(state.goatIndices);
    final nextHistory = Map<int, _LoopRecord>.from(state.history);
    var nextPlaced = state.goatsPlaced;
    var nextPhase = state.phase;

    if (move.isPlacement) {
      nextBoard[move.to] = BaghchalRules.goat;
      nextGoats.add(move.to);
      nextPlaced++;
      if (nextPlaced >= BaghchalRules.maxGoats) nextPhase = 'movement';
    } else {
      nextBoard[move.from] = BaghchalRules.empty;
      nextBoard[move.to] = BaghchalRules.goat;
      final goatIndex = nextGoats.indexOf(move.from);
      if (goatIndex != -1) nextGoats[goatIndex] = move.to;
      _updateHistory(nextHistory, move.from, move.from, move.to);
    }

    return state.copyWith(
      board: nextBoard,
      tigerIndices: nextTigers,
      goatIndices: nextGoats,
      goatsPlaced: nextPlaced,
      phase: nextPhase,
      tigerTurn: true,
      history: nextHistory,
    );
  }

  static Map<int, _LoopRecord> _copyHistory(
    Map<int, Map<String, int>> rawHistory,
  ) {
    final history = <int, _LoopRecord>{};
    for (final entry in rawHistory.entries) {
      final from = entry.value['from'];
      final to = entry.value['to'];
      final count = entry.value['count'];
      if (from == null || to == null || count == null) continue;
      history[entry.key] = _LoopRecord(from: from, to: to, count: count);
    }
    return history;
  }

  static void _updateHistory(
    Map<int, _LoopRecord> history,
    int pieceIndex,
    int from,
    int to,
  ) {
    final previous = history[pieceIndex];
    final count = previous != null &&
            previous.from == to &&
            previous.to == from
        ? previous.count + 1
        : 1;

    history.remove(pieceIndex);
    history[to] = _LoopRecord(from: from, to: to, count: count);
  }

  static bool _isIllegalLoop(
    Map<int, _LoopRecord> history,
    int pieceIndex,
    int from,
    int to,
  ) {
    final previous = history[pieceIndex];
    if (previous == null) return false;
    return previous.from == to &&
        previous.to == from &&
        previous.count + 1 >= 3;
  }
}

class _AiState {
  final List<int> board;
  final List<List<int>> adjacency;
  final List<int> tigerIndices;
  final List<int> goatIndices;
  final String phase;
  final int goatsPlaced;
  final int goatsCaptured;
  final bool tigerTurn;
  final Map<int, _LoopRecord> history;

  const _AiState({
    required this.board,
    required this.adjacency,
    required this.tigerIndices,
    required this.goatIndices,
    required this.phase,
    required this.goatsPlaced,
    required this.goatsCaptured,
    required this.tigerTurn,
    required this.history,
  });

  String get cacheKey {
    final historyKeys = history.keys.toList()..sort();
    final historyKey = historyKeys
        .map((key) {
          final record = history[key]!;
          return '$key:${record.from},${record.to},${record.count}';
        })
        .join(';');
    return '${board.join()}|$phase|$goatsPlaced|$goatsCaptured|'
        '${tigerTurn ? 1 : 0}|$historyKey';
  }

  _AiState copyWith({
    List<int>? board,
    List<int>? tigerIndices,
    List<int>? goatIndices,
    String? phase,
    int? goatsPlaced,
    int? goatsCaptured,
    bool? tigerTurn,
    Map<int, _LoopRecord>? history,
  }) {
    return _AiState(
      board: board ?? this.board,
      adjacency: adjacency,
      tigerIndices: tigerIndices ?? this.tigerIndices,
      goatIndices: goatIndices ?? this.goatIndices,
      phase: phase ?? this.phase,
      goatsPlaced: goatsPlaced ?? this.goatsPlaced,
      goatsCaptured: goatsCaptured ?? this.goatsCaptured,
      tigerTurn: tigerTurn ?? this.tigerTurn,
      history: history ?? this.history,
    );
  }
}

class _AiMove {
  final int from;
  final int to;
  final int? capture;
  final bool isPlacement;

  const _AiMove({
    required this.from,
    required this.to,
    this.capture,
    this.isPlacement = false,
  });
}

class _LoopRecord {
  final int from;
  final int to;
  final int count;

  const _LoopRecord({
    required this.from,
    required this.to,
    required this.count,
  });
}

class _SearchBudget {
  int remaining;

  _SearchBudget(this.remaining);

  bool consume() {
    if (remaining <= 0) return false;
    remaining--;
    return true;
  }

  bool get exhausted => remaining <= 0;
}
