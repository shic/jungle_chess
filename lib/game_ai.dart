// Local computer player for Animal Kings. It only receives visible board state.

import 'dart:math';

import 'package:jungle_chess/game_rules.dart';

enum AiDifficulty { easy, normal, hard }

class AiGameState {
  AiGameState({
    required GameBoard visibleBoard,
    required List<BoardPosition> hiddenPositions,
    required List<GamePiece> hiddenPool,
    required this.currentTurn,
    required this.playerOneSide,
    required this.consecutiveNonCaptureTurns,
  }) : visibleBoard = JungleGameRules.copyBoard(visibleBoard),
       hiddenPositions = List<BoardPosition>.unmodifiable(hiddenPositions),
       hiddenPool = List<GamePiece>.unmodifiable(_sortedPool(hiddenPool));

  factory AiGameState.fromBoard({
    required GameBoard board,
    required PieceSide currentTurn,
    required PieceSide? playerOneSide,
    int consecutiveNonCaptureTurns = 0,
  }) {
    final visibleBoard = List<List<GamePiece?>>.generate(
      JungleGameRules.boardSize,
      (_) => List<GamePiece?>.filled(JungleGameRules.boardSize, null),
    );
    final hiddenPositions = <BoardPosition>[];
    final hiddenPool = <GamePiece>[];

    for (var row = 0; row < JungleGameRules.boardSize; row++) {
      for (var col = 0; col < JungleGameRules.boardSize; col++) {
        final piece = board[row][col];
        if (piece == null) {
          continue;
        }
        if (piece.revealed) {
          visibleBoard[row][col] = piece;
        } else {
          hiddenPositions.add(BoardPosition(row, col));
          hiddenPool.add(piece);
        }
      }
    }

    return AiGameState(
      visibleBoard: visibleBoard,
      hiddenPositions: hiddenPositions,
      hiddenPool: hiddenPool,
      currentTurn: currentTurn,
      playerOneSide: playerOneSide,
      consecutiveNonCaptureTurns: consecutiveNonCaptureTurns,
    );
  }

  final GameBoard visibleBoard;
  final List<BoardPosition> hiddenPositions;
  final List<GamePiece> hiddenPool;
  final PieceSide currentTurn;
  final PieceSide? playerOneSide;
  final int consecutiveNonCaptureTurns;

  static List<GamePiece> _sortedPool(List<GamePiece> pieces) {
    return <GamePiece>[...pieces]..sort((a, b) {
      final sideComparison = a.side.index.compareTo(b.side.index);
      if (sideComparison != 0) {
        return sideComparison;
      }
      return a.rank.compareTo(b.rank);
    });
  }
}

class JungleAi {
  const JungleAi._();

  static const int repeatMoveLimit = 3;
  static const int _hardDepth = 3;
  static const int _hardNodeLimit = 650;

  static GameAction? chooseAction({
    required AiGameState state,
    required AiDifficulty difficulty,
    Random? random,
    Iterable<GameAction> recentActions = const <GameAction>[],
  }) {
    final legalActions = _legalActions(state);
    final actions = _actionsAvoidingRepeat(legalActions, recentActions);
    if (actions.isEmpty) {
      return null;
    }

    final rng = random ?? Random();
    return switch (difficulty) {
      AiDifficulty.easy => _chooseEasy(actions, rng),
      AiDifficulty.normal => _chooseBest(
        actions: actions,
        random: rng,
        score: (action) => _scoreImmediate(state, action, state.currentTurn),
      ),
      AiDifficulty.hard => _chooseBest(
        actions: actions,
        random: rng,
        score: (action) => _expectedActionValue(
          state,
          action,
          state.currentTurn,
          _hardDepth,
          _SearchBudget(_hardNodeLimit),
        ),
      ),
    };
  }

  static List<GameAction> _actionsAvoidingRepeat(
    List<GameAction> actions,
    Iterable<GameAction> recentActions,
  ) {
    final repeatedEdge = _repeatedMoveEdge(recentActions);
    if (repeatedEdge == null) {
      return actions;
    }

    final filtered = <GameAction>[
      for (final action in actions)
        if (!_isMoveOnEdge(action, repeatedEdge)) action,
    ];
    return filtered.isEmpty ? actions : filtered;
  }

  static _MoveEdge? _repeatedMoveEdge(Iterable<GameAction> recentActions) {
    final tailMoves = <GameAction>[];
    for (final action in recentActions.toList().reversed) {
      if (action.kind != GameActionKind.move || action.from == null) {
        break;
      }
      tailMoves.add(action);
      if (tailMoves.length == repeatMoveLimit) {
        break;
      }
    }

    if (tailMoves.length < repeatMoveLimit) {
      return null;
    }

    final edge = _MoveEdge.from(tailMoves.first);
    for (final action in tailMoves.skip(1)) {
      if (_MoveEdge.from(action) != edge) {
        return null;
      }
    }
    return edge;
  }

  static bool _isMoveOnEdge(GameAction action, _MoveEdge edge) {
    if (action.kind != GameActionKind.move || action.from == null) {
      return false;
    }
    return _MoveEdge.from(action) == edge;
  }

  static List<GameAction> _legalActions(AiGameState state) {
    final actions = <GameAction>[
      for (final position in state.hiddenPositions) GameAction.flip(position),
    ];

    if (state.playerOneSide == null) {
      return actions;
    }

    for (var row = 0; row < JungleGameRules.boardSize; row++) {
      for (var col = 0; col < JungleGameRules.boardSize; col++) {
        final piece = state.visibleBoard[row][col];
        if (piece == null || piece.side != state.currentTurn) {
          continue;
        }
        final from = BoardPosition(row, col);
        for (final to in JungleGameRules.adjacentPositions(from)) {
          if (state.hiddenPositions.contains(to)) {
            continue;
          }
          final target = state.visibleBoard[to.row][to.col];
          if (target == null) {
            actions.add(GameAction.move(from: from, to: to));
            continue;
          }
          if (JungleGameRules.canCapture(attacker: piece, defender: target)) {
            actions.add(GameAction.capture(from: from, to: to));
          }
        }
      }
    }

    return actions;
  }

  static GameAction _chooseEasy(List<GameAction> actions, Random random) {
    final weighted = <GameAction>[];
    for (final action in actions) {
      final weight = switch (action.kind) {
        GameActionKind.capture => 4,
        GameActionKind.flip => 2,
        GameActionKind.move => 1,
      };
      for (var i = 0; i < weight; i++) {
        weighted.add(action);
      }
    }
    return weighted[random.nextInt(weighted.length)];
  }

  static GameAction _chooseBest({
    required List<GameAction> actions,
    required Random random,
    required double Function(GameAction action) score,
  }) {
    var bestScore = double.negativeInfinity;
    final bestActions = <GameAction>[];
    for (final action in actions) {
      final value = score(action);
      if (value > bestScore + 0.0001) {
        bestScore = value;
        bestActions
          ..clear()
          ..add(action);
        continue;
      }
      if ((value - bestScore).abs() <= 0.0001) {
        bestActions.add(action);
      }
    }
    return bestActions[random.nextInt(bestActions.length)];
  }

  static double _expectedActionValue(
    AiGameState state,
    GameAction action,
    PieceSide rootSide,
    int depth,
    _SearchBudget budget,
  ) {
    if (!budget.take()) {
      return _evaluate(state, rootSide);
    }

    if (action.kind == GameActionKind.flip) {
      return _expectedFlipValue(state, action, rootSide, depth, budget);
    }

    final next = _applyKnownAction(state, action);
    return _search(next, rootSide, depth - 1, budget);
  }

  static double _search(
    AiGameState state,
    PieceSide rootSide,
    int depth,
    _SearchBudget budget,
  ) {
    if (!budget.take() || depth <= 0) {
      return _evaluate(state, rootSide);
    }

    final terminalScore = _terminalScore(state, rootSide);
    if (terminalScore != null) {
      return terminalScore;
    }

    final actions = _legalActions(state);
    if (actions.isEmpty) {
      return state.currentTurn == rootSide ? -9000 : 9000;
    }

    final ordered = <GameAction>[...actions]
      ..sort((a, b) {
        final aScore = _scoreImmediate(state, a, state.currentTurn);
        final bScore = _scoreImmediate(state, b, state.currentTurn);
        return bScore.compareTo(aScore);
      });
    final candidates = ordered.take(12);

    if (state.currentTurn == rootSide) {
      var best = double.negativeInfinity;
      for (final action in candidates) {
        best = max(
          best,
          _expectedActionValue(state, action, rootSide, depth, budget),
        );
      }
      return best;
    }

    var worst = double.infinity;
    for (final action in candidates) {
      worst = min(
        worst,
        _expectedActionValue(state, action, rootSide, depth, budget),
      );
    }
    return worst;
  }

  static double _expectedFlipValue(
    AiGameState state,
    GameAction action,
    PieceSide rootSide,
    int depth,
    _SearchBudget budget,
  ) {
    if (state.hiddenPool.isEmpty) {
      return _evaluate(state, rootSide);
    }

    var totalWeight = 0;
    var totalScore = 0.0;
    for (final entry in _uniqueHiddenPieces(state.hiddenPool).entries) {
      final piece = entry.key;
      final count = entry.value;
      final next = _applyHypotheticalFlip(state, action.to, piece);
      final value = depth <= 1
          ? _evaluate(next, rootSide)
          : _search(next, rootSide, depth - 1, budget);
      totalWeight += count;
      totalScore += value * count;
      if (budget.exhausted) {
        break;
      }
    }

    if (totalWeight == 0) {
      return _evaluate(state, rootSide);
    }
    return totalScore / totalWeight + _flipPositionScore(state, action.to);
  }

  static AiGameState _applyKnownAction(AiGameState state, GameAction action) {
    final board = JungleGameRules.copyBoard(state.visibleBoard);
    var captured = false;

    switch (action.kind) {
      case GameActionKind.flip:
        throw ArgumentError.value(action, 'action', 'Use flip expectation.');
      case GameActionKind.move:
        final from = action.from!;
        final attacker = board[from.row][from.col]!;
        board[action.to.row][action.to.col] = attacker;
        board[from.row][from.col] = null;
      case GameActionKind.capture:
        final from = action.from!;
        final attacker = board[from.row][from.col]!;
        final defender = board[action.to.row][action.to.col]!;
        captured = true;
        board[from.row][from.col] = null;
        board[action.to.row][action.to.col] = attacker.rank == defender.rank
            ? null
            : attacker;
    }

    return AiGameState(
      visibleBoard: board,
      hiddenPositions: state.hiddenPositions,
      hiddenPool: state.hiddenPool,
      currentTurn: JungleGameRules.opposite(state.currentTurn),
      playerOneSide: state.playerOneSide,
      consecutiveNonCaptureTurns: captured
          ? 0
          : state.consecutiveNonCaptureTurns + 1,
    );
  }

  static AiGameState _applyHypotheticalFlip(
    AiGameState state,
    BoardPosition position,
    GamePiece piece,
  ) {
    final board = JungleGameRules.copyBoard(state.visibleBoard);
    board[position.row][position.col] = piece.copyWith(revealed: true);
    final hiddenPositions = <BoardPosition>[
      for (final hidden in state.hiddenPositions)
        if (hidden != position) hidden,
    ];
    final hiddenPool = <GamePiece>[...state.hiddenPool];
    final removeIndex = hiddenPool.indexWhere(
      (item) => item.side == piece.side && item.rank == piece.rank,
    );
    if (removeIndex >= 0) {
      hiddenPool.removeAt(removeIndex);
    }

    final actor = state.playerOneSide == null ? piece.side : state.currentTurn;
    return AiGameState(
      visibleBoard: board,
      hiddenPositions: hiddenPositions,
      hiddenPool: hiddenPool,
      currentTurn: JungleGameRules.opposite(actor),
      playerOneSide: state.playerOneSide ?? piece.side,
      consecutiveNonCaptureTurns: state.consecutiveNonCaptureTurns + 1,
    );
  }

  static double _scoreImmediate(
    AiGameState state,
    GameAction action,
    PieceSide side,
  ) {
    final terminal = _terminalScoreAfter(state, action, side);
    if (terminal != null) {
      return terminal;
    }

    var score = 0.0;
    switch (action.kind) {
      case GameActionKind.flip:
        score += 4 + _expectedHiddenSwing(state, side);
        score += _flipPositionScore(state, action.to);
      case GameActionKind.move:
        final from = action.from!;
        final piece = state.visibleBoard[from.row][from.col]!;
        score += _centerScore(action.to) - _centerScore(from);
        score += piece.rank * 0.2;
        score -= _exposurePenalty(_applyKnownAction(state, action), side);
      case GameActionKind.capture:
        final from = action.from!;
        final attacker = state.visibleBoard[from.row][from.col]!;
        final defender = state.visibleBoard[action.to.row][action.to.col]!;
        score += _pieceValue(defender) * 7;
        if (attacker.rank == defender.rank) {
          score -= _pieceValue(attacker) * 3;
        }
        score -= _exposurePenalty(_applyKnownAction(state, action), side);
    }
    return score + _evaluate(state, side) * 0.05;
  }

  static double? _terminalScoreAfter(
    AiGameState state,
    GameAction action,
    PieceSide side,
  ) {
    if (action.kind == GameActionKind.flip) {
      return null;
    }
    final next = _applyKnownAction(state, action);
    return _terminalScore(next, side);
  }

  static double? _terminalScore(AiGameState state, PieceSide rootSide) {
    final opponent = JungleGameRules.opposite(rootSide);
    if (_potentialCount(state, rootSide) == 0) {
      return -10000;
    }
    if (_potentialCount(state, opponent) == 0) {
      return 10000;
    }
    if (state.consecutiveNonCaptureTurns >=
        JungleGameRules.nonCaptureDrawLimit) {
      return 0;
    }
    return null;
  }

  static double _evaluate(AiGameState state, PieceSide rootSide) {
    final terminal = _terminalScore(state, rootSide);
    if (terminal != null) {
      return terminal;
    }

    final opponent = JungleGameRules.opposite(rootSide);
    var score = 0.0;
    for (final row in state.visibleBoard) {
      for (final piece in row) {
        if (piece == null) {
          continue;
        }
        final value = _pieceValue(piece);
        score += piece.side == rootSide ? value : -value;
      }
    }

    for (final piece in state.hiddenPool) {
      final value = _pieceValue(piece) * 0.35;
      score += piece.side == rootSide ? value : -value;
    }

    score += _mobility(state, rootSide) * 1.4;
    score -= _mobility(state, opponent) * 1.4;
    score -= _exposurePenalty(state, rootSide);
    score += _exposurePenalty(state, opponent) * 0.6;
    return score;
  }

  static int _potentialCount(AiGameState state, PieceSide side) {
    var count = 0;
    for (final row in state.visibleBoard) {
      for (final piece in row) {
        if (piece?.side == side) {
          count++;
        }
      }
    }
    for (final piece in state.hiddenPool) {
      if (piece.side == side) {
        count++;
      }
    }
    return count;
  }

  static int _mobility(AiGameState state, PieceSide side) {
    return _legalActions(
      AiGameState(
        visibleBoard: state.visibleBoard,
        hiddenPositions: state.hiddenPositions,
        hiddenPool: state.hiddenPool,
        currentTurn: side,
        playerOneSide: state.playerOneSide,
        consecutiveNonCaptureTurns: state.consecutiveNonCaptureTurns,
      ),
    ).length;
  }

  static double _exposurePenalty(AiGameState state, PieceSide side) {
    var penalty = 0.0;
    for (var row = 0; row < JungleGameRules.boardSize; row++) {
      for (var col = 0; col < JungleGameRules.boardSize; col++) {
        final piece = state.visibleBoard[row][col];
        if (piece == null || piece.side != side) {
          continue;
        }
        final from = BoardPosition(row, col);
        for (final to in JungleGameRules.adjacentPositions(from)) {
          final attacker = state.visibleBoard[to.row][to.col];
          if (attacker == null || attacker.side == side) {
            continue;
          }
          if (JungleGameRules.canCapture(attacker: attacker, defender: piece)) {
            penalty += _pieceValue(piece) * 1.25;
          }
        }
      }
    }
    return penalty;
  }

  static double _expectedHiddenSwing(AiGameState state, PieceSide side) {
    if (state.hiddenPool.isEmpty) {
      return 0;
    }
    var total = 0.0;
    for (final piece in state.hiddenPool) {
      final value = _pieceValue(piece);
      total += piece.side == side ? value : -value;
    }
    return total / state.hiddenPool.length;
  }

  static double _flipPositionScore(AiGameState state, BoardPosition position) {
    var score = _centerScore(position) * 0.4;
    for (final adjacent in JungleGameRules.adjacentPositions(position)) {
      final piece = state.visibleBoard[adjacent.row][adjacent.col];
      if (piece == null) {
        continue;
      }
      score += piece.side == state.currentTurn ? 0.6 : -0.2;
    }
    return score;
  }

  static double _centerScore(BoardPosition position) {
    final rowDistance = (position.row - 1.5).abs();
    final colDistance = (position.col - 1.5).abs();
    return 3 - rowDistance - colDistance;
  }

  static double _pieceValue(GamePiece piece) {
    return switch (piece.rank) {
      1 => 18,
      8 => 70,
      _ => piece.rank * 9.0,
    };
  }

  static Map<GamePiece, int> _uniqueHiddenPieces(List<GamePiece> hiddenPool) {
    final entries = <_PieceKey, int>{};
    for (final piece in hiddenPool) {
      entries.update(
        _PieceKey(piece.side, piece.rank),
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return <GamePiece, int>{
      for (final entry in entries.entries)
        GamePiece(side: entry.key.side, rank: entry.key.rank): entry.value,
    };
  }
}

class _MoveEdge {
  const _MoveEdge(this.first, this.second);

  factory _MoveEdge.from(GameAction action) {
    final from = action.from!;
    final to = action.to;
    if (_comparePositions(from, to) <= 0) {
      return _MoveEdge(from, to);
    }
    return _MoveEdge(to, from);
  }

  final BoardPosition first;
  final BoardPosition second;

  static int _comparePositions(BoardPosition a, BoardPosition b) {
    final rowComparison = a.row.compareTo(b.row);
    if (rowComparison != 0) {
      return rowComparison;
    }
    return a.col.compareTo(b.col);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _MoveEdge && other.first == first && other.second == second;
  }

  @override
  int get hashCode => Object.hash(first, second);
}

class _SearchBudget {
  _SearchBudget(this.remaining);

  int remaining;

  bool get exhausted => remaining <= 0;

  bool take() {
    if (remaining <= 0) {
      return false;
    }
    remaining--;
    return true;
  }
}

class _PieceKey {
  const _PieceKey(this.side, this.rank);

  final PieceSide side;
  final int rank;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _PieceKey && other.side == side && other.rank == rank;
  }

  @override
  int get hashCode => Object.hash(side, rank);
}
