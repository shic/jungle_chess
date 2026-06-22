// Flutter UI and interaction flow for Animal Kings.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jungle_chess/game_ai.dart';
import 'package:jungle_chess/game_audio_service.dart';
import 'package:jungle_chess/jungle_localizations.dart';
import 'package:jungle_chess/game_rules.dart';
import 'package:jungle_chess/reset_interstitial_ad_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(ResetInterstitialAdService.instance.initialize());
  runApp(const JungleChessApp());
}

class JungleChessApp extends StatefulWidget {
  const JungleChessApp({super.key, this.initialLanguageCode});

  final String? initialLanguageCode;

  @override
  State<JungleChessApp> createState() => _JungleChessAppState();
}

class _JungleChessAppState extends State<JungleChessApp>
    with WidgetsBindingObserver {
  late String _languageCode;
  late bool _followsDeviceLanguage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _followsDeviceLanguage = widget.initialLanguageCode == null;
    _languageCode = _resolveInitialLanguageCode();
  }

  @override
  void didUpdateWidget(covariant JungleChessApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLanguageCode == oldWidget.initialLanguageCode) {
      return;
    }
    _followsDeviceLanguage = widget.initialLanguageCode == null;
    _languageCode = _resolveInitialLanguageCode();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (!_followsDeviceLanguage) {
      return;
    }
    final nextLanguageCode = AppLanguage.resolveLocales(locales);
    if (nextLanguageCode == _languageCode) {
      return;
    }
    setState(() {
      _languageCode = nextLanguageCode;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _resolveInitialLanguageCode() {
    final initialLanguageCode = widget.initialLanguageCode;
    if (initialLanguageCode != null) {
      return AppLanguage.normalize(initialLanguageCode);
    }
    return AppLanguage.resolveLocales(
      WidgetsBinding.instance.platformDispatcher.locales,
    );
  }

  void _setLanguage(String languageCode) {
    setState(() {
      _followsDeviceLanguage = false;
      _languageCode = AppLanguage.normalize(languageCode);
    });
  }

  void _useDeviceLanguage() {
    setState(() {
      _followsDeviceLanguage = true;
      _languageCode = AppLanguage.resolveLocales(
        WidgetsBinding.instance.platformDispatcher.locales,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = JungleStrings.forCode(_languageCode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: strings.appTitle,
      locale: strings.locale,
      supportedLocales: AppLanguage.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB3541E)),
        scaffoldBackgroundColor: const Color(0xFFF6F0E3),
        useMaterial3: true,
      ),
      home: JungleChessPage(
        languageCode: _languageCode,
        followsDeviceLanguage: _followsDeviceLanguage,
        onLanguageChanged: _setLanguage,
        onUseDeviceLanguage: _useDeviceLanguage,
      ),
    );
  }
}

enum _MoveDirection { up, down, left, right }

enum GameMode { localTwoPlayer, vsComputer }

const double _boardGap = 10;
const String _deviceLanguageDropdownValue = 'device-language';

class _GameSnapshot {
  const _GameSnapshot({
    required this.board,
    required this.currentTurn,
    required this.playerOneSide,
    required this.statusMessage,
    required this.winner,
    required this.isDraw,
    required this.turnsWithoutCapture,
    required this.recentAiActions,
  });

  final GameBoard board;
  final PieceSide currentTurn;
  final PieceSide? playerOneSide;
  final _StatusMessage statusMessage;
  final PieceSide? winner;
  final bool isDraw;
  final int turnsWithoutCapture;
  final List<GameAction> recentAiActions;
}

class _StatusMessage {
  const _StatusMessage(this._builder);

  final String Function(JungleStrings strings) _builder;

  String resolve(JungleStrings strings) => _builder(strings);
}

String _emptyStatusMessage(JungleStrings strings) => '';

extension _MoveDirectionDetails on _MoveDirection {
  int get rowDelta {
    return switch (this) {
      _MoveDirection.up => -1,
      _MoveDirection.down => 1,
      _MoveDirection.left || _MoveDirection.right => 0,
    };
  }

  int get colDelta {
    return switch (this) {
      _MoveDirection.left => -1,
      _MoveDirection.right => 1,
      _MoveDirection.up || _MoveDirection.down => 0,
    };
  }

  double get radians {
    return switch (this) {
      _MoveDirection.up => -pi / 2,
      _MoveDirection.down => pi / 2,
      _MoveDirection.left => pi,
      _MoveDirection.right => 0,
    };
  }

  Offset entryOffset(double distance) {
    return switch (this) {
      _MoveDirection.up => Offset(0, distance),
      _MoveDirection.down => Offset(0, -distance),
      _MoveDirection.left => Offset(distance, 0),
      _MoveDirection.right => Offset(-distance, 0),
    };
  }
}

class JungleChessPage extends StatefulWidget {
  const JungleChessPage({
    super.key,
    this.initialBoard,
    this.initialTurn = PieceSide.red,
    this.languageCode = defaultLanguageCode,
    this.followsDeviceLanguage = false,
    this.initialGameMode = GameMode.localTwoPlayer,
    this.initialAiDifficulty = AiDifficulty.normal,
    this.onLanguageChanged,
    this.onUseDeviceLanguage,
  });

  final GameBoard? initialBoard;
  final PieceSide initialTurn;
  final String languageCode;
  final bool followsDeviceLanguage;
  final GameMode initialGameMode;
  final AiDifficulty initialAiDifficulty;
  final ValueChanged<String>? onLanguageChanged;
  final VoidCallback? onUseDeviceLanguage;

  @override
  State<JungleChessPage> createState() => _JungleChessPageState();
}

class _JungleChessPageState extends State<JungleChessPage> {
  static const int boardSize = JungleGameRules.boardSize;
  static const Duration _firstFlipToastDuration = Duration(seconds: 5);
  static const Duration _aiMoveDelay = Duration(milliseconds: 400);

  final Random _random = Random();
  final List<_GameSnapshot> _moveHistory = <_GameSnapshot>[];
  final List<GameAction> _recentAiActions = <GameAction>[];
  late List<List<GamePiece?>> _board;
  PieceSide _currentTurn = PieceSide.red;
  PieceSide? _playerOneSide;
  PieceSide? _firstFlipToastSide;
  BoardPosition? _selected;
  _StatusMessage _statusMessage = const _StatusMessage(_emptyStatusMessage);
  PieceSide? _winner;
  late GameMode _gameMode;
  late AiDifficulty _aiDifficulty;
  bool _isDraw = false;
  bool _soundEnabled = true;
  late bool _modeSelected;
  bool _undoInProgress = false;
  bool _showUndoAnimation = false;
  bool _aiThinking = false;
  int _turnsWithoutCapture = 0;
  int _aiTurnToken = 0;
  Timer? _firstFlipToastTimer;

  JungleStrings get _strings => JungleStrings.forCode(widget.languageCode);

  @override
  void initState() {
    super.initState();
    _gameMode = widget.initialGameMode;
    _aiDifficulty = widget.initialAiDifficulty;
    _modeSelected = widget.initialBoard != null;
    GameAudioService.instance.enabled = _soundEnabled;
    _resetGame();
  }

  @override
  void dispose() {
    _aiTurnToken++;
    _firstFlipToastTimer?.cancel();
    super.dispose();
  }

  void _resetGame() {
    _cancelFirstFlipToast();
    _cancelAiTurn();
    final initialBoard = widget.initialBoard;
    if (initialBoard != null) {
      _board = _copyBoard(initialBoard);
      final initialTurn = widget.initialTurn;
      final playerOneSide = _initialPlayerOneSide(initialBoard, initialTurn);
      setState(() {
        _moveHistory.clear();
        _recentAiActions.clear();
        _currentTurn = initialTurn;
        _playerOneSide = playerOneSide;
        _firstFlipToastSide = null;
        _selected = null;
        _winner = null;
        _isDraw = false;
        _undoInProgress = false;
        _showUndoAnimation = false;
        _aiThinking = false;
        _turnsWithoutCapture = 0;
        _statusMessage = playerOneSide == null
            ? _StatusMessage((strings) => strings.openingTurn())
            : _StatusMessage(
                (strings) => strings.turnMessage(
                  initialTurn,
                  playerOneSide,
                  0,
                  JungleGameRules.nonCaptureDrawLimit,
                  computerOpponent: _isVsComputer,
                ),
              );
      });
      _queueAiTurnCheck();
      return;
    }

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
      _moveHistory.clear();
      _recentAiActions.clear();
      _currentTurn = PieceSide.red;
      _playerOneSide = null;
      _firstFlipToastSide = null;
      _selected = null;
      _winner = null;
      _isDraw = false;
      _undoInProgress = false;
      _showUndoAnimation = false;
      _aiThinking = false;
      _turnsWithoutCapture = 0;
      _statusMessage = _StatusMessage((strings) => strings.openingTurn());
    });
    _queueAiTurnCheck();
  }

  GameBoard _copyBoard(GameBoard board) {
    return <List<GamePiece?>>[
      for (final row in board) <GamePiece?>[...row],
    ];
  }

  PieceSide? _initialPlayerOneSide(GameBoard board, PieceSide initialTurn) {
    for (final row in board) {
      for (final piece in row) {
        if (piece != null && piece.revealed) {
          return initialTurn;
        }
      }
    }
    return null;
  }

  bool get _canUndo => _moveHistory.isNotEmpty;

  bool get _isVsComputer => _gameMode == GameMode.vsComputer;

  PieceSide? get _aiSide {
    final playerOneSide = _playerOneSide;
    if (!_isVsComputer || playerOneSide == null) {
      return null;
    }
    return JungleGameRules.opposite(playerOneSide);
  }

  bool get _isAiTurn {
    final aiSide = _aiSide;
    return aiSide != null &&
        _currentTurn == aiSide &&
        _winner == null &&
        !_isDraw;
  }

  bool get _blocksHumanInput => _undoInProgress || _aiThinking || _isAiTurn;

  void _cancelAiTurn() {
    _aiTurnToken++;
    _aiThinking = false;
  }

  void _queueAiTurnCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _scheduleAiTurnIfNeeded();
    });
  }

  void _cancelFirstFlipToast() {
    _firstFlipToastTimer?.cancel();
    _firstFlipToastTimer = null;
  }

  void _scheduleFirstFlipToastDismiss() {
    _cancelFirstFlipToast();
    _firstFlipToastTimer = Timer(_firstFlipToastDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _firstFlipToastSide = null;
      });
    });
  }

  Future<void> _onResetPressed() async {
    if (_winner != null || _isDraw) {
      await _restartGameWithAd();
      return;
    }

    await _confirmResetGame();
  }

  Future<void> _confirmResetGame() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        final strings = _strings;
        return AlertDialog(
          title: Text(strings.resetTitle),
          content: Text(strings.resetContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.continueGame),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.resetButton),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldReset != true) {
      return;
    }
    await _restartGameWithAd();
  }

  Future<void> _restartGameWithAd() async {
    await ResetInterstitialAdService.instance.showBeforeReset();
    if (!mounted) {
      return;
    }
    _resetGame();
  }

  void _startGame(GameMode mode, {AiDifficulty? difficulty}) {
    _gameMode = mode;
    _aiDifficulty = difficulty ?? _aiDifficulty;
    _modeSelected = true;
    _resetGame();
  }

  Future<void> _onUndoPressed() async {
    if (!_canUndo || _undoInProgress || _aiThinking) {
      return;
    }

    await _confirmUndoMove();
  }

  Future<void> _confirmUndoMove() async {
    final shouldUndo = await showDialog<bool>(
      context: context,
      builder: (context) {
        final strings = _strings;
        return AlertDialog(
          title: Text(strings.undoTitle),
          content: Text(
            _isVsComputer ? strings.undoContentComputer : strings.undoContent,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.watchAdAndUndo),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldUndo != true) {
      return;
    }
    await _undoMoveWithAd();
  }

  Future<void> _undoMoveWithAd() async {
    if (!_canUndo || _undoInProgress || _aiThinking) {
      return;
    }

    setState(() {
      _undoInProgress = true;
      _selected = null;
      _statusMessage = _StatusMessage((strings) => strings.adThenUndo());
    });

    await ResetInterstitialAdService.instance.showBeforeAction();
    if (!mounted) {
      return;
    }

    await _playUndoAnimation();
    if (!mounted) {
      return;
    }

    _restorePreviousMove();
  }

  Future<void> _playUndoAnimation() async {
    setState(() {
      _showUndoAnimation = true;
      _statusMessage = _StatusMessage((strings) => strings.undoingStatus());
    });
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) {
      return;
    }
    setState(() {
      _showUndoAnimation = false;
    });
  }

  void _saveUndoSnapshot() {
    _moveHistory.add(
      _GameSnapshot(
        board: _copyBoard(_board),
        currentTurn: _currentTurn,
        playerOneSide: _playerOneSide,
        statusMessage: _statusMessage,
        winner: _winner,
        isDraw: _isDraw,
        turnsWithoutCapture: _turnsWithoutCapture,
        recentAiActions: List<GameAction>.unmodifiable(_recentAiActions),
      ),
    );
  }

  void _restorePreviousMove() {
    if (!_canUndo) {
      setState(() {
        _undoInProgress = false;
        _showUndoAnimation = false;
      });
      return;
    }

    var snapshot = _moveHistory.removeLast();
    if (_isVsComputer &&
        _snapshotBelongsToAiTurn(snapshot) &&
        _moveHistory.isNotEmpty) {
      snapshot = _moveHistory.removeLast();
    }
    _cancelAiTurn();
    _cancelFirstFlipToast();
    setState(() {
      _board = _copyBoard(snapshot.board);
      _recentAiActions
        ..clear()
        ..addAll(snapshot.recentAiActions);
      _currentTurn = snapshot.currentTurn;
      _playerOneSide = snapshot.playerOneSide;
      _firstFlipToastSide = null;
      _selected = null;
      _winner = snapshot.winner;
      _isDraw = snapshot.isDraw;
      _turnsWithoutCapture = snapshot.turnsWithoutCapture;
      _undoInProgress = false;
      _showUndoAnimation = false;
      _statusMessage = _undoStatusMessage(snapshot);
    });
  }

  bool _snapshotBelongsToAiTurn(_GameSnapshot snapshot) {
    final playerOneSide = snapshot.playerOneSide;
    if (playerOneSide == null) {
      return false;
    }
    return snapshot.currentTurn == JungleGameRules.opposite(playerOneSide);
  }

  _StatusMessage _undoStatusMessage(_GameSnapshot snapshot) {
    final opening = _moveHistory.isEmpty;
    if (snapshot.winner != null || snapshot.isDraw) {
      return _StatusMessage((strings) {
        return strings.undoRestored(
          opening: opening,
          next: snapshot.statusMessage.resolve(strings),
        );
      });
    }

    final turn = snapshot.currentTurn;
    final playerOneSide = snapshot.playerOneSide;
    final turnsWithoutCapture = snapshot.turnsWithoutCapture;
    return _StatusMessage((strings) {
      return strings.undoRestored(
        opening: opening,
        next: playerOneSide == null
            ? strings.openingTurn()
            : strings.undoTurn(
                turn,
                playerOneSide,
                turnsWithoutCapture,
                JungleGameRules.nonCaptureDrawLimit,
                computerOpponent: _isVsComputer,
              ),
      );
    });
  }

  Future<bool> _confirmModeRestart(GameMode mode) async {
    final strings = _strings;
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.modeChangeTitle),
          content: Text(
            strings.modeChangeContent(strings.gameModeOption(mode.name)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.resetButton),
            ),
          ],
        );
      },
    );

    return mounted && shouldRestart == true;
  }

  Future<void> _showSettings() async {
    var selectedDropdownValue = widget.followsDeviceLanguage
        ? _deviceLanguageDropdownValue
        : widget.languageCode;
    var selectedLanguageCode = widget.languageCode;
    var selectedGameMode = _gameMode;
    var selectedAiDifficulty = _aiDifficulty;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final strings = JungleStrings.forCode(selectedLanguageCode);
            return AlertDialog(
              title: Text(strings.settingsTitle),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        _soundEnabled ? Icons.volume_up : Icons.volume_off,
                      ),
                      title: Text(strings.soundEffects),
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                          GameAudioService.instance.enabled = value;
                        });
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        strings.gameModeLabel,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<GameMode>(
                      key: const ValueKey<String>('game-mode-segmented'),
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment<GameMode>(
                          value: GameMode.localTwoPlayer,
                          label: Text(
                            strings.gameModeOption(
                              GameMode.localTwoPlayer.name,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          icon: const Icon(Icons.people_alt),
                        ),
                        ButtonSegment<GameMode>(
                          value: GameMode.vsComputer,
                          label: Text(
                            strings.gameModeOption(GameMode.vsComputer.name),
                            overflow: TextOverflow.ellipsis,
                          ),
                          icon: const Icon(Icons.smart_toy),
                        ),
                      ],
                      selected: <GameMode>{selectedGameMode},
                      onSelectionChanged: (values) async {
                        final nextMode = values.single;
                        if (nextMode == _gameMode) {
                          selectedGameMode = nextMode;
                          setDialogState(() {});
                          return;
                        }
                        if (!_modeSelected) {
                          selectedGameMode = nextMode;
                          setState(() {
                            _gameMode = nextMode;
                          });
                          setDialogState(() {});
                          return;
                        }
                        final confirmed = await _confirmModeRestart(nextMode);
                        if (!mounted || !confirmed) {
                          setDialogState(() {
                            selectedGameMode = _gameMode;
                          });
                          return;
                        }
                        selectedGameMode = nextMode;
                        _gameMode = nextMode;
                        _resetGame();
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AiDifficulty>(
                      key: const ValueKey<String>('ai-difficulty-dropdown'),
                      initialValue: selectedAiDifficulty,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: strings.aiDifficultyLabel,
                        prefixIcon: const Icon(Icons.psychology),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        for (final difficulty in AiDifficulty.values)
                          DropdownMenuItem<AiDifficulty>(
                            value: difficulty,
                            child: Text(
                              strings.aiDifficultyOption(difficulty.name),
                            ),
                          ),
                      ],
                      onChanged: selectedGameMode == GameMode.vsComputer
                          ? (value) {
                              if (value == null) {
                                return;
                              }
                              selectedAiDifficulty = value;
                              setState(() {
                                _aiDifficulty = value;
                              });
                              setDialogState(() {});
                            }
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: const ValueKey<String>('language-dropdown'),
                      initialValue: selectedDropdownValue,
                      isExpanded: true,
                      menuMaxHeight: 360,
                      decoration: InputDecoration(
                        labelText: strings.languageLabel,
                        prefixIcon: const Icon(Icons.language),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        if (widget.onUseDeviceLanguage != null)
                          DropdownMenuItem<String>(
                            value: _deviceLanguageDropdownValue,
                            child: Text(strings.deviceLanguageLabel),
                          ),
                        for (final language in AppLanguage.supported)
                          DropdownMenuItem<String>(
                            value: language.code,
                            child: Text(language.menuLabel),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        selectedDropdownValue = value;
                        if (value == _deviceLanguageDropdownValue) {
                          selectedLanguageCode = AppLanguage.resolveLocales(
                            WidgetsBinding.instance.platformDispatcher.locales,
                          );
                          widget.onUseDeviceLanguage?.call();
                        } else {
                          selectedLanguageCode = AppLanguage.normalize(value);
                          widget.onLanguageChanged?.call(value);
                        }
                        setDialogState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(strings.done),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _playSound(GameSoundEffect effect) {
    GameAudioService.instance.play(effect);
  }

  void _scheduleAiTurnIfNeeded() {
    if (!_isAiTurn || _aiThinking || _undoInProgress) {
      return;
    }

    final token = ++_aiTurnToken;
    setState(() {
      _aiThinking = true;
      _selected = null;
      _statusMessage = _StatusMessage(
        (strings) => strings.aiThinking(
          _currentTurn,
          _playerOneSide,
          computerOpponent: _isVsComputer,
        ),
      );
    });

    Future<void>.delayed(_aiMoveDelay, () {
      if (!mounted || token != _aiTurnToken || !_isAiTurn) {
        return;
      }
      _performAiTurn();
    });
  }

  void _performAiTurn() {
    if (!_isAiTurn) {
      setState(() {
        _aiThinking = false;
      });
      return;
    }

    final state = AiGameState.fromBoard(
      board: _board,
      currentTurn: _currentTurn,
      playerOneSide: _playerOneSide,
      consecutiveNonCaptureTurns: _turnsWithoutCapture,
    );
    final action = JungleAi.chooseAction(
      state: state,
      difficulty: _aiDifficulty,
      random: _random,
      recentActions: _recentAiActions,
    );
    if (action == null) {
      setState(() {
        _aiThinking = false;
      });
      return;
    }

    setState(() {
      _aiThinking = false;
    });
    _applyGameAction(action);
    _rememberAiAction(action);
  }

  void _rememberAiAction(GameAction action) {
    _recentAiActions.add(action);
    if (_recentAiActions.length > JungleAi.repeatMoveLimit) {
      _recentAiActions.removeRange(
        0,
        _recentAiActions.length - JungleAi.repeatMoveLimit,
      );
    }
  }

  void _applyGameAction(GameAction action) {
    switch (action.kind) {
      case GameActionKind.flip:
        final piece = _board[action.to.row][action.to.col];
        if (piece != null && !piece.revealed) {
          _flipPiece(action.to, piece);
        }
      case GameActionKind.move || GameActionKind.capture:
        final from = action.from;
        if (from == null) {
          return;
        }
        final attacker = _board[from.row][from.col];
        if (attacker == null) {
          return;
        }
        _tryMoveOrCapture(
          from: from,
          to: action.to,
          attacker: attacker,
          defender: _board[action.to.row][action.to.col],
        );
    }
  }

  void _onCellTapped(BoardPosition position) {
    if (_blocksHumanInput || _winner != null || _isDraw) {
      return;
    }

    final piece = _board[position.row][position.col];

    if (_playerOneSide == null) {
      if (piece != null && !piece.revealed) {
        _flipPiece(position, piece);
        return;
      }

      _playSound(GameSoundEffect.tap);
      setState(() {
        _selected = null;
        _statusMessage = _StatusMessage((strings) => strings.openingTurn());
      });
      return;
    }

    if (_selected == position) {
      _playSound(GameSoundEffect.tap);
      setState(() {
        _selected = null;
        _statusMessage = _StatusMessage(
          (strings) => strings.selectionCanceled(),
        );
      });
      return;
    }

    if (piece != null && piece.revealed && piece.side == _currentTurn) {
      final currentTurn = _currentTurn;
      final playerOneSide = _playerOneSide;
      _playSound(GameSoundEffect.tap);
      setState(() {
        _selected = position;
        _statusMessage = _StatusMessage(
          (strings) => strings.selectedPiece(
            currentTurn,
            playerOneSide,
            piece,
            computerOpponent: _isVsComputer,
          ),
        );
      });
      return;
    }

    if (piece != null && !piece.revealed) {
      _flipPiece(position, piece);
      return;
    }

    final selected = _selected;
    if (selected == null) {
      _playSound(GameSoundEffect.tap);
      setState(() {
        _statusMessage = _StatusMessage(
          (strings) => strings.choosePieceFirst(),
        );
      });
      return;
    }

    final movingPiece = _board[selected.row][selected.col];
    if (movingPiece == null) {
      setState(() {
        _selected = null;
        _statusMessage = _StatusMessage(
          (strings) => strings.selectedPieceMissing(),
        );
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
    final assigningPlayers = _playerOneSide == null;
    final actor = assigningPlayers ? piece.side : _currentTurn;
    final playerOneSide = _playerOneSide ?? piece.side;
    _playSound(GameSoundEffect.tap);
    _saveUndoSnapshot();
    final actionMessage = _StatusMessage(
      (strings) => assigningPlayers
          ? strings.firstFlipAssignment(
              piece.side,
              piece,
              computerOpponent: _isVsComputer,
            )
          : strings.flippedPiece(
              actor,
              playerOneSide,
              piece.side,
              piece,
              computerOpponent: _isVsComputer,
            ),
    );
    setState(() {
      _board[position.row][position.col] = piece.copyWith(revealed: true);
      _playerOneSide = playerOneSide;
      _firstFlipToastSide = assigningPlayers ? piece.side : _firstFlipToastSide;
      _currentTurn = actor;
      _selected = null;
      _statusMessage = actionMessage;
    });
    _finishTurn(captured: false, actionMessage: actionMessage, actor: actor);
    if (assigningPlayers) {
      _scheduleFirstFlipToastDismiss();
    }
  }

  void _tryMoveOrCapture({
    required BoardPosition from,
    required BoardPosition to,
    required GamePiece attacker,
    required GamePiece? defender,
  }) {
    if (!from.isAdjacentTo(to)) {
      setState(() {
        _statusMessage = _StatusMessage((strings) => strings.oneStepOnly());
      });
      return;
    }

    if (defender == null) {
      final actor = _currentTurn;
      final playerOneSide = _playerOneSide;
      _playSound(GameSoundEffect.move);
      _saveUndoSnapshot();
      setState(() {
        _board[to.row][to.col] = attacker;
        _board[from.row][from.col] = null;
        _selected = null;
        _statusMessage = _StatusMessage(
          (strings) => strings.movedToEmpty(
            actor,
            playerOneSide,
            attacker,
            computerOpponent: _isVsComputer,
          ),
        );
      });
      _finishTurn(captured: false);
      return;
    }

    if (!defender.revealed) {
      setState(() {
        _statusMessage = _StatusMessage(
          (strings) => strings.cannotMoveToHidden(),
        );
      });
      return;
    }

    if (defender.side == attacker.side) {
      setState(() {
        _statusMessage = _StatusMessage(
          (strings) => strings.cannotCaptureOwn(),
        );
      });
      return;
    }

    if (!_canCapture(attacker: attacker, defender: defender)) {
      setState(() {
        _statusMessage = _StatusMessage(
          (strings) => strings.cannotCapture(attacker, defender),
        );
      });
      return;
    }

    final isMutualElimination = attacker.rank == defender.rank;
    final actor = _currentTurn;
    final playerOneSide = _playerOneSide;
    final defenderSide = defender.side;
    _playSound(GameSoundEffect.capture);
    _saveUndoSnapshot();
    final actionMessage = isMutualElimination
        ? _StatusMessage(
            (strings) => strings.mutualElimination(
              actor: actor,
              playerOneSide: playerOneSide,
              attacker: attacker,
              defenderSide: defenderSide,
              defender: defender,
              computerOpponent: _isVsComputer,
            ),
          )
        : _StatusMessage(
            (strings) => strings.capturedPiece(
              actor: actor,
              playerOneSide: playerOneSide,
              attacker: attacker,
              defenderSide: defenderSide,
              defender: defender,
              computerOpponent: _isVsComputer,
            ),
          );
    setState(() {
      _board[from.row][from.col] = null;
      _board[to.row][to.col] = isMutualElimination ? null : attacker;
      _selected = null;
      _statusMessage = actionMessage;
    });
    _finishTurn(captured: true, actionMessage: actionMessage);
  }

  bool _canCapture({required GamePiece attacker, required GamePiece defender}) {
    return JungleGameRules.canCapture(attacker: attacker, defender: defender);
  }

  bool _isLegalMoveTarget({
    required BoardPosition from,
    required BoardPosition to,
  }) {
    final attacker = _board[from.row][from.col];
    if (attacker == null ||
        !attacker.revealed ||
        attacker.side != _currentTurn ||
        !from.isAdjacentTo(to)) {
      return false;
    }

    final defender = _board[to.row][to.col];
    if (defender == null) {
      return true;
    }
    if (!defender.revealed || defender.side == attacker.side) {
      return false;
    }
    return _canCapture(attacker: attacker, defender: defender);
  }

  List<_MoveDirection> _availableMoveDirections(BoardPosition from) {
    final directions = <_MoveDirection>[];
    for (final direction in _MoveDirection.values) {
      final to = BoardPosition(
        from.row + direction.rowDelta,
        from.col + direction.colDelta,
      );
      if (_isInsideBoard(to) && _isLegalMoveTarget(from: from, to: to)) {
        directions.add(direction);
      }
    }
    return directions;
  }

  bool _isInsideBoard(BoardPosition position) {
    return position.row >= 0 &&
        position.row < boardSize &&
        position.col >= 0 &&
        position.col < boardSize;
  }

  void _finishTurn({
    required bool captured,
    _StatusMessage? actionMessage,
    PieceSide? actor,
  }) {
    final actingSide = actor ?? _currentTurn;
    final turnsWithoutCapture = captured ? 0 : _turnsWithoutCapture + 1;
    final outcome = JungleGameRules.evaluateAfterTurn(
      board: _board,
      actor: actingSide,
      consecutiveNonCaptureTurns: turnsWithoutCapture,
    );

    if (outcome.isDraw) {
      setState(() {
        _isDraw = true;
        _turnsWithoutCapture = turnsWithoutCapture;
        _selected = null;
        _statusMessage = _drawMessage(outcome.reason);
      });
      _cancelAiTurn();
      return;
    }

    final winner = outcome.winner;
    if (winner != null) {
      setState(() {
        _winner = winner;
        _turnsWithoutCapture = turnsWithoutCapture;
        _selected = null;
        _statusMessage = _winnerMessage(winner, outcome.reason);
      });
      _cancelAiTurn();
      return;
    }

    final nextTurn = JungleGameRules.opposite(actingSide);
    setState(() {
      _currentTurn = nextTurn;
      _turnsWithoutCapture = turnsWithoutCapture;
      _statusMessage = _ongoingTurnMessage(
        nextTurn: _currentTurn,
        turnsWithoutCapture: _turnsWithoutCapture,
        actionMessage: actionMessage,
        captureActor: captured ? actingSide : null,
      );
    });
    _scheduleAiTurnIfNeeded();
  }

  int _remainingCount(PieceSide side) {
    return JungleGameRules.remainingCount(_board, side);
  }

  _StatusMessage _winnerMessage(PieceSide winner, GameEndReason? reason) {
    final playerOneSide = _playerOneSide;
    return _StatusMessage(
      (strings) => strings.winnerMessage(
        winner,
        playerOneSide,
        reason,
        computerOpponent: _isVsComputer,
      ),
    );
  }

  _StatusMessage _drawMessage(GameEndReason? reason) {
    return _StatusMessage(
      (strings) =>
          strings.drawMessage(reason, JungleGameRules.nonCaptureDrawLimit),
    );
  }

  _StatusMessage _ongoingTurnMessage({
    required PieceSide nextTurn,
    required int turnsWithoutCapture,
    _StatusMessage? actionMessage,
    PieceSide? captureActor,
  }) {
    final playerOneSide = _playerOneSide;
    if (actionMessage == null) {
      return _StatusMessage(
        (strings) => strings.turnMessage(
          nextTurn,
          playerOneSide,
          turnsWithoutCapture,
          JungleGameRules.nonCaptureDrawLimit,
          computerOpponent: _isVsComputer,
        ),
      );
    }

    if (captureActor == null) {
      return _StatusMessage((strings) {
        final turn = strings.turnMessage(
          nextTurn,
          playerOneSide,
          turnsWithoutCapture,
          JungleGameRules.nonCaptureDrawLimit,
          computerOpponent: _isVsComputer,
        );
        return '${actionMessage.resolve(strings)}\n$turn';
      });
    }

    final opponent = JungleGameRules.opposite(captureActor);
    final remaining = _remainingCount(opponent);
    return _StatusMessage((strings) {
      final turn = strings.turnMessage(
        nextTurn,
        playerOneSide,
        turnsWithoutCapture,
        JungleGameRules.nonCaptureDrawLimit,
        computerOpponent: _isVsComputer,
      );
      return strings.remainingAfterCapture(
        action: actionMessage.resolve(strings),
        opponent: opponent,
        playerOneSide: playerOneSide,
        remaining: remaining,
        turn: turn,
        computerOpponent: _isVsComputer,
      );
    });
  }

  bool _isHighlighted(BoardPosition position) {
    final selected = _selected;
    if (selected == null) {
      return false;
    }
    if (selected == position) {
      return true;
    }

    return _isLegalMoveTarget(from: selected, to: position);
  }

  @override
  Widget build(BuildContext context) {
    final strings = _strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: strings.settingsTooltip,
            icon: const Icon(Icons.settings),
            onPressed: _aiThinking ? null : _showSettings,
          ),
        ],
      ),
      body: _modeSelected
          ? _buildGameBody(strings)
          : _buildModeSelection(strings),
    );
  }

  Widget _buildGameBody(JungleStrings strings) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildBoard(strings),
                    const SizedBox(height: 12),
                    _buildSideCounters(),
                    const SizedBox(height: 16),
                    _buildRulesCard(strings),
                  ],
                ),
              ),
            ),
          ),
          if (_firstFlipToastSide != null) _buildFirstFlipToast(),
        ],
      ),
    );
  }

  Widget _buildModeSelection(JungleStrings strings) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 18),
                Icon(
                  Icons.grid_view_rounded,
                  size: 42,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.modeSelectionTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.modeSelectionSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5E5046),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                _buildModeChoiceButton(
                  key: const ValueKey<String>('start-local-two-player'),
                  icon: Icons.people_alt,
                  title: strings.gameModeOption(GameMode.localTwoPlayer.name),
                  description: strings.localTwoPlayerDescription,
                  onPressed: () => _startGame(GameMode.localTwoPlayer),
                ),
                const SizedBox(height: 14),
                _buildModeChoiceButton(
                  key: const ValueKey<String>('start-vs-computer'),
                  icon: Icons.smart_toy,
                  title: strings.gameModeOption(GameMode.vsComputer.name),
                  description: strings.vsComputerDescription,
                  filled: true,
                  onPressed: () => _startGame(
                    GameMode.vsComputer,
                    difficulty: _aiDifficulty,
                  ),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<AiDifficulty>(
                  key: const ValueKey<String>('mode-selection-ai-difficulty'),
                  initialValue: _aiDifficulty,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: strings.aiDifficultyLabel,
                    prefixIcon: const Icon(Icons.psychology),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final difficulty in AiDifficulty.values)
                      DropdownMenuItem<AiDifficulty>(
                        value: difficulty,
                        child: Text(
                          strings.aiDifficultyOption(difficulty.name),
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _aiDifficulty = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeChoiceButton({
    required Key key,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onPressed,
    bool filled = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = filled ? colorScheme.primary : Colors.white;
    final foregroundColor = filled
        ? colorScheme.onPrimary
        : colorScheme.primary;
    final descriptionColor = filled
        ? colorScheme.onPrimary.withValues(alpha: 0.82)
        : const Color(0xFF5E5046);

    return Material(
      key: key,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: filled
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: foregroundColor.withValues(alpha: filled ? 0.16 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: foregroundColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: descriptionColor,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward, color: foregroundColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstFlipToast() {
    final strings = _strings;
    final side = _firstFlipToastSide!;
    final sideColor = side == PieceSide.red
        ? const Color(0xFFC44536)
        : const Color(0xFF1E6FBA);

    return Positioned(
      key: const ValueKey<String>('first-flip-toast'),
      top: 14,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -18 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: sideColor.withValues(alpha: 0.22)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(width: 7, color: sideColor),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: sideColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.flag_rounded,
                                    color: sideColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        strings.firstFlipToastTitle(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: sideColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        strings.firstFlipToastMessage(
                                          side,
                                          computerOpponent: _isVsComputer,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF3F332B),
                                          fontSize: 14,
                                          height: 1.35,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final strings = _strings;
    final turnColor = _playerOneSide == null
        ? const Color(0xFF7A593F)
        : _currentTurn == PieceSide.red
        ? const Color(0xFFC44536)
        : const Color(0xFF1E6FBA);
    final statusLineHeight = MediaQuery.textScalerOf(context).scale(16) * 1.5;
    final heading = _winner != null
        ? strings.victoryHeading(
            _winner!,
            _playerOneSide,
            computerOpponent: _isVsComputer,
          )
        : _isDraw
        ? strings.drawHeading
        : _playerOneSide == null
        ? strings.openingHeading
        : strings.currentTurn(
            _currentTurn,
            _playerOneSide,
            computerOpponent: _isVsComputer,
          );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _winner != null || _isDraw
                            ? Colors.grey
                            : turnColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        heading,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildStatusActions(strings),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: statusLineHeight * 3,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  _statusMessage.resolve(strings),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusActions(JungleStrings strings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Tooltip(
            message: _canUndo ? strings.undoButton : strings.undoUnavailable,
            child: OutlinedButton.icon(
              key: const ValueKey<String>('undo-button'),
              onPressed: _canUndo && !_undoInProgress && !_aiThinking
                  ? _onUndoPressed
                  : null,
              icon: const Icon(Icons.undo),
              label: Text(strings.undoButton, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FilledButton.icon(
            key: const ValueKey<String>('reset-button'),
            onPressed: _undoInProgress || _aiThinking ? null : _onResetPressed,
            icon: const Icon(Icons.refresh),
            label: Text(strings.resetButton, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }

  Widget _buildSideCounters() {
    return Row(
      key: const ValueKey<String>('side-counters'),
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
    );
  }

  Widget _buildSideCounter({required PieceSide side, required int count}) {
    final strings = _strings;
    final color = side == PieceSide.red
        ? const Color(0xFFC44536)
        : const Color(0xFF1E6FBA);

    return Container(
      key: ValueKey<String>('${side.name}-remaining-counter'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            strings.sideRemaining(
              side,
              _playerOneSide,
              computerOpponent: _isVsComputer,
            ),
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            strings.piecesCount(count),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(JungleStrings strings) {
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
        child: Stack(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: boardSize * boardSize,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: boardSize,
                crossAxisSpacing: _boardGap,
                mainAxisSpacing: _boardGap,
              ),
              itemBuilder: (context, index) {
                final row = index ~/ boardSize;
                final col = index % boardSize;
                final position = BoardPosition(row, col);
                final piece = _board[row][col];
                return _BoardCell(
                  key: ValueKey<String>('board-cell-$row-$col'),
                  piece: piece,
                  strings: strings,
                  highlighted: _isHighlighted(position),
                  onTap: () => _onCellTapped(position),
                );
              },
            ),
            if (_selected != null)
              _MoveArrowOverlay(
                selected: _selected!,
                directions: _availableMoveDirections(_selected!),
              ),
            if (_aiThinking) _buildAiThinkingOverlay(),
            if (_showUndoAnimation) _buildUndoAnimationOverlay(),
            if (_winner != null || _isDraw) _buildGameOverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildUndoAnimationOverlay() {
    final strings = _strings;
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          key: const ValueKey<String>('undo-animation-overlay'),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 720),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0, 1).toDouble(),
                  child: Transform.rotate(
                    angle: -pi * value,
                    child: Transform.scale(
                      scale: 0.72 + value * 0.28,
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F0E3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.undo, size: 30, color: Color(0xFFB3541E)),
                    const SizedBox(width: 10),
                    Text(
                      strings.undoingLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiThinkingOverlay() {
    final strings = _strings;
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          key: const ValueKey<String>('ai-thinking-overlay'),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF6),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.smart_toy, color: Color(0xFF1E6FBA)),
                  const SizedBox(width: 10),
                  Text(
                    strings.aiThinking(
                      _currentTurn,
                      _playerOneSide,
                      computerOpponent: _isVsComputer,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF3F332B),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final strings = _strings;
    final label = _winner == null
        ? strings.drawHeading
        : strings.gameOverWinner(
            _winner!,
            _playerOneSide,
            computerOpponent: _isVsComputer,
          );
    final accentColor = _winner == PieceSide.blue
        ? const Color(0xFF76B7FF)
        : const Color(0xFFFFA39A);

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                strings.gameOverPrompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRulesCard(JungleStrings strings) {
    final rules = strings.rules(JungleGameRules.nonCaptureDrawLimit);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.rulesTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final rule in rules) ...[
              Text(rule),
              if (rule != rules.last) const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    super.key,
    required this.piece,
    required this.strings,
    required this.highlighted,
    required this.onTap,
  });

  final GamePiece? piece;
  final JungleStrings strings;
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
            border: Border.all(
              color: borderColor,
              width: highlighted ? 3 : 1.5,
            ),
          ),
          child: _buildCellContent(),
        ),
      ),
    );
  }

  Widget _buildCellContent() {
    final cellPiece = piece;
    if (cellPiece == null) {
      return const SizedBox.expand();
    }
    if (cellPiece.revealed) {
      return _RevealedPiece(piece: cellPiece, strings: strings);
    }
    return const Center(
      child: Text(
        '?',
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: Colors.white,
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

class _MoveArrowOverlay extends StatelessWidget {
  const _MoveArrowOverlay({required this.selected, required this.directions});

  final BoardPosition selected;
  final List<_MoveDirection> directions;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boardSide = min(constraints.maxWidth, constraints.maxHeight);
            final cellSize =
                (boardSide - _boardGap * (JungleGameRules.boardSize - 1)) /
                JungleGameRules.boardSize;
            final step = cellSize + _boardGap;
            final arrowSize = min(36.0, max(28.0, cellSize * 0.28));
            final selectedCenter = Offset(
              selected.col * step + cellSize / 2,
              selected.row * step + cellSize / 2,
            );

            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (final direction in directions)
                  _buildPositionedArrow(
                    direction: direction,
                    selectedCenter: selectedCenter,
                    step: step,
                    arrowSize: arrowSize,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPositionedArrow({
    required _MoveDirection direction,
    required Offset selectedCenter,
    required double step,
    required double arrowSize,
  }) {
    final targetCenter = selectedCenter.translate(
      direction.colDelta * step,
      direction.rowDelta * step,
    );
    final arrowCenter = Offset.lerp(selectedCenter, targetCenter, 0.5)!;

    return Positioned(
      left: arrowCenter.dx - arrowSize / 2,
      top: arrowCenter.dy - arrowSize / 2,
      width: arrowSize,
      height: arrowSize,
      child: _FloatingMoveArrow(direction: direction),
    );
  }
}

class _FloatingMoveArrow extends StatelessWidget {
  const _FloatingMoveArrow({required this.direction});

  final _MoveDirection direction;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('move-direction-arrow-${direction.name}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: 0.72 * value,
          child: Transform.translate(
            offset: direction.entryOffset(6 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: const Offset(0, 1.5),
            child: CustomPaint(
              painter: _MoveArrowPainter(
                direction: direction,
                color: Colors.black.withValues(alpha: 0.18),
              ),
            ),
          ),
          CustomPaint(
            painter: _MoveArrowPainter(
              direction: direction,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoveArrowPainter extends CustomPainter {
  const _MoveArrowPainter({required this.direction, required this.color});

  final _MoveDirection direction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.41)
      ..lineTo(size.width * 0.58, size.height * 0.41)
      ..lineTo(size.width * 0.58, size.height * 0.24)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.58, size.height * 0.76)
      ..lineTo(size.width * 0.58, size.height * 0.59)
      ..lineTo(size.width * 0.12, size.height * 0.59)
      ..close();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas
      ..translate(size.width / 2, size.height / 2)
      ..rotate(direction.radians)
      ..translate(-size.width / 2, -size.height / 2)
      ..drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MoveArrowPainter oldDelegate) {
    return oldDelegate.direction != direction || oldDelegate.color != color;
  }
}

class _RevealedPiece extends StatelessWidget {
  const _RevealedPiece({required this.piece, required this.strings});

  static const Map<int, String> animalAssets = <int, String>{
    1: 'assets/images/animals/mouse.svg',
    2: 'assets/images/animals/cat.svg',
    3: 'assets/images/animals/dog.svg',
    4: 'assets/images/animals/wolf.svg',
    5: 'assets/images/animals/leopard.svg',
    6: 'assets/images/animals/tiger.svg',
    7: 'assets/images/animals/lion.svg',
    8: 'assets/images/animals/elephant.svg',
  };

  static const Map<int, double> animalScaleFactors = <int, double>{
    1: 0.66,
    3: 0.64,
    4: 0.68,
    5: 0.7,
    8: 0.66,
  };

  static const Map<int, Offset> animalCenterOffsets = <int, Offset>{
    1: Offset(0, -0.03),
    3: Offset(0, 0.05),
    5: Offset(0.02, -0.1),
    8: Offset(0.05, -0.02),
  };

  final GamePiece piece;
  final JungleStrings strings;

  @override
  Widget build(BuildContext context) {
    final animalAsset = animalAssets[piece.rank];

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = min(constraints.maxWidth, constraints.maxHeight);
        final edgeInset = tileSize * 0.1;
        final badgeSize = tileSize * 0.62;
        final animalSize = badgeSize * (animalScaleFactors[piece.rank] ?? 0.68);
        final centerOffset = animalCenterOffsets[piece.rank] ?? Offset.zero;

        return Stack(
          children: [
            Positioned(
              left: edgeInset,
              top: edgeInset * 0.75,
              child: Text(
                '${piece.rank}',
                style: TextStyle(
                  fontSize: tileSize * 0.35,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              right: edgeInset * 0.55,
              bottom: edgeInset * 0.5,
              child: Semantics(
                label: strings.animalName(piece.rank),
                image: true,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: tileSize * 0.08,
                        offset: Offset(0, tileSize * 0.035),
                      ),
                    ],
                  ),
                  child: animalAsset == null
                      ? const SizedBox.shrink()
                      : Transform.translate(
                          offset: Offset(
                            centerOffset.dx * badgeSize,
                            centerOffset.dy * badgeSize,
                          ),
                          child: SizedBox.square(
                            dimension: animalSize,
                            child: SvgPicture.asset(
                              animalAsset,
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
