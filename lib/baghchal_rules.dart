import 'dart:math';

class BaghchalRules {
  static const int boardSize = 25;
  static const int maxGoats = 20;
  static const int empty = 0;
  static const int tiger = 1;
  static const int goat = 2;

  static const List<List<int>> lineSegments = [
    [0, 1, 2, 3, 4],
    [5, 6, 7, 8, 9],
    [10, 11, 12, 13, 14],
    [15, 16, 17, 18, 19],
    [20, 21, 22, 23, 24],
    [0, 5, 10, 15, 20],
    [1, 6, 11, 16, 21],
    [2, 7, 12, 17, 22],
    [3, 8, 13, 18, 23],
    [4, 9, 14, 19, 24],
    [0, 6, 12, 18, 24],
    [4, 8, 12, 16, 20],
    [2, 6, 10],
    [2, 8, 14],
    [10, 16, 22],
    [14, 18, 22],
  ];

  static List<List<int>> buildAdjacency() {
    final adjacency = List.generate(boardSize, (_) => <int>[]);
    final edges = <String>{};

    for (final segment in lineSegments) {
      for (var i = 0; i < segment.length - 1; i++) {
        final a = segment[i];
        final b = segment[i + 1];
        final key = '${min(a, b)}-${max(a, b)}';

        if (edges.add(key)) {
          adjacency[a].add(b);
          adjacency[b].add(a);
        }
      }
    }

    return adjacency
        .map((neighbors) => List<int>.unmodifiable(neighbors))
        .toList();
  }

  static List<Map<String, dynamic>> tigerMoves({
    required List<int> board,
    required List<List<int>> adjacency,
    required int from,
  }) {
    if (!_isPoint(from) || board[from] != tiger) {
      return const [];
    }

    final moves = <Map<String, dynamic>>[];

    for (final to in adjacency[from]) {
      if (board[to] == empty) {
        moves.add({'to': to, 'capture': null, 'type': 'walk'});
      }
    }

    final captures = <String>{};
    for (final segment in lineSegments) {
      for (var i = 0; i < segment.length; i++) {
        if (segment[i] != from) continue;

        _addCapture(
          board: board,
          moves: moves,
          seen: captures,
          middle: i + 1 < segment.length ? segment[i + 1] : null,
          landing: i + 2 < segment.length ? segment[i + 2] : null,
        );
        _addCapture(
          board: board,
          moves: moves,
          seen: captures,
          middle: i - 1 >= 0 ? segment[i - 1] : null,
          landing: i - 2 >= 0 ? segment[i - 2] : null,
        );
      }
    }

    return moves;
  }

  static List<Map<String, dynamic>> goatMoves({
    required List<int> board,
    required List<List<int>> adjacency,
    required int from,
  }) {
    if (!_isPoint(from) || board[from] != goat) {
      return const [];
    }

    final moves = <Map<String, dynamic>>[];
    for (final to in adjacency[from]) {
      if (board[to] == empty) {
        moves.add({'to': to, 'capture': null, 'type': 'walk'});
      }
    }
    return moves;
  }

  static void _addCapture({
    required List<int> board,
    required List<Map<String, dynamic>> moves,
    required Set<String> seen,
    required int? middle,
    required int? landing,
  }) {
    if (middle == null || landing == null) return;
    if (board[middle] != goat || board[landing] != empty) return;

    final key = '$landing-$middle';
    if (seen.add(key)) {
      moves.add({'to': landing, 'capture': middle, 'type': 'capture'});
    }
  }

  static bool _isPoint(int point) => point >= 0 && point < boardSize;
}
