// Widget tests for the primary gameplay, reset, and settings flows.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jungle_chess/game_rules.dart';
import 'package:jungle_chess/main.dart';

const String _chineseLanguageCode = 'zh';

void main() {
  testWidgets('uses the supported device language on first launch', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = <Locale>[
      const Locale('it', 'IT'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const JungleChessApp());

    expect(find.text('Ricomincia'), findsOneWidget);
    expect(find.text('Regole'), findsOneWidget);
  });

  testWidgets('falls back to English for unsupported device languages', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = <Locale>[
      const Locale('th', 'TH'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const JungleChessApp());

    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Rules'), findsOneWidget);
  });

  testWidgets('renders jungle chess game screen', (tester) async {
    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );

    expect(find.text('Animal Kings'), findsOneWidget);
    expect(find.text('重新开始'), findsOneWidget);
    expect(find.text('规则说明'), findsOneWidget);
  });

  testWidgets('keeps status heading readable beside undo actions on phones', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );

    final heading = find.text('当前回合：红方');
    expect(heading, findsOneWidget);
    expect(tester.getSize(heading).height, lessThan(70));
    expect(find.text('悔棋'), findsOneWidget);
    expect(find.text('重新开始'), findsOneWidget);

    final undoButtonRect = tester.getRect(
      find.byKey(const ValueKey<String>('undo-button')),
    );
    final resetButtonRect = tester.getRect(
      find.byKey(const ValueKey<String>('reset-button')),
    );
    expect(
      undoButtonRect.center.dy,
      moreOrLessEquals(resetButtonRect.center.dy, epsilon: 1),
    );
    expect(undoButtonRect.left, lessThan(resetButtonRect.left));
    expect(resetButtonRect.right - undoButtonRect.left, greaterThan(250));
  });

  testWidgets('places remaining counters below the board', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );

    final boardBottom = tester
        .getBottomLeft(find.byKey(const ValueKey<String>('board-cell-3-0')))
        .dy;
    final countersTop = tester
        .getTopLeft(find.byKey(const ValueKey<String>('side-counters')))
        .dy;

    expect(countersTop, greaterThan(boardBottom));
    expect(
      find.byKey(const ValueKey<String>('red-remaining-counter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('blue-remaining-counter')),
      findsOneWidget,
    );
  });

  testWidgets('asks for confirmation before restarting', (tester) async {
    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );

    await tester.tap(find.byKey(const ValueKey<String>('reset-button')));
    await tester.pumpAndSettle();

    expect(find.text('重新开始？'), findsOneWidget);
    expect(find.text('当前棋局会被清空。'), findsOneWidget);
    expect(find.text('继续游戏'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('重新开始'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('继续游戏'));
    await tester.pumpAndSettle();

    expect(find.text('重新开始？'), findsNothing);
  });

  testWidgets('opens settings and toggles sound effects', (tester) async {
    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsOneWidget);
    expect(find.text('音效'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    final soundSwitch = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(soundSwitch.value, isFalse);

    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsNothing);
  });

  testWidgets('changes interface language from settings', (tester) async {
    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('language-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Sound effects'), findsOneWidget);
    expect(find.text('Interface language'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Rules'), findsOneWidget);
  });

  testWidgets('can return to the device language from settings', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = <Locale>[
      const Locale('it', 'IT'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const JungleChessApp());

    expect(find.text('Ricomincia'), findsOneWidget);
    expect(find.text('Regole'), findsOneWidget);

    await tester.tap(find.byTooltip('Impostazioni'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('language-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Sound effects'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Rules'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('language-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Device language').last);
    await tester.pumpAndSettle();

    expect(find.text('Impostazioni'), findsOneWidget);
    expect(find.text('Effetti sonori'), findsOneWidget);

    await tester.tap(find.text('Fine'));
    await tester.pumpAndSettle();

    expect(find.text('Ricomincia'), findsOneWidget);
    expect(find.text('Regole'), findsOneWidget);
  });

  testWidgets(
    'asks for confirmation before undoing and reverts after animation',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: JungleChessPage(
            languageCode: _chineseLanguageCode,
            initialBoard: testBoard(
              red: const BoardPosition(0, 0),
              blue: const BoardPosition(0, 1),
              hiddenBlue: const BoardPosition(1, 0),
            ),
          ),
        ),
      );

      final undoButton = find.byKey(const ValueKey<String>('undo-button'));
      expect(tester.widget<OutlinedButton>(undoButton).onPressed, isNull);

      await tester.tap(find.text('?'));
      await tester.pumpAndSettle();

      expect(tester.widget<OutlinedButton>(undoButton).onPressed, isNotNull);

      await tester.tap(undoButton);
      await tester.pumpAndSettle();

      expect(find.text('确认悔棋？'), findsOneWidget);
      expect(find.text('观看广告后将回退到上一步。'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('观看广告并悔棋'), findsOneWidget);

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(find.text('确认悔棋？'), findsNothing);
      expect(find.text('?'), findsNothing);

      await tester.tap(undoButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '观看广告并悔棋'));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('undo-animation-overlay')),
        findsOneWidget,
      );
      expect(find.text('悔棋中'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(find.text('?'), findsOneWidget);
      expect(find.text('当前回合：红方'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(undoButton).onPressed, isNull);
    },
  );

  testWidgets('can undo multiple moves until the opening position', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialBoard: testBoard(
            red: const BoardPosition(0, 0),
            blue: const BoardPosition(0, 1),
            hiddenBlue: const BoardPosition(1, 0),
          ),
        ),
      ),
    );

    final undoButton = find.byKey(const ValueKey<String>('undo-button'));

    await tester.tap(find.text('8'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('?'));
    await tester.pumpAndSettle();

    expect(find.text('?'), findsNothing);
    expect(find.text('当前回合：红方'), findsOneWidget);

    await _confirmUndo(tester);

    expect(find.text('?'), findsOneWidget);
    expect(find.text('当前回合：蓝方'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(undoButton).onPressed, isNotNull);

    await _confirmUndo(tester);

    expect(find.text('?'), findsOneWidget);
    expect(find.text('当前回合：红方'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(undoButton).onPressed, isNull);
  });

  testWidgets('shows directional arrows for legal selected-piece moves', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialBoard: testBoard(
            red: const BoardPosition(0, 0),
            blue: const BoardPosition(0, 1),
          ),
        ),
      ),
    );

    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('move-direction-arrow-down')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('move-direction-arrow-right')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('move-direction-arrow-up')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('move-direction-arrow-left')),
      findsNothing,
    );

    final selectedCellCenter = tester.getCenter(
      find.byKey(const ValueKey<String>('board-cell-0-0')),
    );
    final rightCellCenter = tester.getCenter(
      find.byKey(const ValueKey<String>('board-cell-0-1')),
    );
    final downCellCenter = tester.getCenter(
      find.byKey(const ValueKey<String>('board-cell-1-0')),
    );
    final rightArrowCenter = tester.getCenter(
      find.byKey(const ValueKey<String>('move-direction-arrow-right')),
    );
    final downArrowCenter = tester.getCenter(
      find.byKey(const ValueKey<String>('move-direction-arrow-down')),
    );

    expect(
      rightArrowCenter.dx,
      moreOrLessEquals(
        (selectedCellCenter.dx + rightCellCenter.dx) / 2,
        epsilon: 1,
      ),
    );
    expect(rightArrowCenter.dy, moreOrLessEquals(selectedCellCenter.dy));
    expect(downArrowCenter.dx, moreOrLessEquals(selectedCellCenter.dx));
    expect(
      downArrowCenter.dy,
      moreOrLessEquals(
        (selectedCellCenter.dy + downCellCenter.dy) / 2,
        epsilon: 1,
      ),
    );
  });

  testWidgets('declares a winner after capturing the last opposing piece', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialBoard: testBoard(
            red: const BoardPosition(0, 0),
            blue: const BoardPosition(0, 1),
          ),
        ),
      ),
    );

    await tester.tap(find.text('8'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    expect(find.text('红方胜利'), findsOneWidget);
    expect(find.text('红方赢'), findsOneWidget);
    expect(find.text('点击重新开始进入下一局'), findsOneWidget);
    expect(find.text('红方获胜，已吃光对手所有棋子。'), findsOneWidget);
  });

  testWidgets('restarts without confirmation after the game is over', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialBoard: testBoard(
            red: const BoardPosition(0, 0),
            blue: const BoardPosition(0, 1),
          ),
        ),
      ),
    );

    await tester.tap(find.text('8'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    expect(find.text('红方赢'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('reset-button')));
    await tester.pumpAndSettle();

    expect(find.text('重新开始？'), findsNothing);
    expect(find.text('红方赢'), findsNothing);
    expect(find.text('当前回合：红方'), findsOneWidget);
  });

  testWidgets('explains when captured piece was not the last hidden piece', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialBoard: testBoard(
            red: const BoardPosition(0, 0),
            blue: const BoardPosition(0, 1),
            hiddenBlue: const BoardPosition(3, 3),
          ),
        ),
      ),
    );

    await tester.tap(find.text('8'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    expect(find.text('红方胜利'), findsNothing);
    expect(find.text('红方赢'), findsNothing);
    expect(find.textContaining('蓝方还剩 1 枚（含暗棋）'), findsOneWidget);
  });
}

GameBoard testBoard({
  required BoardPosition red,
  required BoardPosition blue,
  BoardPosition? hiddenBlue,
}) {
  final board = List<List<GamePiece?>>.generate(
    JungleGameRules.boardSize,
    (_) => List<GamePiece?>.filled(JungleGameRules.boardSize, null),
  );
  board[red.row][red.col] = const GamePiece(
    side: PieceSide.red,
    rank: 8,
    revealed: true,
  );
  board[blue.row][blue.col] = const GamePiece(
    side: PieceSide.blue,
    rank: 2,
    revealed: true,
  );
  if (hiddenBlue != null) {
    board[hiddenBlue.row][hiddenBlue.col] = const GamePiece(
      side: PieceSide.blue,
      rank: 3,
    );
  }
  return board;
}

Future<void> _confirmUndo(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey<String>('undo-button')));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, '观看广告并悔棋'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}
