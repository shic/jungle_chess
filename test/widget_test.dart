// Widget tests for the primary gameplay, reset, and settings flows.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jungle_chess/game_ai.dart';
import 'package:jungle_chess/game_rules.dart';
import 'package:jungle_chess/jungle_localizations.dart';
import 'package:jungle_chess/main.dart';

const String _chineseLanguageCode = 'zh';

void main() {
  testWidgets('renders mode selection on first launch', (tester) async {
    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );

    expect(find.text('选择对局'), findsOneWidget);
    expect(find.text('本地双人'), findsOneWidget);
    expect(find.text('人机对战'), findsOneWidget);
    expect(find.text('电脑难度'), findsNothing);
    expect(find.byKey(const ValueKey<String>('board-cell-0-0')), findsNothing);

    await _startLocalTwoPlayerGame(tester);

    expect(find.text('玩家1先翻棋'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('board-cell-0-0')),
      findsOneWidget,
    );
  });

  testWidgets('starts computer mode from the selection screen', (tester) async {
    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );

    await tester.tap(find.byKey(const ValueKey<String>('start-vs-computer')));
    await tester.pumpAndSettle();

    expect(find.text('电脑难度'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('board-cell-0-0')), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('start-vs-computer-easy')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('start-vs-computer-normal')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('start-vs-computer-hard')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('start-vs-computer-hard')),
    );
    await tester.pumpAndSettle();

    expect(find.text('电脑难度'), findsNothing);
    expect(find.text('玩家1先翻棋'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('board-cell-0-0')),
      findsOneWidget,
    );
  });

  testWidgets('returns from computer difficulty selection to mode selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );

    await tester.tap(find.byKey(const ValueKey<String>('start-vs-computer')));
    await tester.pumpAndSettle();

    expect(find.text('电脑难度'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('back-to-mode-selection')),
    );
    await tester.pumpAndSettle();

    expect(find.text('选择对局'), findsOneWidget);
    expect(find.text('电脑难度'), findsNothing);
    expect(find.byKey(const ValueKey<String>('board-cell-0-0')), findsNothing);
  });

  testWidgets('uses the supported device language on first launch', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = <Locale>[
      const Locale('it', 'IT'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const JungleChessApp());
    await _startLocalTwoPlayerGame(tester);

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
    await _startLocalTwoPlayerGame(tester);

    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Rules'), findsOneWidget);
  });

  testWidgets('renders jungle chess game screen', (tester) async {
    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );
    await _startLocalTwoPlayerGame(tester);

    expect(find.text('Animal Kings'), findsOneWidget);
    expect(find.text('重新开始'), findsOneWidget);
    expect(find.text('规则说明'), findsOneWidget);
  });

  testWidgets('asks before returning from the game board to mode selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );
    await _startLocalTwoPlayerGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('game-back-button')));
    await tester.pumpAndSettle();

    expect(find.text('返回选择对局？'), findsOneWidget);
    expect(find.text('当前棋局会结束，并返回选择本地双人或人机对战。'), findsOneWidget);
    expect(find.text('继续游戏'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, '返回'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('继续游戏'));
    await tester.pumpAndSettle();

    expect(find.text('返回选择对局？'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('board-cell-0-0')),
      findsOneWidget,
    );
    expect(find.text('选择对局'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('game-back-button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, '返回'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('选择对局'), findsOneWidget);
    expect(find.text('本地双人'), findsOneWidget);
    expect(find.text('人机对战'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('game-back-button')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey<String>('board-cell-0-0')), findsNothing);
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
    await _startLocalTwoPlayerGame(tester);

    final heading = find.text('玩家1先翻棋');
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
    await _startLocalTwoPlayerGame(tester);

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
    await _startLocalTwoPlayerGame(tester);

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
    await _startLocalTwoPlayerGame(tester);

    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Rules'), findsOneWidget);
  });

  testWidgets('changes game mode and AI difficulty from settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const JungleChessApp(initialLanguageCode: _chineseLanguageCode),
    );
    await _startLocalTwoPlayerGame(tester);

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();

    expect(find.text('游戏模式'), findsOneWidget);
    expect(find.text('本地双人'), findsOneWidget);
    expect(find.text('人机对战'), findsOneWidget);
    expect(find.text('电脑难度'), findsOneWidget);

    await tester.tap(find.text('人机对战'));
    await tester.pumpAndSettle();

    expect(find.text('切换模式？'), findsOneWidget);
    expect(find.textContaining('切换到人机对战'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, '重新开始'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('ai-difficulty-dropdown')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('困难').last);
    await tester.pumpAndSettle();

    expect(find.text('困难'), findsOneWidget);

    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsNothing);
  });

  testWidgets('can return to the device language from settings', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = <Locale>[
      const Locale('it', 'IT'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const JungleChessApp());
    await _startLocalTwoPlayerGame(tester);

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
      expect(_currentTurnText('当前回合：玩家1（红方）'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(undoButton).onPressed, isNull);
    },
  );

  testWidgets('starts unassigned and binds player 1 to first red flip', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialBoard: hiddenOpeningBoard(
            first: const GamePiece(side: PieceSide.red, rank: 8),
            second: const GamePiece(side: PieceSide.blue, rank: 2),
          ),
        ),
      ),
    );

    expect(find.text('玩家1先翻棋'), findsOneWidget);
    expect(_currentTurnText('当前回合：红方'), findsNothing);
    expect(find.text('红方先手：每回合可以翻一张牌，或者移动一枚自己的棋子。'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('board-cell-0-0')));
    await tester.pumpAndSettle();

    expect(_currentTurnText('当前回合：玩家2（蓝方）'), findsOneWidget);
    expect(find.textContaining('玩家1翻出了红方 8号象'), findsOneWidget);
    expect(find.textContaining('玩家1是红方，玩家2是蓝方'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('first-flip-toast')),
      findsOneWidget,
    );
    expect(find.text('阵营已确定'), findsOneWidget);
    expect(find.text('你翻出了红方棋子，本局你执红方。现在轮到玩家2（蓝方）。'), findsOneWidget);
  });

  testWidgets('colors localized current-turn player label by side', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: 'it',
          initialBoard: hiddenOpeningBoard(
            first: const GamePiece(side: PieceSide.red, rank: 8),
            second: const GamePiece(side: PieceSide.blue, rank: 2),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('board-cell-0-0')));
    await tester.pumpAndSettle();

    expect(
      _currentTurnText('Turno attuale: Giocatore 2 (Blu)'),
      findsOneWidget,
    );
    expect(
      _currentTurnSideSpan(tester, 'Giocatore 2 (Blu)').style?.color,
      const Color(0xFF1E6FBA),
    );
  });

  test('localizes computer-mode current-turn player labels', () {
    final strings = JungleStrings.forCode('it');

    expect(
      strings.currentTurn(PieceSide.red, PieceSide.red, computerOpponent: true),
      'Turno attuale: Tu (Rosso)',
    );
    expect(
      strings.currentTurn(
        PieceSide.blue,
        PieceSide.red,
        computerOpponent: true,
      ),
      'Turno attuale: Computer (Blu)',
    );
  });

  testWidgets('keeps first flip toast visible for five seconds', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialBoard: hiddenOpeningBoard(
            first: const GamePiece(side: PieceSide.blue, rank: 2),
            second: const GamePiece(side: PieceSide.red, rank: 8),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('board-cell-0-0')));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('first-flip-toast')),
      findsOneWidget,
    );
    expect(find.text('阵营已确定'), findsOneWidget);
    expect(find.text('你翻出了蓝方棋子，本局你执蓝方。现在轮到玩家2（红方）。'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 4999));

    expect(
      find.byKey(const ValueKey<String>('first-flip-toast')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('first-flip-toast')),
      findsNothing,
    );
  });

  testWidgets('binds player 1 to blue when the first flip is blue', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialBoard: hiddenOpeningBoard(
            first: const GamePiece(side: PieceSide.blue, rank: 2),
            second: const GamePiece(side: PieceSide.red, rank: 8),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('board-cell-0-0')));
    await tester.pumpAndSettle();

    expect(_currentTurnText('当前回合：玩家2（红方）'), findsOneWidget);
    expect(find.textContaining('玩家1翻出了蓝方 2号猫'), findsOneWidget);
    expect(find.textContaining('玩家1是蓝方，玩家2是红方'), findsOneWidget);
  });

  testWidgets('undoing the first flip clears the player side assignment', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialBoard: hiddenOpeningBoard(
            first: const GamePiece(side: PieceSide.red, rank: 8),
            second: const GamePiece(side: PieceSide.blue, rank: 2),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('board-cell-0-0')));
    await tester.pumpAndSettle();

    expect(_currentTurnText('当前回合：玩家2（蓝方）'), findsOneWidget);

    await _confirmUndo(tester);

    expect(find.text('玩家1先翻棋'), findsOneWidget);
    expect(_currentTurnText('当前回合：玩家2（蓝方）'), findsNothing);
    expect(find.text('?'), findsNWidgets(2));
  });

  testWidgets(
    'computer moves after the player and blocks input while thinking',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: JungleChessPage(
            languageCode: _chineseLanguageCode,
            initialGameMode: GameMode.vsComputer,
            initialAiDifficulty: AiDifficulty.easy,
            initialBoard: hiddenOpeningBoard(
              first: const GamePiece(side: PieceSide.red, rank: 8),
              second: const GamePiece(side: PieceSide.blue, rank: 2),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey<String>('board-cell-0-0')));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('ai-thinking-overlay')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Icon>(
              find.byKey(const ValueKey<String>('ai-thinking-icon')),
            )
            .color,
        const Color(0xFF1E6FBA),
      );
      expect(find.text('?'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('board-cell-0-1')));
      await tester.pump();

      expect(find.text('?'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('ai-thinking-overlay')),
        findsNothing,
      );
      expect(find.text('2'), findsOneWidget);
      expect(_currentTurnText('当前回合：你（红方）'), findsOneWidget);
    },
  );

  testWidgets('computer thinking icon follows the computer side color', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialGameMode: GameMode.vsComputer,
          initialAiDifficulty: AiDifficulty.easy,
          initialBoard: hiddenOpeningBoard(
            first: const GamePiece(side: PieceSide.blue, rank: 2),
            second: const GamePiece(side: PieceSide.red, rank: 8),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('board-cell-0-0')));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('ai-thinking-overlay')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey<String>('ai-thinking-icon')))
          .color,
      const Color(0xFFC44536),
    );

    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump();
  });

  testWidgets('computer mode undo rolls back a full player-computer round', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JungleChessPage(
          languageCode: _chineseLanguageCode,
          initialGameMode: GameMode.vsComputer,
          initialAiDifficulty: AiDifficulty.easy,
          initialBoard: hiddenOpeningBoard(
            first: const GamePiece(side: PieceSide.red, rank: 8),
            second: const GamePiece(side: PieceSide.blue, rank: 2),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('board-cell-0-0')));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump();

    expect(find.text('8'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('undo-button')));
    await tester.pumpAndSettle();

    expect(find.text('观看广告后将回退一整轮玩家和电脑的操作。'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '观看广告并悔棋'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('玩家1先翻棋'), findsOneWidget);
    expect(find.text('?'), findsNWidgets(2));
    expect(find.text('8'), findsNothing);
    expect(find.text('2'), findsNothing);
  });

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
    expect(_currentTurnText('当前回合：玩家1（红方）'), findsOneWidget);

    await _confirmUndo(tester);

    expect(find.text('?'), findsOneWidget);
    expect(_currentTurnText('当前回合：玩家2（蓝方）'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(undoButton).onPressed, isNotNull);

    await _confirmUndo(tester);

    expect(find.text('?'), findsOneWidget);
    expect(_currentTurnText('当前回合：玩家1（红方）'), findsOneWidget);
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

    expect(find.text('玩家1（红方）胜利'), findsOneWidget);
    expect(find.text('玩家1（红方）赢'), findsOneWidget);
    expect(find.text('点击重新开始进入下一局'), findsOneWidget);
    expect(find.text('玩家1（红方）获胜，已吃光对手所有棋子。'), findsOneWidget);
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

    expect(find.text('玩家1（红方）赢'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('reset-button')));
    await tester.pumpAndSettle();

    expect(find.text('重新开始？'), findsNothing);
    expect(find.text('玩家1（红方）赢'), findsNothing);
    expect(_currentTurnText('当前回合：玩家1（红方）'), findsOneWidget);
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

    expect(find.text('玩家1（红方）胜利'), findsNothing);
    expect(find.text('玩家1（红方）赢'), findsNothing);
    expect(find.textContaining('玩家2（蓝方）还剩 1 枚（含暗棋）'), findsOneWidget);
  });
}

GameBoard hiddenOpeningBoard({
  required GamePiece first,
  required GamePiece second,
}) {
  final board = List<List<GamePiece?>>.generate(
    JungleGameRules.boardSize,
    (_) => List<GamePiece?>.filled(JungleGameRules.boardSize, null),
  );
  board[0][0] = first;
  board[0][1] = second;
  return board;
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

Future<void> _startLocalTwoPlayerGame(WidgetTester tester) async {
  await tester.tap(
    find.byKey(const ValueKey<String>('start-local-two-player')),
  );
  await tester.pumpAndSettle();
}

Finder _currentTurnText(String text) {
  return find.text(text, findRichText: true);
}

TextSpan _currentTurnSideSpan(WidgetTester tester, String sideText) {
  final heading = tester.widget<Text>(
    find.byKey(const ValueKey<String>('current-turn-heading')),
  );
  final span = heading.textSpan! as TextSpan;
  return span.children!.whereType<TextSpan>().firstWhere(
    (child) => child.text == sideText,
  );
}
