import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const JungleChessApp());
}

class JungleChessApp extends StatelessWidget {
  const JungleChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '斗兽棋',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB3541E),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F0E3),
        useMaterial3: true,
      ),
      home: const JungleChessPage(),
    );
  }
}

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

  GamePiece copyWith({
    PieceSide? side,
    int? rank,
    bool? revealed,
  }) {
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

class JungleChessPage extends StatefulWidget {
  const JungleChessPage({super.key});

  @override
  State<JungleChessPage> createState() => _JungleChessPageState();
}

class _JungleChessPageState extends State<JungleChessPage> {
  static const int boardSize = 4;
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

  final Random _random = Random();
  late List<List<GamePiece?>> _board;
  PieceSide _currentTurn = PieceSide.red;
  BoardPosition? _selected;
  String _statusMessage = '';
  PieceSide? _winner;
  bool _isDraw = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    final pieces = <GamePiece>[
      for (final side in PieceSide.values)
        for (var rank = 1; rank <= 8; rank++) GamePiece(side: side, rank: rank),
    ]..shuffle(_random);

    _board = List<List<GamePiece?>>.generate(
      boardSize,
      (row) => List<GamePiece?>.generate(
        boardSize,
        (col) => pieces[row * boardSize + col],
      ),
    );

    setState(() {
      _currentTurn = PieceSide.red;
      _selected = null;
      _winner = null;
      _isDraw = false;
      _statusMessage = '红方先手：每回合可以翻一张牌，或者移动一枚自己的棋子。';
    });
  }

  void _onCellTapped(BoardPosition position) {
    if (_winner != null || _isDraw) {
      return;
    }

    final piece = _board[position.row][position.col];

    if (_selected == position) {
      setState(() {
        _selected = null;
        _statusMessage = '已取消选中，可以重新选择翻牌或走棋。';
      });
      return;
    }

    if (piece != null &&
        piece.revealed &&
        piece.side == _currentTurn) {
      setState(() {
        _selected = position;
        _statusMessage = '${_sideLabel(_currentTurn)}方已选中 ${_pieceLabel(piece)}。';
      });
      return;
    }

    if (piece != null && !piece.revealed) {
      _flipPiece(position, piece);
      return;
    }

    final selected = _selected;
    if (selected == null) {
      setState(() {
        _statusMessage = '请先翻一张暗棋，或者选中自己的棋子再走一步。';
      });
      return;
    }

    final movingPiece = _board[selected.row][selected.col];
    if (movingPiece == null) {
      setState(() {
        _selected = null;
        _statusMessage = '选中的棋子不存在了，请重新操作。';
      });
      return;
    }

    _tryMoveOrCapture(
      from: selected,
      to: position,
      attacker: movingPiece,
      defender: piece,
    );
  }

  void _flipPiece(BoardPosition position, GamePiece piece) {
    setState(() {
      _board[position.row][position.col] = piece.copyWith(revealed: true);
      _selected = null;
      _statusMessage =
          '${_sideLabel(_currentTurn)}方翻开了 ${_sideLabel(piece.side)}方 ${_pieceLabel(piece)}。';
    });
    _finishTurn();
  }

  void _tryMoveOrCapture({
    required BoardPosition from,
    required BoardPosition to,
    required GamePiece attacker,
    required GamePiece? defender,
  }) {
    if (!from.isAdjacentTo(to)) {
      setState(() {
        _statusMessage = '每次只能上下左右移动一步。';
      });
      return;
    }

    if (defender == null) {
      setState(() {
        _board[to.row][to.col] = attacker;
        _board[from.row][from.col] = null;
        _selected = null;
        _statusMessage =
            '${_sideLabel(_currentTurn)}方把 ${_pieceLabel(attacker)} 移动到空位。';
      });
      _finishTurn();
      return;
    }

    if (!defender.revealed) {
      setState(() {
        _statusMessage = '不能走到暗棋上，只能翻开它。';
      });
      return;
    }

    if (defender.side == attacker.side) {
      setState(() {
        _statusMessage = '不能吃自己的棋子。';
      });
      return;
    }

    if (!_canCapture(attacker: attacker, defender: defender)) {
      setState(() {
        _statusMessage =
            '${_pieceLabel(attacker)} 不能吃掉 ${_pieceLabel(defender)}。';
      });
      return;
    }

    final isMutualElimination = attacker.rank == defender.rank;
    final specialWinner = _specialThreePieceWinner(
      from: from,
      to: to,
      eliminatedRank: attacker.rank,
      isMutualElimination: isMutualElimination,
    );
    final winnerMessage = specialWinner == null
        ? null
        : '${_sideLabel(specialWinner)}方获胜：场上只剩三枚棋子时，两枚大棋子同归于尽，最后剩下的是${_sideLabel(specialWinner)}方。';

    setState(() {
      _board[from.row][from.col] = null;
      _board[to.row][to.col] = isMutualElimination ? null : attacker;
      _selected = null;
      _statusMessage =
          isMutualElimination
              ? '${_sideLabel(_currentTurn)}方的 ${_pieceLabel(attacker)} 与 ${_sideLabel(defender.side)}方的 ${_pieceLabel(defender)} 同归于尽。'
              : '${_sideLabel(_currentTurn)}方用 ${_pieceLabel(attacker)} 吃掉了 ${_sideLabel(defender.side)}方 ${_pieceLabel(defender)}。';
    });
    _finishTurn(
      forcedWinner: specialWinner,
      winnerMessage: winnerMessage,
    );
  }

  bool _canCapture({
    required GamePiece attacker,
    required GamePiece defender,
  }) {
    if (attacker.side == defender.side) {
      return false;
    }
    if (attacker.rank == 1 && defender.rank == 8) {
      return true;
    }
    return attacker.rank >= defender.rank;
  }

  void _finishTurn({
    PieceSide? forcedWinner,
    String? winnerMessage,
  }) {
    final winner = forcedWinner ?? _checkWinner();
    if (winner != null) {
      setState(() {
        _winner = winner;
        _selected = null;
        _statusMessage = winnerMessage ?? '${_sideLabel(winner)}方获胜，已吃光对手所有棋子。';
      });
      return;
    }

    final nextTurn = _currentTurn == PieceSide.red ? PieceSide.blue : PieceSide.red;
    final currentPlayerCanAct = _sideHasAction(_currentTurn);
    final nextPlayerCanAct = _sideHasAction(nextTurn);

    setState(() {
      _currentTurn = nextTurn;
    });

    if (!nextPlayerCanAct && !currentPlayerCanAct) {
      setState(() {
        _isDraw = true;
        _statusMessage = '双方都没有可执行的操作，平局。';
      });
      return;
    }

    if (!nextPlayerCanAct) {
      setState(() {
        _winner = _currentTurn == PieceSide.red ? PieceSide.blue : PieceSide.red;
        _statusMessage =
            '${_sideLabel(_winner!)}方获胜，对手已经没有可执行的操作。';
      });
      return;
    }

    setState(() {
      _statusMessage = '轮到${_sideLabel(_currentTurn)}方：翻牌或走一步。';
    });
  }

  PieceSide? _checkWinner() {
    var redCount = 0;
    var blueCount = 0;
    for (final row in _board) {
      for (final piece in row) {
        if (piece == null) {
          continue;
        }
        if (piece.side == PieceSide.red) {
          redCount++;
        } else {
          blueCount++;
        }
      }
    }

    if (redCount == 0) {
      return PieceSide.blue;
    }
    if (blueCount == 0) {
      return PieceSide.red;
    }
    return null;
  }

  PieceSide? _specialThreePieceWinner({
    required BoardPosition from,
    required BoardPosition to,
    required int eliminatedRank,
    required bool isMutualElimination,
  }) {
    if (!isMutualElimination) {
      return null;
    }

    final remainingPieces = <GamePiece>[];
    for (var row = 0; row < boardSize; row++) {
      for (var col = 0; col < boardSize; col++) {
        final piece = _board[row][col];
        if (piece == null) {
          continue;
        }
        if ((row == from.row && col == from.col) ||
            (row == to.row && col == to.col)) {
          continue;
        }
        remainingPieces.add(piece);
      }
    }

    if (remainingPieces.length != 1) {
      return null;
    }

    final remainingPiece = remainingPieces.first;
    if (remainingPiece.rank >= eliminatedRank) {
      return null;
    }

    return remainingPiece.side;
  }

  bool _sideHasAction(PieceSide side) {
    if (_hasHiddenPieces()) {
      return true;
    }

    for (var row = 0; row < boardSize; row++) {
      for (var col = 0; col < boardSize; col++) {
        final piece = _board[row][col];
        if (piece == null || !piece.revealed || piece.side != side) {
          continue;
        }

        final from = BoardPosition(row, col);
        for (final target in _adjacentPositions(from)) {
          final other = _board[target.row][target.col];
          if (other == null) {
            return true;
          }
          if (other.revealed && _canCapture(attacker: piece, defender: other)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  bool _hasHiddenPieces() {
    for (final row in _board) {
      for (final piece in row) {
        if (piece != null && !piece.revealed) {
          return true;
        }
      }
    }
    return false;
  }

  List<BoardPosition> _adjacentPositions(BoardPosition position) {
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

  int _remainingCount(PieceSide side) {
    var count = 0;
    for (final row in _board) {
      for (final piece in row) {
        if (piece?.side == side) {
          count++;
        }
      }
    }
    return count;
  }

  String _sideLabel(PieceSide side) {
    return side == PieceSide.red ? '红' : '蓝';
  }

  String _pieceLabel(GamePiece piece) {
    return '${piece.rank}号${animalNames[piece.rank]}';
  }

  bool _isHighlighted(BoardPosition position) {
    final selected = _selected;
    if (selected == null) {
      return false;
    }
    if (selected == position) {
      return true;
    }

    final attacker = _board[selected.row][selected.col];
    if (attacker == null) {
      return false;
    }

    if (!selected.isAdjacentTo(position)) {
      return false;
    }

    final defender = _board[position.row][position.col];
    if (defender == null) {
      return true;
    }
    if (!defender.revealed || defender.side == attacker.side) {
      return false;
    }
    return _canCapture(attacker: attacker, defender: defender);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('斗兽棋'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildBoard(),
                  const SizedBox(height: 16),
                  _buildRulesCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final turnColor = _currentTurn == PieceSide.red
        ? const Color(0xFFC44536)
        : const Color(0xFF1E6FBA);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _winner != null || _isDraw ? Colors.grey : turnColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _winner != null
                        ? '${_sideLabel(_winner!)}方胜利'
                        : _isDraw
                            ? '平局'
                            : '当前回合：${_sideLabel(_currentTurn)}方',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: _resetGame,
                  child: const Text('重新开始'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSideCounter(
                    side: PieceSide.red,
                    count: _remainingCount(PieceSide.red),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSideCounter(
                    side: PieceSide.blue,
                    count: _remainingCount(PieceSide.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideCounter({
    required PieceSide side,
    required int count,
  }) {
    final color = side == PieceSide.red
        ? const Color(0xFFC44536)
        : const Color(0xFF1E6FBA);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            '${_sideLabel(side)}方剩余',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count 枚',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD8B27A), Color(0xFFB17A4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: boardSize * boardSize,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: boardSize,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ boardSize;
            final col = index % boardSize;
            final position = BoardPosition(row, col);
            final piece = _board[row][col];
            return _BoardCell(
              piece: piece,
              highlighted: _isHighlighted(position),
              onTap: () => _onCellTapped(position),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRulesCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '规则说明',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12),
            Text('1. 棋盘为 4 x 4，共 16 枚棋子，红蓝双方各有 1 到 8 号。'),
            SizedBox(height: 6),
            Text('2. 每回合只能二选一：翻开一张暗棋，或者移动一枚自己的明棋一步。'),
            SizedBox(height: 6),
            Text('3. 只能上下左右移动，不能斜走，也不能一次移动多格。'),
            SizedBox(height: 6),
            Text('4. 吃子时必须是对方明棋，且数字相同或更大；特殊规则是 1 号可以吃 8 号。'),
            SizedBox(height: 6),
            Text('5. 如果双方数字相同，互吃后两枚棋子都会消失。'),
            SizedBox(height: 6),
            Text('6. 如果场上只剩一枚小棋子和两枚相同的大棋子，大棋子同归于尽后，剩下那一方直接获胜。'),
            SizedBox(height: 6),
            Text('7. 被吃掉的位置会变成空格，后续可以移动进去。'),
          ],
        ),
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.piece,
    required this.highlighted,
    required this.onTap,
  });

  final GamePiece? piece;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = highlighted
        ? const Color(0xFFFFD166)
        : Colors.white.withValues(alpha: 0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _backgroundColor(),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: highlighted ? 3 : 1.5),
          ),
          child: piece == null
              ? const Center(
                  child: Text(
                    '空',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                )
              : piece!.revealed
                  ? _RevealedPiece(piece: piece!)
                  : const Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Color _backgroundColor() {
    if (piece == null) {
      return const Color(0xFF7A593F);
    }
    if (!piece!.revealed) {
      return const Color(0xFF5B432F);
    }
    return piece!.side == PieceSide.red
        ? const Color(0xFFD95D4F)
        : const Color(0xFF347FC4);
  }
}

class _RevealedPiece extends StatelessWidget {
  const _RevealedPiece({required this.piece});

  final GamePiece piece;

  @override
  Widget build(BuildContext context) {
    final animal = _JungleChessPageState.animalNames[piece.rank] ?? '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${piece.rank}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            animal,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
