// Centralizes the board model and win/draw rules so UI and tests share one source of truth.

enum PieceSide { red, blue }

class GamePiece {
  const GamePiece({
    required this.side,
    required this.rank,
    this.revealed = false,
  });

  final PieceSide side;
  final int rank;
  final bool revealed;

  GamePiece copyWith({PieceSide? side, int? rank, bool? revealed}) {
    return GamePiece(
      side: side ?? this.side,
      rank: rank ?? this.rank,
      revealed: revealed ?? this.revealed,
    );
  }
}

class BoardPosition {
  const BoardPosition(this.row, this.col);

  final int row;
  final int col;

  bool isAdjacentTo(BoardPosition other) {
    final rowDistance = (row - other.row).abs();
    final colDistance = (col - other.col).abs();
    return rowDistance + colDistance == 1;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BoardPosition && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}

typedef GameBoard = List<List<GamePiece?>>;

enum GameEndReason {
  elimination,
  mutualElimination,
  nonCaptureLimit,
  noLegalAction,
  noLegalActions,
}

class GameOutcome {
  const GameOutcome.ongoing() : winner = null, isDraw = false, reason = null;

  const GameOutcome.win(PieceSide this.winner, this.reason) : isDraw = false;

  const GameOutcome.draw(this.reason) : winner = null, isDraw = true;

  final PieceSide? winner;
  final bool isDraw;
  final GameEndReason? reason;

  bool get isFinished => winner != null || isDraw;
}

class JungleGameRules {
  const JungleGameRules._();

  static const int boardSize = 4;
  static const int nonCaptureDrawLimit = 30;
  static const Map<int, String> animalNames = <int, String>{
    1: '鼠',
    2: '猫',
    3: '狗',
    4: '狼',
    5: '豹',
    6: '虎',
    7: '狮',
    8: '象',
  };

  static PieceSide opposite(PieceSide side) {
    return side == PieceSide.red ? PieceSide.blue : PieceSide.red;
  }

  static bool canCapture({
    required GamePiece attacker,
    required GamePiece defender,
  }) {
    if (attacker.side == defender.side) {
      return false;
    }
    if (attacker.rank == 1 && defender.rank == 8) {
      return true;
    }
    if (attacker.rank == 8 && defender.rank == 1) {
      return false;
    }
    return attacker.rank >= defender.rank;
  }

  static GameOutcome evaluateAfterTurn({
    required GameBoard board,
    required PieceSide actor,
    int consecutiveNonCaptureTurns = 0,
  }) {
    final materialOutcome = evaluateMaterial(board);
    if (materialOutcome.isFinished) {
      return materialOutcome;
    }

    if (consecutiveNonCaptureTurns >= nonCaptureDrawLimit) {
      return const GameOutcome.draw(GameEndReason.nonCaptureLimit);
    }

    final nextTurn = opposite(actor);
    final actorCanAct = sideHasAction(board, actor);
    final nextPlayerCanAct = sideHasAction(board, nextTurn);

    if (!nextPlayerCanAct && !actorCanAct) {
      return const GameOutcome.draw(GameEndReason.noLegalActions);
    }
    if (!nextPlayerCanAct) {
      return GameOutcome.win(actor, GameEndReason.noLegalAction);
    }

    return const GameOutcome.ongoing();
  }

  static GameOutcome evaluateMaterial(GameBoard board) {
    final redCount = remainingCount(board, PieceSide.red);
    final blueCount = remainingCount(board, PieceSide.blue);

    if (redCount == 0 && blueCount == 0) {
      return const GameOutcome.draw(GameEndReason.mutualElimination);
    }
    if (redCount == 0) {
      return const GameOutcome.win(PieceSide.blue, GameEndReason.elimination);
    }
    if (blueCount == 0) {
      return const GameOutcome.win(PieceSide.red, GameEndReason.elimination);
    }
    return const GameOutcome.ongoing();
  }

  static bool sideHasAction(GameBoard board, PieceSide side) {
    if (remainingCount(board, side) == 0) {
      return false;
    }
    if (hasHiddenPieces(board)) {
      return true;
    }

    for (var row = 0; row < boardSize; row++) {
      for (var col = 0; col < boardSize; col++) {
        final piece = board[row][col];
        if (piece == null || !piece.revealed || piece.side != side) {
          continue;
        }

        final from = BoardPosition(row, col);
        for (final target in adjacentPositions(from)) {
          final other = board[target.row][target.col];
          if (other == null) {
            return true;
          }
          if (other.revealed && canCapture(attacker: piece, defender: other)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  static bool hasHiddenPieces(GameBoard board) {
    for (final row in board) {
      for (final piece in row) {
        if (piece != null && !piece.revealed) {
          return true;
        }
      }
    }
    return false;
  }

  static List<BoardPosition> adjacentPositions(BoardPosition position) {
    final candidates = <BoardPosition>[
      BoardPosition(position.row - 1, position.col),
      BoardPosition(position.row + 1, position.col),
      BoardPosition(position.row, position.col - 1),
      BoardPosition(position.row, position.col + 1),
    ];

    return candidates
        .where(
          (item) =>
              item.row >= 0 &&
              item.row < boardSize &&
              item.col >= 0 &&
              item.col < boardSize,
        )
        .toList();
  }

  static int remainingCount(GameBoard board, PieceSide side) {
    var count = 0;
    for (final row in board) {
      for (final piece in row) {
        if (piece?.side == side) {
          count++;
        }
      }
    }
    return count;
  }
}
