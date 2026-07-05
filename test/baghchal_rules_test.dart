import 'package:baghchal_app/baghchal_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<List<int>> adjacency;

  setUp(() {
    adjacency = BaghchalRules.buildAdjacency();
  });

  test('builds only adjacent board-line edges', () {
    expect(adjacency[0], unorderedEquals([1, 5, 6]));
    expect(adjacency[12], unorderedEquals([6, 7, 8, 11, 13, 16, 17, 18]));

    expect(adjacency[0], isNot(contains(12)));
    expect(adjacency[4], isNot(contains(12)));
    expect(adjacency[20], isNot(contains(12)));
    expect(adjacency[24], isNot(contains(12)));
  });

  test('tiger captures along a straight drawn line only', () {
    final board = List<int>.filled(
      BaghchalRules.boardSize,
      BaghchalRules.empty,
    );
    board[0] = BaghchalRules.tiger;
    board[6] = BaghchalRules.goat;

    final moves = BaghchalRules.tigerMoves(
      board: board,
      adjacency: adjacency,
      from: 0,
    );

    expect(
      moves,
      contains(
        allOf(
          containsPair('to', 12),
          containsPair('capture', 6),
          containsPair('type', 'capture'),
        ),
      ),
    );
  });

  test('tiger cannot capture across an undrawn diagonal', () {
    final board = List<int>.filled(
      BaghchalRules.boardSize,
      BaghchalRules.empty,
    );
    board[0] = BaghchalRules.tiger;
    board[7] = BaghchalRules.goat;

    final moves = BaghchalRules.tigerMoves(
      board: board,
      adjacency: adjacency,
      from: 0,
    );

    expect(
      moves,
      isNot(
        contains(
          allOf(
            containsPair('to', 14),
            containsPair('capture', 7),
          ),
        ),
      ),
    );
  });

  test('all tigers are trapped in late placement position', () {
    final board = List<int>.filled(
      BaghchalRules.boardSize,
      BaghchalRules.goat,
    );
    board[1] = BaghchalRules.empty;
    board[5] = BaghchalRules.empty;
    const tigers = [13, 17, 18, 19];
    for (final tiger in tigers) {
      board[tiger] = BaghchalRules.tiger;
    }

    for (final tiger in tigers) {
      expect(
        BaghchalRules.tigerMoves(
          board: board,
          adjacency: adjacency,
          from: tiger,
        ),
        isEmpty,
      );
    }
  });
}
