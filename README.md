# Baghchal

A Flutter implementation of Bagh Chal, the traditional Tigers and Goats
strategy game from Nepal.

## Current Rules

- 4 tigers start on the board corners.
- 20 goats are placed one at a time; goats cannot move until all are placed.
- Tigers can move or capture during both phases.
- Pieces move only along drawn adjacent board lines.
- Tigers capture by jumping over exactly one adjacent goat to the empty point
  immediately beyond it on the same line.
- Tigers win after capturing 5 goats.
- Goats win when all tigers have no legal moves.
- After all goats are placed, moves that recreate a previous board position are
  rejected to prevent loops.

## Development

```sh
flutter pub get
flutter test
flutter run
```

The core board graph and move generation live in `lib/baghchal_rules.dart` and
are covered by focused tests in `test/baghchal_rules_test.dart`.
