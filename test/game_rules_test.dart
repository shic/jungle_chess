// Regression coverage for capture hierarchy and end-of-game rule evaluation.

import 'package:flutter_test/flutter_test.dart';
import 'package:jungle_chess/game_rules.dart';

void main() {
  group('capture rules', () {
    test('rat can capture elephant, but elephant cannot capture rat', () {
      final redRat = piece(PieceSide.red, 1);
      final blueElephant = piece(PieceSide.blue, 8);

      expect(
        JungleGameRules.canCapture(attacker: redRat, defender: blueElephant),
        isTrue,
      );
      expect(
        JungleGameRules.canCapture(attacker: blueElephant, defender: redRat),
        isFalse,
      );
    });

    test('same-side pieces and lower ranks cannot be captured', () {
      expect(
        JungleGameRules.canCapture(
          attacker: piece(PieceSide.red, 4),
          defender: piece(PieceSide.red, 3),
        ),
        isFalse,
      );
      expect(
        JungleGameRules.canCapture(
          attacker: piece(PieceSide.red, 3),
          defender: piece(PieceSide.blue, 4),
        ),
        isFalse,
      );
      expect(
        JungleGameRules.canCapture(
          attacker: piece(PieceSide.red, 4),
          defender: piece(PieceSide.blue, 4),
        ),
        isTrue,
      );
    });
  });

  group('win condition', () {
    test('last equal-rank mutual elimination is a draw, not a blue win', () {
      final outcome = JungleGameRules.evaluateAfterTurn(
        board: emptyBoard(),
        actor: PieceSide.red,
      );

      expect(outcome.isDraw, isTrue);
      expect(outcome.winner, isNull);
      expect(outcome.reason, GameEndReason.mutualElimination);
    });

    test('the only side with remaining pieces wins by elimination', () {
      final board = emptyBoard()..[1][1] = piece(PieceSide.red, 3);

      final outcome = JungleGameRules.evaluateAfterTurn(
        board: board,
        actor: PieceSide.blue,
      );

      expect(outcome.isDraw, isFalse);
      expect(outcome.winner, PieceSide.red);
      expect(outcome.reason, GameEndReason.elimination);
    });

    test('actor wins when the next player has no legal action', () {
      final outcome = JungleGameRules.evaluateAfterTurn(
        board: fullAlternatingBoard(redRank: 8, blueRank: 2),
        actor: PieceSide.red,
      );

      expect(outcome.isDraw, isFalse);
      expect(outcome.winner, PieceSide.red);
      expect(outcome.reason, GameEndReason.noLegalAction);
    });

    test('hidden pieces keep the game alive because either side can flip', () {
      final board = fullAlternatingBoard(redRank: 8, blueRank: 2)
        ..[0][0] = piece(PieceSide.red, 8, revealed: false);

      final outcome = JungleGameRules.evaluateAfterTurn(
        board: board,
        actor: PieceSide.red,
      );

      expect(outcome.isFinished, isFalse);
    });

    test('consecutive non-captures draw at the configured limit', () {
      final outcome = JungleGameRules.evaluateAfterTurn(
        board: openBoardWithMoves(),
        actor: PieceSide.red,
        consecutiveNonCaptureTurns: JungleGameRules.nonCaptureDrawLimit,
      );

      expect(outcome.isDraw, isTrue);
      expect(outcome.winner, isNull);
      expect(outcome.reason, GameEndReason.nonCaptureLimit);
    });

    test('one non-capture before the limit does not draw', () {
      final outcome = JungleGameRules.evaluateAfterTurn(
        board: openBoardWithMoves(),
        actor: PieceSide.red,
        consecutiveNonCaptureTurns: JungleGameRules.nonCaptureDrawLimit - 1,
      );

      expect(outcome.isFinished, isFalse);
    });
  });
}

GamePiece piece(PieceSide side, int rank, {bool revealed = true}) {
  return GamePiece(side: side, rank: rank, revealed: revealed);
}

GameBoard emptyBoard() {
  return List<GamePiece?>.generate(
    JungleGameRules.boardSize * JungleGameRules.boardSize,
    (_) => null,
  ).chunkedBoard();
}

GameBoard fullAlternatingBoard({required int redRank, required int blueRank}) {
  return List<GamePiece?>.generate(
    JungleGameRules.boardSize * JungleGameRules.boardSize,
    (index) {
      final row = index ~/ JungleGameRules.boardSize;
      final col = index % JungleGameRules.boardSize;
      final side = (row + col).isEven ? PieceSide.red : PieceSide.blue;
      final rank = side == PieceSide.red ? redRank : blueRank;
      return piece(side, rank);
    },
  ).chunkedBoard();
}

GameBoard openBoardWithMoves() {
  return emptyBoard()
    ..[0][0] = piece(PieceSide.red, 3)
    ..[3][3] = piece(PieceSide.blue, 3);
}

extension on List<GamePiece?> {
  GameBoard chunkedBoard() {
    return <List<GamePiece?>>[
      for (var row = 0; row < JungleGameRules.boardSize; row++)
        sublist(
          row * JungleGameRules.boardSize,
          (row + 1) * JungleGameRules.boardSize,
        ),
    ];
  }
}
