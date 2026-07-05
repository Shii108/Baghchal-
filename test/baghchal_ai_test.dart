import 'package:baghchal_app/baghchal_ai.dart';
import 'package:baghchal_app/baghchal_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<List<int>> adjacency;

  setUp(() {
    adjacency = BaghchalRules.buildAdjacency();
  });

  test('hard tiger AI takes an immediate fifth capture', () {
    final board = List<int>.filled(
      BaghchalRules.boardSize,
      BaghchalRules.empty,
    );
    const tigers = [0, 4, 20, 24];
    for (final tiger in tigers) {
      board[tiger] = BaghchalRules.tiger;
    }
    board[1] = BaghchalRules.goat;

    final move = BaghchalAi.chooseHardTigerMove(
      board: board,
      adjacency: adjacency,
      tigerIndices: tigers,
      goatIndices: const [1],
      phase: 'placement',
      goatsPlaced: 1,
      goatsCaptured: 4,
      searchDepth: 2,
    );

    expect(move, isNotNull);
    expect(move!['from'], 0);
    expect(move['to'], 2);
    expect(move['capture'], 1);
  });

  test('hard tiger AI avoids an immediate goat trapping reply', () {
    final board = List<int>.filled(
      BaghchalRules.boardSize,
      BaghchalRules.goat,
    );
    const tigers = [0, 1, 2, 3];
    const empties = [4, 13];
    for (final empty in empties) {
      board[empty] = BaghchalRules.empty;
    }
    for (final tiger in tigers) {
      board[tiger] = BaghchalRules.tiger;
    }
    final goats = [
      for (var i = 0; i < BaghchalRules.boardSize; i++)
        if (board[i] == BaghchalRules.goat) i,
    ];

    final move = BaghchalAi.chooseHardTigerMove(
      board: board,
      adjacency: adjacency,
      tigerIndices: tigers,
      goatIndices: goats,
      phase: 'placement',
      goatsPlaced: 19,
      goatsCaptured: 0,
      searchDepth: 2,
    );

    expect(move, isNotNull);
    final after = _applyTigerMove(board, tigers, move!);

    expect(_goatTrapPlacements(after.board, after.tigers, adjacency), isEmpty);
  });
}

_TestState _applyTigerMove(
  List<int> board,
  List<int> tigers,
  Map<String, dynamic> move,
) {
  final nextBoard = List<int>.from(board);
  final nextTigers = List<int>.from(tigers);
  final from = move['from'] as int;
  final to = move['to'] as int;
  final capture = move['capture'] as int?;

  nextBoard[from] = BaghchalRules.empty;
  nextBoard[to] = BaghchalRules.tiger;
  nextTigers[nextTigers.indexOf(from)] = to;
  if (capture != null) {
    nextBoard[capture] = BaghchalRules.empty;
  }

  return _TestState(nextBoard, nextTigers);
}

List<int> _goatTrapPlacements(
  List<int> board,
  List<int> tigers,
  List<List<int>> adjacency,
) {
  final placements = <int>[];
  for (var point = 0; point < BaghchalRules.boardSize; point++) {
    if (board[point] != BaghchalRules.empty) continue;
    final nextBoard = List<int>.from(board);
    nextBoard[point] = BaghchalRules.goat;
    if (!_hasTigerMoves(nextBoard, tigers, adjacency)) {
      placements.add(point);
    }
  }
  return placements;
}

bool _hasTigerMoves(
  List<int> board,
  List<int> tigers,
  List<List<int>> adjacency,
) {
  for (final tiger in tigers) {
    if (BaghchalRules.tigerMoves(
      board: board,
      adjacency: adjacency,
      from: tiger,
    ).isNotEmpty) {
      return true;
    }
  }
  return false;
}

class _TestState {
  final List<int> board;
  final List<int> tigers;

  const _TestState(this.board, this.tigers);
}
