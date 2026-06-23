// Regression coverage for capture hierarchy and end-of-game rule evaluation.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jungle_chess/game_ai.dart';
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

  group('game actions', () {
    test('unassigned opening can only flip hidden pieces', () {
      final board = emptyBoard()
        ..[0][0] = piece(PieceSide.red, 8, revealed: false)
        ..[0][1] = piece(PieceSide.blue, 2, revealed: false)
        ..[1][1] = piece(PieceSide.red, 3);

      final actions = JungleGameRules.legalActionsFor(
        board: board,
        currentTurn: PieceSide.red,
      );

      expect(
        actions,
        unorderedEquals(<GameAction>[
          const GameAction.flip(BoardPosition(0, 0)),
          const GameAction.flip(BoardPosition(0, 1)),
        ]),
      );
    });

    test('assigned turns include flips, empty moves, and legal captures', () {
      final board = emptyBoard()
        ..[1][1] = piece(PieceSide.red, 8)
        ..[1][2] = piece(PieceSide.blue, 2)
        ..[0][1] = piece(PieceSide.red, 3)
        ..[2][1] = piece(PieceSide.blue, 4, revealed: false);

      final actions = JungleGameRules.legalActionsFor(
        board: board,
        currentTurn: PieceSide.red,
        playerOneSide: PieceSide.red,
      );

      expect(actions, contains(const GameAction.flip(BoardPosition(2, 1))));
      expect(
        actions,
        contains(
          const GameAction.capture(
            from: BoardPosition(1, 1),
            to: BoardPosition(1, 2),
          ),
        ),
      );
      expect(
        actions,
        contains(
          const GameAction.move(
            from: BoardPosition(1, 1),
            to: BoardPosition(1, 0),
          ),
        ),
      );
      expect(
        actions,
        isNot(
          contains(
            const GameAction.move(
              from: BoardPosition(1, 1),
              to: BoardPosition(2, 1),
            ),
          ),
        ),
      );
      expect(
        actions,
        isNot(
          contains(
            const GameAction.capture(
              from: BoardPosition(1, 1),
              to: BoardPosition(0, 1),
            ),
          ),
        ),
      );
    });

    test('rat-elephant special rule is represented in legal actions', () {
      final board = emptyBoard()
        ..[0][0] = piece(PieceSide.red, 1)
        ..[0][1] = piece(PieceSide.blue, 8);

      final actions = JungleGameRules.legalActionsFor(
        board: board,
        currentTurn: PieceSide.red,
        playerOneSide: PieceSide.red,
      );

      expect(
        actions,
        contains(
          const GameAction.capture(
            from: BoardPosition(0, 0),
            to: BoardPosition(0, 1),
          ),
        ),
      );
    });

    test(
      'pure action simulation captures without mutating the source board',
      () {
        final board = emptyBoard()
          ..[0][0] = piece(PieceSide.red, 4)
          ..[0][1] = piece(PieceSide.blue, 4);

        final result = JungleGameRules.applyAction(
          board: board,
          action: const GameAction.capture(
            from: BoardPosition(0, 0),
            to: BoardPosition(0, 1),
          ),
          currentTurn: PieceSide.red,
          playerOneSide: PieceSide.red,
          consecutiveNonCaptureTurns: 7,
        );

        expect(result.captured, isTrue);
        expect(result.consecutiveNonCaptureTurns, 0);
        expect(result.board[0][0], isNull);
        expect(result.board[0][1], isNull);
        expect(board[0][0], isNotNull);
        expect(board[0][1], isNotNull);
      },
    );
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

  group('local AI', () {
    test('AI state does not bind hidden identities to hidden positions', () {
      final firstBoard = emptyBoard()
        ..[0][0] = piece(PieceSide.red, 8)
        ..[3][3] = piece(PieceSide.blue, 2)
        ..[0][1] = piece(PieceSide.red, 1, revealed: false)
        ..[1][0] = piece(PieceSide.blue, 7, revealed: false);
      final secondBoard = emptyBoard()
        ..[0][0] = piece(PieceSide.red, 8)
        ..[3][3] = piece(PieceSide.blue, 2)
        ..[0][1] = piece(PieceSide.blue, 7, revealed: false)
        ..[1][0] = piece(PieceSide.red, 1, revealed: false);

      final firstAction = JungleAi.chooseAction(
        state: AiGameState.fromBoard(
          board: firstBoard,
          currentTurn: PieceSide.blue,
          playerOneSide: PieceSide.red,
        ),
        difficulty: AiDifficulty.hard,
        random: Random(4),
      );
      final secondAction = JungleAi.chooseAction(
        state: AiGameState.fromBoard(
          board: secondBoard,
          currentTurn: PieceSide.blue,
          playerOneSide: PieceSide.red,
        ),
        difficulty: AiDifficulty.hard,
        random: Random(4),
      );

      expect(secondAction, firstAction);
    });

    test('easy AI only returns legal actions', () {
      final board = emptyBoard()
        ..[0][0] = piece(PieceSide.red, 8)
        ..[0][1] = piece(PieceSide.blue, 2)
        ..[1][0] = piece(PieceSide.blue, 5, revealed: false);
      final legalActions = JungleGameRules.legalActionsFor(
        board: board,
        currentTurn: PieceSide.red,
        playerOneSide: PieceSide.red,
      );

      for (var seed = 0; seed < 20; seed++) {
        final action = JungleAi.chooseAction(
          state: AiGameState.fromBoard(
            board: board,
            currentTurn: PieceSide.red,
            playerOneSide: PieceSide.red,
          ),
          difficulty: AiDifficulty.easy,
          random: Random(seed),
        );

        expect(legalActions, contains(action));
      }
    });

    test('normal AI chooses an immediate winning capture', () {
      final board = emptyBoard()
        ..[0][0] = piece(PieceSide.red, 8)
        ..[0][1] = piece(PieceSide.blue, 2);

      final action = JungleAi.chooseAction(
        state: AiGameState.fromBoard(
          board: board,
          currentTurn: PieceSide.red,
          playerOneSide: PieceSide.red,
        ),
        difficulty: AiDifficulty.normal,
        random: Random(1),
      );

      expect(
        action,
        const GameAction.capture(
          from: BoardPosition(0, 0),
          to: BoardPosition(0, 1),
        ),
      );
    });

    test('AI takes a safe adjacent capture before flipping', () {
      final hiddenPieces = <GamePiece>[
        piece(PieceSide.red, 1, revealed: false),
        piece(PieceSide.red, 2, revealed: false),
        piece(PieceSide.red, 3, revealed: false),
        piece(PieceSide.red, 4, revealed: false),
        piece(PieceSide.red, 5, revealed: false),
        piece(PieceSide.red, 6, revealed: false),
        piece(PieceSide.red, 8, revealed: false),
        piece(PieceSide.blue, 2, revealed: false),
        piece(PieceSide.blue, 3, revealed: false),
        piece(PieceSide.blue, 4, revealed: false),
        piece(PieceSide.blue, 5, revealed: false),
        piece(PieceSide.blue, 7, revealed: false),
        piece(PieceSide.blue, 8, revealed: false),
      ];
      var hiddenIndex = 0;
      final board = List<List<GamePiece?>>.generate(
        JungleGameRules.boardSize,
        (row) => List<GamePiece?>.generate(JungleGameRules.boardSize, (col) {
          final position = BoardPosition(row, col);
          if (position == const BoardPosition(0, 0)) {
            return piece(PieceSide.blue, 1);
          }
          if (position == const BoardPosition(2, 1)) {
            return piece(PieceSide.red, 7);
          }
          if (position == const BoardPosition(2, 2)) {
            return piece(PieceSide.blue, 6);
          }
          return hiddenPieces[hiddenIndex++];
        }),
      );

      for (final difficulty in AiDifficulty.values) {
        final action = JungleAi.chooseAction(
          state: AiGameState.fromBoard(
            board: board,
            currentTurn: PieceSide.red,
            playerOneSide: PieceSide.blue,
          ),
          difficulty: difficulty,
          random: Random(1),
        );

        expect(
          action,
          const GameAction.capture(
            from: BoardPosition(2, 1),
            to: BoardPosition(2, 2),
          ),
          reason: '${difficulty.name} should not flip while 7 can safely eat 6',
        );
      }
    });

    test('AI avoids a fourth repeated back-and-forth move', () {
      final board = emptyBoard()
        ..[1][2] = piece(PieceSide.blue, 7)
        ..[3][3] = piece(PieceSide.red, 8);
      const blockedRepeat = GameAction.move(
        from: BoardPosition(1, 2),
        to: BoardPosition(1, 1),
      );
      final legalActions = JungleGameRules.legalActionsFor(
        board: board,
        currentTurn: PieceSide.blue,
        playerOneSide: PieceSide.red,
      );

      final action = JungleAi.chooseAction(
        state: AiGameState.fromBoard(
          board: board,
          currentTurn: PieceSide.blue,
          playerOneSide: PieceSide.red,
        ),
        difficulty: AiDifficulty.normal,
        random: Random(1),
        recentActions: const <GameAction>[
          GameAction.move(from: BoardPosition(1, 1), to: BoardPosition(1, 2)),
          GameAction.move(from: BoardPosition(1, 2), to: BoardPosition(1, 1)),
          GameAction.move(from: BoardPosition(1, 1), to: BoardPosition(1, 2)),
        ],
      );

      expect(legalActions, contains(action));
      expect(action, isNot(blockedRepeat));
    });

    test('hard AI avoids moving a high piece next to a rat', () {
      final board = emptyBoard()
        ..[1][1] = piece(PieceSide.red, 8)
        ..[1][3] = piece(PieceSide.blue, 1)
        ..[3][3] = piece(PieceSide.blue, 3);

      final action = JungleAi.chooseAction(
        state: AiGameState.fromBoard(
          board: board,
          currentTurn: PieceSide.red,
          playerOneSide: PieceSide.red,
        ),
        difficulty: AiDifficulty.hard,
        random: Random(2),
      );

      expect(
        action,
        isNot(
          const GameAction.move(
            from: BoardPosition(1, 1),
            to: BoardPosition(1, 2),
          ),
        ),
      );
    });

    test('hard AI moves an elephant before an adjacent rat can take it', () {
      final board = emptyBoard()
        ..[0][0] = piece(PieceSide.red, 4, revealed: false)
        ..[1][1] = piece(PieceSide.red, 8)
        ..[1][2] = piece(PieceSide.blue, 1)
        ..[3][3] = piece(PieceSide.blue, 5, revealed: false);

      final action = JungleAi.chooseAction(
        state: AiGameState.fromBoard(
          board: board,
          currentTurn: PieceSide.red,
          playerOneSide: PieceSide.red,
        ),
        difficulty: AiDifficulty.hard,
        random: Random(7),
      );

      expect(action?.kind, GameActionKind.move);
      expect(action?.from, const BoardPosition(1, 1));
    });

    test('hard AI avoids a capture that lets a rat recapture elephant', () {
      final board = emptyBoard()
        ..[1][1] = piece(PieceSide.red, 8)
        ..[1][2] = piece(PieceSide.blue, 7)
        ..[1][3] = piece(PieceSide.blue, 1)
        ..[3][0] = piece(PieceSide.red, 2);

      final action = JungleAi.chooseAction(
        state: AiGameState.fromBoard(
          board: board,
          currentTurn: PieceSide.red,
          playerOneSide: PieceSide.red,
        ),
        difficulty: AiDifficulty.hard,
        random: Random(3),
      );

      expect(
        action,
        isNot(
          const GameAction.capture(
            from: BoardPosition(1, 1),
            to: BoardPosition(1, 2),
          ),
        ),
      );
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
