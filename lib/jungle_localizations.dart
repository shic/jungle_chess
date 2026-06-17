import 'package:flutter/widgets.dart';
import 'package:jungle_chess/game_rules.dart';

const String defaultLanguageCode = 'zh';

class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });

  final String code;
  final String nativeName;
  final String englishName;

  Locale get locale => Locale(code);

  String get menuLabel {
    if (nativeName == englishName) {
      return nativeName;
    }
    return '$nativeName ($englishName)';
  }

  static const List<AppLanguage> supported = <AppLanguage>[
    AppLanguage(code: 'zh', nativeName: '简体中文', englishName: 'Chinese'),
    AppLanguage(code: 'en', nativeName: 'English', englishName: 'English'),
    AppLanguage(code: 'es', nativeName: 'Español', englishName: 'Spanish'),
    AppLanguage(code: 'fr', nativeName: 'Français', englishName: 'French'),
    AppLanguage(code: 'de', nativeName: 'Deutsch', englishName: 'German'),
    AppLanguage(code: 'it', nativeName: 'Italiano', englishName: 'Italian'),
    AppLanguage(code: 'pt', nativeName: 'Português', englishName: 'Portuguese'),
    AppLanguage(code: 'nl', nativeName: 'Nederlands', englishName: 'Dutch'),
    AppLanguage(code: 'pl', nativeName: 'Polski', englishName: 'Polish'),
    AppLanguage(code: 'ro', nativeName: 'Română', englishName: 'Romanian'),
    AppLanguage(code: 'ru', nativeName: 'Русский', englishName: 'Russian'),
    AppLanguage(code: 'uk', nativeName: 'Українська', englishName: 'Ukrainian'),
    AppLanguage(code: 'tr', nativeName: 'Türkçe', englishName: 'Turkish'),
    AppLanguage(code: 'el', nativeName: 'Ελληνικά', englishName: 'Greek'),
    AppLanguage(code: 'sv', nativeName: 'Svenska', englishName: 'Swedish'),
    AppLanguage(code: 'cs', nativeName: 'Čeština', englishName: 'Czech'),
    AppLanguage(code: 'hu', nativeName: 'Magyar', englishName: 'Hungarian'),
    AppLanguage(code: 'da', nativeName: 'Dansk', englishName: 'Danish'),
    AppLanguage(code: 'fi', nativeName: 'Suomi', englishName: 'Finnish'),
    AppLanguage(code: 'no', nativeName: 'Norsk', englishName: 'Norwegian'),
    AppLanguage(code: 'sk', nativeName: 'Slovenčina', englishName: 'Slovak'),
    AppLanguage(code: 'bg', nativeName: 'Български', englishName: 'Bulgarian'),
    AppLanguage(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi'),
    AppLanguage(code: 'ar', nativeName: 'العربية', englishName: 'Arabic'),
    AppLanguage(code: 'bn', nativeName: 'বাংলা', englishName: 'Bengali'),
    AppLanguage(code: 'ur', nativeName: 'اردو', englishName: 'Urdu'),
    AppLanguage(
      code: 'id',
      nativeName: 'Bahasa Indonesia',
      englishName: 'Indonesian',
    ),
    AppLanguage(code: 'ja', nativeName: '日本語', englishName: 'Japanese'),
    AppLanguage(code: 'pa', nativeName: 'ਪੰਜਾਬੀ', englishName: 'Punjabi'),
    AppLanguage(
      code: 'vi',
      nativeName: 'Tiếng Việt',
      englishName: 'Vietnamese',
    ),
    AppLanguage(code: 'ko', nativeName: '한국어', englishName: 'Korean'),
  ];

  static List<Locale> get supportedLocales {
    return <Locale>[for (final language in supported) language.locale];
  }

  static AppLanguage byCode(String code) {
    return supported.firstWhere(
      (language) => language.code == code,
      orElse: () => supported.first,
    );
  }

  static String normalize(String code) {
    final normalized = code.toLowerCase().split(RegExp('[-_]')).first;
    final isSupported = supported.any(
      (language) => language.code == normalized,
    );
    return isSupported ? normalized : defaultLanguageCode;
  }
}

class JungleStrings {
  JungleStrings._(this.language, this._strings);

  factory JungleStrings.forCode(String code) {
    final normalized = AppLanguage.normalize(code);
    return JungleStrings._(AppLanguage.byCode(normalized), <String, String>{
      ..._englishStrings,
      ...(_localizedStrings[normalized] ?? const <String, String>{}),
    });
  }

  final AppLanguage language;
  final Map<String, String> _strings;

  Locale get locale => language.locale;

  String get appTitle => _lookup('appTitle');
  String get settingsTooltip => _lookup('settingsTooltip');
  String get settingsTitle => _lookup('settingsTitle');
  String get soundEffects => _lookup('soundEffects');
  String get languageLabel => _lookup('languageLabel');
  String get done => _lookup('done');
  String get resetButton => _lookup('resetButton');
  String get resetTitle => _lookup('resetTitle');
  String get resetContent => _lookup('resetContent');
  String get continueGame => _lookup('continueGame');
  String get undoButton => _lookup('undoButton');
  String get undoUnavailable => _lookup('undoUnavailable');
  String get undoTitle => _lookup('undoTitle');
  String get undoContent => _lookup('undoContent');
  String get cancel => _lookup('cancel');
  String get watchAdAndUndo => _lookup('watchAdAndUndo');
  String get undoingLabel => _lookup('undoingLabel');
  String get rulesTitle => _lookup('rulesTitle');
  String get drawHeading => _lookup('drawHeading');
  String get gameOverPrompt => _lookup('gameOverPrompt');

  String sideLabel(PieceSide side) {
    return _lookup('side.${side.name}');
  }

  String animalName(int rank) {
    return _lookup('animal.$rank');
  }

  String pieceLabel(GamePiece piece) {
    return _format(_lookup('pieceLabel'), <String, String>{
      'rank': '${piece.rank}',
      'animal': animalName(piece.rank),
    });
  }

  String openingTurn(PieceSide side) {
    return _format(_lookup('openingTurn'), <String, String>{
      'side': sideLabel(side),
    });
  }

  String adThenUndo() => _lookup('adThenUndo');

  String undoingStatus() => _lookup('undoingStatus');

  String undoRestored({required bool opening, required String next}) {
    return _format(
      _lookup(opening ? 'undoRestoredOpening' : 'undoRestoredPrevious'),
      <String, String>{'next': next},
    );
  }

  String undoTurn(PieceSide side, int turnsWithoutCapture, int limit) {
    return _format(_lookup('undoTurn'), <String, String>{
      'side': sideLabel(side),
      'count': '$turnsWithoutCapture',
      'limit': '$limit',
    });
  }

  String selectionCanceled() => _lookup('selectionCanceled');

  String selectedPiece(PieceSide side, GamePiece piece) {
    return _format(_lookup('selectedPiece'), <String, String>{
      'side': sideLabel(side),
      'piece': pieceLabel(piece),
    });
  }

  String choosePieceFirst() => _lookup('choosePieceFirst');

  String selectedPieceMissing() => _lookup('selectedPieceMissing');

  String flippedPiece(PieceSide actor, PieceSide pieceSide, GamePiece piece) {
    return _format(_lookup('flippedPiece'), <String, String>{
      'actor': sideLabel(actor),
      'side': sideLabel(pieceSide),
      'piece': pieceLabel(piece),
    });
  }

  String oneStepOnly() => _lookup('oneStepOnly');

  String movedToEmpty(PieceSide actor, GamePiece piece) {
    return _format(_lookup('movedToEmpty'), <String, String>{
      'actor': sideLabel(actor),
      'piece': pieceLabel(piece),
    });
  }

  String cannotMoveToHidden() => _lookup('cannotMoveToHidden');

  String cannotCaptureOwn() => _lookup('cannotCaptureOwn');

  String cannotCapture(GamePiece attacker, GamePiece defender) {
    return _format(_lookup('cannotCapture'), <String, String>{
      'attacker': pieceLabel(attacker),
      'defender': pieceLabel(defender),
    });
  }

  String mutualElimination({
    required PieceSide actor,
    required GamePiece attacker,
    required PieceSide defenderSide,
    required GamePiece defender,
  }) {
    return _format(_lookup('mutualElimination'), <String, String>{
      'actor': sideLabel(actor),
      'attacker': pieceLabel(attacker),
      'defenderSide': sideLabel(defenderSide),
      'defender': pieceLabel(defender),
    });
  }

  String capturedPiece({
    required PieceSide actor,
    required GamePiece attacker,
    required PieceSide defenderSide,
    required GamePiece defender,
  }) {
    return _format(_lookup('capturedPiece'), <String, String>{
      'actor': sideLabel(actor),
      'attacker': pieceLabel(attacker),
      'defenderSide': sideLabel(defenderSide),
      'defender': pieceLabel(defender),
    });
  }

  String winnerMessage(PieceSide winner, GameEndReason? reason) {
    return _format(
      _lookup(
        reason == GameEndReason.noLegalAction
            ? 'winnerNoLegalAction'
            : 'winnerElimination',
      ),
      <String, String>{'side': sideLabel(winner)},
    );
  }

  String drawMessage(GameEndReason? reason, int limit) {
    final key = switch (reason) {
      GameEndReason.nonCaptureLimit => 'drawNonCaptureLimit',
      GameEndReason.noLegalActions => 'drawNoLegalActions',
      _ => 'drawMutualElimination',
    };
    return _format(_lookup(key), <String, String>{'limit': '$limit'});
  }

  String turnMessage(PieceSide side, int turnsWithoutCapture, int limit) {
    return _format(_lookup('turnMessage'), <String, String>{
      'side': sideLabel(side),
      'count': '$turnsWithoutCapture',
      'limit': '$limit',
    });
  }

  String remainingAfterCapture({
    required String action,
    required PieceSide opponent,
    required int remaining,
    required String turn,
  }) {
    return _format(_lookup('remainingAfterCapture'), <String, String>{
      'action': action,
      'side': sideLabel(opponent),
      'remaining': '$remaining',
      'turn': turn,
    });
  }

  String currentTurn(PieceSide side) {
    return _format(_lookup('currentTurn'), <String, String>{
      'side': sideLabel(side),
    });
  }

  String victoryHeading(PieceSide side) {
    return _format(_lookup('victoryHeading'), <String, String>{
      'side': sideLabel(side),
    });
  }

  String sideRemaining(PieceSide side) {
    return _format(_lookup('sideRemaining'), <String, String>{
      'side': sideLabel(side),
    });
  }

  String piecesCount(int count) {
    return _format(_lookup('piecesCount'), <String, String>{'count': '$count'});
  }

  String gameOverWinner(PieceSide side) {
    return _format(_lookup('gameOverWinner'), <String, String>{
      'side': sideLabel(side),
    });
  }

  List<String> rules(int limit) {
    return <String>[
      for (var index = 1; index <= 9; index++)
        _format(_lookup('rule$index'), <String, String>{'limit': '$limit'}),
    ];
  }

  String _lookup(String key) {
    return _strings[key] ?? _englishStrings[key] ?? key;
  }

  String _format(String template, Map<String, String> values) {
    var output = template;
    for (final entry in values.entries) {
      output = output.replaceAll('{${entry.key}}', entry.value);
    }
    return output;
  }
}

const Map<String, String> _englishStrings = <String, String>{
  'appTitle': 'Animal Kings',
  'settingsTooltip': 'Settings',
  'settingsTitle': 'Settings',
  'soundEffects': 'Sound effects',
  'languageLabel': 'Interface language',
  'done': 'Done',
  'resetButton': 'Restart',
  'resetTitle': 'Restart?',
  'resetContent': 'The current game will be cleared.',
  'continueGame': 'Keep playing',
  'undoButton': 'Undo',
  'undoUnavailable': 'Already at the opening',
  'undoTitle': 'Confirm undo?',
  'undoContent': 'After watching an ad, the game will go back one move.',
  'cancel': 'Cancel',
  'watchAdAndUndo': 'Watch ad and undo',
  'undoingLabel': 'Undoing',
  'rulesTitle': 'Rules',
  'drawHeading': 'Draw',
  'gameOverPrompt': 'Tap restart to begin the next game',
  'side.red': 'Red',
  'side.blue': 'Blue',
  'animal.1': 'Rat',
  'animal.2': 'Cat',
  'animal.3': 'Dog',
  'animal.4': 'Wolf',
  'animal.5': 'Leopard',
  'animal.6': 'Tiger',
  'animal.7': 'Lion',
  'animal.8': 'Elephant',
  'pieceLabel': 'No. {rank} {animal}',
  'openingTurn':
      '{side} starts: each turn, flip one hidden piece or move one of your pieces.',
  'adThenUndo': 'The move will be undone after the ad.',
  'undoingStatus': 'Undoing...',
  'undoRestoredOpening': 'Undone, back to the opening. {next}',
  'undoRestoredPrevious': 'Undone, back to the previous move. {next}',
  'undoTurn':
      "It is {side}'s turn: flip a piece or move one step. Non-captures {count}/{limit}.",
  'selectionCanceled':
      'Selection canceled. You can flip a piece or choose a piece again.',
  'selectedPiece': '{side} selected {piece}.',
  'choosePieceFirst':
      'Flip a hidden piece first, or select one of your pieces before moving.',
  'selectedPieceMissing': 'The selected piece is gone. Please choose again.',
  'flippedPiece': '{actor} flipped {side} {piece}.',
  'oneStepOnly': 'You can only move one square up, down, left, or right.',
  'movedToEmpty': '{actor} moved {piece} to an empty square.',
  'cannotMoveToHidden': 'You cannot move onto a hidden piece. Flip it instead.',
  'cannotCaptureOwn': 'You cannot capture your own piece.',
  'cannotCapture': '{attacker} cannot capture {defender}.',
  'mutualElimination':
      "{actor}'s {attacker} and {defenderSide}'s {defender} eliminated each other.",
  'capturedPiece': "{actor}'s {attacker} captured {defenderSide}'s {defender}.",
  'winnerNoLegalAction': '{side} wins. The opponent has no legal action left.',
  'winnerElimination': '{side} wins after capturing all opposing pieces.',
  'drawNonCaptureLimit': '{limit} turns without a capture. Draw.',
  'drawNoLegalActions': 'Neither side has a legal action. Draw.',
  'drawMutualElimination': 'The last pieces eliminated each other. Draw.',
  'turnMessage':
      "{side}'s turn: flip a piece or move one step. Non-captures {count}/{limit}.",
  'remainingAfterCapture':
      '{action} {side} has {remaining} piece(s) left, including hidden pieces.\n{turn}',
  'currentTurn': 'Current turn: {side}',
  'victoryHeading': '{side} victory',
  'sideRemaining': '{side} remaining',
  'piecesCount': '{count} piece(s)',
  'gameOverWinner': '{side} wins',
  'rule1':
      '1. The board is 4 x 4, with 16 pieces. Red and Blue each have ranks 1 to 8.',
  'rule2':
      '2. On each turn choose one action: flip a hidden piece, or move one of your revealed pieces one step.',
  'rule3':
      '3. Pieces move only up, down, left, or right. No diagonals and no multi-square moves.',
  'rule4':
      '4. Captures must target a revealed opposing piece with an equal or lower number. Special rule: 1 can capture 8, but 8 cannot capture 1.',
  'rule5': '5. If both numbers are the same, both pieces disappear.',
  'rule6':
      '6. Capture all opposing pieces to win. If the final pieces disappear together, the game is a draw.',
  'rule7':
      '7. If there are no hidden pieces and one side has no legal action, the opponent wins. If both sides cannot act, it is a draw.',
  'rule8':
      '8. {limit} consecutive turns without a capture is a draw. The counter resets after a capture.',
  'rule9':
      '9. Captured squares become empty, and pieces may move into them later.',
};

const Map<String, String> _chineseStrings = <String, String>{
  'settingsTooltip': '设置',
  'settingsTitle': '设置',
  'soundEffects': '音效',
  'languageLabel': '界面语言',
  'done': '完成',
  'resetButton': '重新开始',
  'resetTitle': '重新开始？',
  'resetContent': '当前棋局会被清空。',
  'continueGame': '继续游戏',
  'undoButton': '悔棋',
  'undoUnavailable': '已经是开局',
  'undoTitle': '确认悔棋？',
  'undoContent': '观看广告后将回退到上一步。',
  'cancel': '取消',
  'watchAdAndUndo': '观看广告并悔棋',
  'undoingLabel': '悔棋中',
  'rulesTitle': '规则说明',
  'drawHeading': '平局',
  'gameOverPrompt': '点击重新开始进入下一局',
  'side.red': '红',
  'side.blue': '蓝',
  'animal.1': '鼠',
  'animal.2': '猫',
  'animal.3': '狗',
  'animal.4': '狼',
  'animal.5': '豹',
  'animal.6': '虎',
  'animal.7': '狮',
  'animal.8': '象',
  'pieceLabel': '{rank}号{animal}',
  'openingTurn': '{side}方先手：每回合可以翻一张牌，或者移动一枚自己的棋子。',
  'adThenUndo': '广告结束后将悔棋。',
  'undoingStatus': '悔棋中...',
  'undoRestoredOpening': '已悔棋，回到开局。{next}',
  'undoRestoredPrevious': '已悔棋，回到上一步。{next}',
  'undoTurn': '轮到{side}方：翻牌或走一步。连续未吃子 {count}/{limit}。',
  'selectionCanceled': '已取消选中，可以重新选择翻牌或走棋。',
  'selectedPiece': '{side}方已选中 {piece}。',
  'choosePieceFirst': '请先翻一张暗棋，或者选中自己的棋子再走一步。',
  'selectedPieceMissing': '选中的棋子不存在了，请重新操作。',
  'flippedPiece': '{actor}方翻开了 {side}方 {piece}。',
  'oneStepOnly': '每次只能上下左右移动一步。',
  'movedToEmpty': '{actor}方把 {piece} 移动到空位。',
  'cannotMoveToHidden': '不能走到暗棋上，只能翻开它。',
  'cannotCaptureOwn': '不能吃自己的棋子。',
  'cannotCapture': '{attacker} 不能吃掉 {defender}。',
  'mutualElimination':
      '{actor}方的 {attacker} 与 {defenderSide}方的 {defender} 同归于尽。',
  'capturedPiece': '{actor}方用 {attacker} 吃掉了 {defenderSide}方 {defender}。',
  'winnerNoLegalAction': '{side}方获胜，对手已经没有可执行的操作。',
  'winnerElimination': '{side}方获胜，已吃光对手所有棋子。',
  'drawNonCaptureLimit': '连续 {limit} 个回合没有吃子，平局。',
  'drawNoLegalActions': '双方都没有可执行的操作，平局。',
  'drawMutualElimination': '双方最后的棋子同归于尽，平局。',
  'turnMessage': '轮到{side}方：翻牌或走一步。连续未吃子 {count}/{limit}。',
  'remainingAfterCapture': '{action} {side}方还剩 {remaining} 枚（含暗棋）。\n{turn}',
  'currentTurn': '当前回合：{side}方',
  'victoryHeading': '{side}方胜利',
  'sideRemaining': '{side}方剩余',
  'piecesCount': '{count} 枚',
  'gameOverWinner': '{side}方赢',
  'rule1': '1. 棋盘为 4 x 4，共 16 枚棋子，红蓝双方各有 1 到 8 号。',
  'rule2': '2. 每回合只能二选一：翻开一张暗棋，或者移动一枚自己的明棋一步。',
  'rule3': '3. 只能上下左右移动，不能斜走，也不能一次移动多格。',
  'rule4': '4. 吃子时必须是对方明棋，且数字相同或更大；特殊规则是 1 号可以吃 8 号，8 号不能吃 1 号。',
  'rule5': '5. 如果双方数字相同，互吃后两枚棋子都会消失。',
  'rule6': '6. 吃光对手所有棋子获胜；如果双方最后的棋子同归于尽，则判为平局。',
  'rule7': '7. 如果没有暗棋且一方没有可执行操作，对手获胜；双方都无法行动则平局。',
  'rule8': '8. 连续 {limit} 个回合没有吃子，判为平局；吃子后重新计数。',
  'rule9': '9. 被吃掉的位置会变成空格，后续可以移动进去。',
};

const Map<String, String> _spanishStrings = <String, String>{
  'settingsTooltip': 'Ajustes',
  'settingsTitle': 'Ajustes',
  'soundEffects': 'Sonidos',
  'languageLabel': 'Idioma de la interfaz',
  'done': 'Listo',
  'resetButton': 'Reiniciar',
  'resetTitle': '¿Reiniciar?',
  'resetContent': 'La partida actual se borrará.',
  'continueGame': 'Seguir jugando',
  'undoButton': 'Deshacer',
  'undoUnavailable': 'Ya estás en el inicio',
  'undoTitle': '¿Confirmar deshacer?',
  'undoContent': 'Tras ver un anuncio, la partida volverá un movimiento atrás.',
  'cancel': 'Cancelar',
  'watchAdAndUndo': 'Ver anuncio y deshacer',
  'undoingLabel': 'Deshaciendo',
  'rulesTitle': 'Reglas',
  'drawHeading': 'Empate',
  'gameOverPrompt': 'Toca reiniciar para empezar otra partida',
  'side.red': 'Rojo',
  'side.blue': 'Azul',
  'animal.1': 'Rata',
  'animal.2': 'Gato',
  'animal.3': 'Perro',
  'animal.4': 'Lobo',
  'animal.5': 'Leopardo',
  'animal.6': 'Tigre',
  'animal.7': 'León',
  'animal.8': 'Elefante',
  'pieceLabel': 'N.º {rank} {animal}',
  'openingTurn':
      '{side} empieza: en cada turno, voltea una pieza oculta o mueve una pieza propia.',
  'adThenUndo': 'El movimiento se deshará después del anuncio.',
  'undoingStatus': 'Deshaciendo...',
  'undoRestoredOpening': 'Deshecho, vuelta al inicio. {next}',
  'undoRestoredPrevious': 'Deshecho, vuelta al movimiento anterior. {next}',
  'undoTurn':
      'Turno de {side}: voltea o mueve un paso. Sin capturas {count}/{limit}.',
  'selectionCanceled':
      'Selección cancelada. Puedes voltear o elegir otra pieza.',
  'selectedPiece': '{side} seleccionó {piece}.',
  'choosePieceFirst':
      'Primero voltea una pieza oculta, o selecciona una pieza propia para moverla.',
  'selectedPieceMissing': 'La pieza seleccionada ya no está. Elige otra.',
  'flippedPiece': '{actor} volteó {piece} de {side}.',
  'oneStepOnly':
      'Solo puedes mover una casilla arriba, abajo, izquierda o derecha.',
  'movedToEmpty': '{actor} movió {piece} a una casilla vacía.',
  'cannotMoveToHidden': 'No puedes moverte sobre una pieza oculta. Voltèala.',
  'cannotCaptureOwn': 'No puedes capturar tu propia pieza.',
  'cannotCapture': '{attacker} no puede capturar {defender}.',
  'mutualElimination':
      '{attacker} de {actor} y {defender} de {defenderSide} se eliminaron mutuamente.',
  'capturedPiece':
      '{attacker} de {actor} capturó {defender} de {defenderSide}.',
  'winnerNoLegalAction': '{side} gana. El rival no tiene acciones legales.',
  'winnerElimination': '{side} gana al capturar todas las piezas rivales.',
  'drawNonCaptureLimit': '{limit} turnos sin captura. Empate.',
  'drawNoLegalActions': 'Ningún bando tiene acciones legales. Empate.',
  'drawMutualElimination':
      'Las últimas piezas se eliminaron mutuamente. Empate.',
  'turnMessage':
      'Turno de {side}: voltea o mueve un paso. Sin capturas {count}/{limit}.',
  'remainingAfterCapture':
      '{action} A {side} le quedan {remaining} pieza(s), incluidas las ocultas.\n{turn}',
  'currentTurn': 'Turno actual: {side}',
  'victoryHeading': 'Victoria de {side}',
  'sideRemaining': 'Restantes de {side}',
  'piecesCount': '{count} pieza(s)',
  'gameOverWinner': '{side} gana',
  'rule1':
      '1. El tablero es de 4 x 4, con 16 piezas. Rojo y Azul tienen rangos del 1 al 8.',
  'rule2':
      '2. En cada turno elige una acción: voltear una pieza oculta o mover una pieza revelada un paso.',
  'rule3':
      '3. Las piezas solo se mueven arriba, abajo, izquierda o derecha. No hay diagonales ni saltos.',
  'rule4':
      '4. Para capturar, la pieza rival debe estar revelada y tener número igual o menor. Regla especial: 1 captura a 8, pero 8 no captura a 1.',
  'rule5': '5. Si los números son iguales, ambas piezas desaparecen.',
  'rule6':
      '6. Ganas al capturar todas las piezas rivales. Si las últimas desaparecen juntas, hay empate.',
  'rule7':
      '7. Si no quedan piezas ocultas y un bando no puede actuar, gana el rival. Si ninguno puede actuar, hay empate.',
  'rule8':
      '8. {limit} turnos seguidos sin captura son empate. El contador se reinicia al capturar.',
  'rule9':
      '9. Las casillas capturadas quedan vacías y se pueden ocupar después.',
};

const Map<String, String> _italianStrings = <String, String>{
  'settingsTooltip': 'Impostazioni',
  'settingsTitle': 'Impostazioni',
  'soundEffects': 'Effetti sonori',
  'languageLabel': 'Lingua interfaccia',
  'done': 'Fine',
  'resetButton': 'Ricomincia',
  'resetTitle': 'Ricominciare?',
  'resetContent': 'La partita attuale verrà cancellata.',
  'continueGame': 'Continua',
  'undoButton': 'Annulla',
  'undoUnavailable': 'Sei già all’inizio',
  'undoTitle': 'Confermare annullamento?',
  'undoContent':
      'Dopo aver guardato un annuncio, tornerai alla mossa precedente.',
  'cancel': 'Annulla',
  'watchAdAndUndo': 'Guarda annuncio e annulla',
  'undoingLabel': 'Annullamento',
  'rulesTitle': 'Regole',
  'drawHeading': 'Patta',
  'gameOverPrompt': 'Tocca ricomincia per iniziare la prossima partita',
  'side.red': 'Rosso',
  'side.blue': 'Blu',
  'animal.1': 'Topo',
  'animal.2': 'Gatto',
  'animal.3': 'Cane',
  'animal.4': 'Lupo',
  'animal.5': 'Leopardo',
  'animal.6': 'Tigre',
  'animal.7': 'Leone',
  'animal.8': 'Elefante',
  'pieceLabel': 'N. {rank} {animal}',
  'openingTurn':
      '{side} inizia: a ogni turno scopri una pedina nascosta o muovi una tua pedina.',
  'adThenUndo': 'La mossa verrà annullata dopo l’annuncio.',
  'undoingStatus': 'Annullamento...',
  'undoRestoredOpening': 'Annullato, ritorno all’inizio. {next}',
  'undoRestoredPrevious': 'Annullato, ritorno alla mossa precedente. {next}',
  'undoTurn':
      'Tocca a {side}: scopri o muovi di un passo. Senza catture {count}/{limit}.',
  'selectionCanceled':
      'Selezione annullata. Puoi scoprire o scegliere un’altra pedina.',
  'selectedPiece': '{side} ha selezionato {piece}.',
  'choosePieceFirst':
      'Scopri prima una pedina nascosta, oppure seleziona una tua pedina da muovere.',
  'selectedPieceMissing': 'La pedina selezionata non c’è più. Scegli di nuovo.',
  'flippedPiece': '{actor} ha scoperto {piece} di {side}.',
  'oneStepOnly':
      'Puoi muovere solo di una casella in alto, in basso, a sinistra o a destra.',
  'movedToEmpty': '{actor} ha mosso {piece} in una casella vuota.',
  'cannotMoveToHidden':
      'Non puoi muovere su una pedina nascosta. Devi scoprirla.',
  'cannotCaptureOwn': 'Non puoi catturare una tua pedina.',
  'cannotCapture': '{attacker} non può catturare {defender}.',
  'mutualElimination':
      '{attacker} di {actor} e {defender} di {defenderSide} si sono eliminati a vicenda.',
  'capturedPiece':
      '{attacker} di {actor} ha catturato {defender} di {defenderSide}.',
  'winnerNoLegalAction': '{side} vince. L’avversario non ha azioni legali.',
  'winnerElimination':
      '{side} vince dopo aver catturato tutte le pedine avversarie.',
  'drawNonCaptureLimit': '{limit} turni senza catture. Patta.',
  'drawNoLegalActions': 'Nessun lato ha azioni legali. Patta.',
  'drawMutualElimination':
      'Le ultime pedine si sono eliminate a vicenda. Patta.',
  'turnMessage':
      'Tocca a {side}: scopri o muovi di un passo. Senza catture {count}/{limit}.',
  'remainingAfterCapture':
      '{action} A {side} restano {remaining} pedina/e, incluse quelle nascoste.\n{turn}',
  'currentTurn': 'Turno attuale: {side}',
  'victoryHeading': 'Vittoria di {side}',
  'sideRemaining': 'Rimaste a {side}',
  'piecesCount': '{count} pedina/e',
  'gameOverWinner': '{side} vince',
  'rule1':
      '1. Il tabellone è 4 x 4, con 16 pedine. Rosso e Blu hanno ranghi da 1 a 8.',
  'rule2':
      '2. A ogni turno scegli un’azione: scoprire una pedina nascosta o muovere una pedina scoperta di un passo.',
  'rule3':
      '3. Le pedine si muovono solo su, giù, sinistra o destra. Niente diagonali o mosse multiple.',
  'rule4':
      '4. Puoi catturare solo una pedina avversaria scoperta con numero uguale o minore. Regola speciale: 1 cattura 8, ma 8 non cattura 1.',
  'rule5': '5. Se i numeri sono uguali, entrambe le pedine spariscono.',
  'rule6':
      '6. Vinci catturando tutte le pedine avversarie. Se le ultime spariscono insieme, è patta.',
  'rule7':
      '7. Se non ci sono pedine nascoste e un lato non può agire, vince l’altro. Se nessuno può agire, è patta.',
  'rule8':
      '8. {limit} turni consecutivi senza catture sono patta. Il contatore si azzera dopo una cattura.',
  'rule9':
      '9. Le caselle catturate diventano vuote e possono essere occupate in seguito.',
};

const Map<String, String> _frenchStrings = <String, String>{
  'settingsTooltip': 'Paramètres',
  'settingsTitle': 'Paramètres',
  'soundEffects': 'Effets sonores',
  'languageLabel': 'Langue de l’interface',
  'done': 'Terminé',
  'resetButton': 'Recommencer',
  'resetTitle': 'Recommencer ?',
  'resetContent': 'La partie en cours sera effacée.',
  'continueGame': 'Continuer',
  'undoButton': 'Annuler',
  'undoUnavailable': 'Déjà au début',
  'undoTitle': 'Confirmer l’annulation ?',
  'undoContent': 'Après une publicité, la partie reviendra au coup précédent.',
  'cancel': 'Annuler',
  'watchAdAndUndo': 'Voir la publicité et annuler',
  'undoingLabel': 'Annulation',
  'rulesTitle': 'Règles',
  'drawHeading': 'Match nul',
  'gameOverPrompt': 'Touchez recommencer pour lancer la partie suivante',
  'side.red': 'Rouge',
  'side.blue': 'Bleu',
  'animal.1': 'Rat',
  'animal.2': 'Chat',
  'animal.3': 'Chien',
  'animal.4': 'Loup',
  'animal.5': 'Léopard',
  'animal.6': 'Tigre',
  'animal.7': 'Lion',
  'animal.8': 'Éléphant',
  'pieceLabel': 'No {rank} {animal}',
  'openingTurn':
      '{side} commence : à chaque tour, retournez une pièce cachée ou déplacez une de vos pièces.',
  'adThenUndo': 'Le coup sera annulé après la publicité.',
  'undoingStatus': 'Annulation...',
  'undoRestoredOpening': 'Annulé, retour au début. {next}',
  'undoRestoredPrevious': 'Annulé, retour au coup précédent. {next}',
  'undoTurn':
      'Tour de {side} : retournez une pièce ou avancez d’une case. Sans capture {count}/{limit}.',
  'selectionCanceled':
      'Sélection annulée. Vous pouvez retourner une pièce ou en choisir une autre.',
  'selectedPiece': '{side} a sélectionné {piece}.',
  'choosePieceFirst':
      'Retournez d’abord une pièce cachée, ou sélectionnez une de vos pièces avant de bouger.',
  'selectedPieceMissing':
      'La pièce sélectionnée a disparu. Veuillez choisir à nouveau.',
  'flippedPiece': '{actor} a retourné {piece} de {side}.',
  'oneStepOnly':
      'Vous ne pouvez avancer que d’une case vers le haut, le bas, la gauche ou la droite.',
  'movedToEmpty': '{actor} a déplacé {piece} vers une case vide.',
  'cannotMoveToHidden':
      'Vous ne pouvez pas aller sur une pièce cachée. Retournez-la.',
  'cannotCaptureOwn': 'Vous ne pouvez pas capturer votre propre pièce.',
  'cannotCapture': '{attacker} ne peut pas capturer {defender}.',
  'mutualElimination':
      '{attacker} de {actor} et {defender} de {defenderSide} se sont éliminés.',
  'capturedPiece':
      '{attacker} de {actor} a capturé {defender} de {defenderSide}.',
  'winnerNoLegalAction': '{side} gagne. L’adversaire n’a plus d’action légale.',
  'winnerElimination':
      '{side} gagne après avoir capturé toutes les pièces adverses.',
  'drawNonCaptureLimit': '{limit} tours sans capture. Match nul.',
  'drawNoLegalActions': 'Aucun camp n’a d’action légale. Match nul.',
  'drawMutualElimination': 'Les dernières pièces se sont éliminées. Match nul.',
  'turnMessage':
      'Tour de {side} : retournez une pièce ou avancez d’une case. Sans capture {count}/{limit}.',
  'remainingAfterCapture':
      '{action} Il reste {remaining} pièce(s) à {side}, pièces cachées comprises.\n{turn}',
  'currentTurn': 'Tour actuel : {side}',
  'victoryHeading': 'Victoire de {side}',
  'sideRemaining': 'Restantes pour {side}',
  'piecesCount': '{count} pièce(s)',
  'gameOverWinner': '{side} gagne',
  'rule1':
      '1. Le plateau est de 4 x 4, avec 16 pièces. Rouge et Bleu ont chacun les rangs 1 à 8.',
  'rule2':
      '2. À chaque tour, choisissez une action : retourner une pièce cachée ou déplacer une pièce révélée d’une case.',
  'rule3':
      '3. Les pièces vont seulement en haut, en bas, à gauche ou à droite. Pas de diagonales ni de déplacement multiple.',
  'rule4':
      '4. Une capture vise une pièce adverse révélée de nombre égal ou inférieur. Règle spéciale : 1 capture 8, mais 8 ne capture pas 1.',
  'rule5': '5. Si les nombres sont identiques, les deux pièces disparaissent.',
  'rule6':
      '6. Capturez toutes les pièces adverses pour gagner. Si les dernières disparaissent ensemble, c’est nul.',
  'rule7':
      '7. S’il n’y a plus de pièces cachées et qu’un camp ne peut pas agir, l’autre gagne. Si aucun ne peut agir, c’est nul.',
  'rule8':
      '8. {limit} tours consécutifs sans capture donnent un match nul. Le compteur repart après une capture.',
  'rule9':
      '9. Les cases capturées deviennent vides et peuvent être occupées plus tard.',
};

const Map<String, String> _germanStrings = <String, String>{
  'settingsTooltip': 'Einstellungen',
  'settingsTitle': 'Einstellungen',
  'soundEffects': 'Soundeffekte',
  'languageLabel': 'Sprache der Oberfläche',
  'done': 'Fertig',
  'resetButton': 'Neustart',
  'resetTitle': 'Neu starten?',
  'resetContent': 'Die aktuelle Partie wird gelöscht.',
  'continueGame': 'Weiterspielen',
  'undoButton': 'Zurück',
  'undoUnavailable': 'Bereits am Anfang',
  'undoTitle': 'Zurücknehmen bestätigen?',
  'undoContent': 'Nach einer Anzeige geht die Partie einen Zug zurück.',
  'cancel': 'Abbrechen',
  'watchAdAndUndo': 'Anzeige ansehen und zurück',
  'undoingLabel': 'Zurücknehmen',
  'rulesTitle': 'Regeln',
  'drawHeading': 'Remis',
  'gameOverPrompt': 'Tippe auf Neustart für die nächste Partie',
  'side.red': 'Rot',
  'side.blue': 'Blau',
  'animal.1': 'Ratte',
  'animal.2': 'Katze',
  'animal.3': 'Hund',
  'animal.4': 'Wolf',
  'animal.5': 'Leopard',
  'animal.6': 'Tiger',
  'animal.7': 'Löwe',
  'animal.8': 'Elefant',
  'pieceLabel': 'Nr. {rank} {animal}',
  'openingTurn':
      '{side} beginnt: Decke pro Zug eine verdeckte Figur auf oder bewege eine eigene Figur.',
  'adThenUndo': 'Der Zug wird nach der Anzeige zurückgenommen.',
  'undoingStatus': 'Wird zurückgenommen...',
  'undoRestoredOpening': 'Zurückgenommen, wieder am Anfang. {next}',
  'undoRestoredPrevious': 'Zurückgenommen, wieder beim vorherigen Zug. {next}',
  'undoTurn':
      '{side} ist am Zug: aufdecken oder einen Schritt ziehen. Ohne Schlag {count}/{limit}.',
  'selectionCanceled':
      'Auswahl aufgehoben. Du kannst aufdecken oder erneut eine Figur wählen.',
  'selectedPiece': '{side} hat {piece} gewählt.',
  'choosePieceFirst':
      'Decke zuerst eine verdeckte Figur auf oder wähle eine eigene Figur zum Ziehen.',
  'selectedPieceMissing':
      'Die gewählte Figur ist nicht mehr da. Bitte erneut wählen.',
  'flippedPiece': '{actor} hat {piece} von {side} aufgedeckt.',
  'oneStepOnly':
      'Du kannst nur ein Feld nach oben, unten, links oder rechts ziehen.',
  'movedToEmpty': '{actor} hat {piece} auf ein leeres Feld gezogen.',
  'cannotMoveToHidden':
      'Du kannst nicht auf eine verdeckte Figur ziehen. Decke sie auf.',
  'cannotCaptureOwn': 'Du kannst keine eigene Figur schlagen.',
  'cannotCapture': '{attacker} kann {defender} nicht schlagen.',
  'mutualElimination':
      '{attacker} von {actor} und {defender} von {defenderSide} haben sich gegenseitig entfernt.',
  'capturedPiece':
      '{attacker} von {actor} hat {defender} von {defenderSide} geschlagen.',
  'winnerNoLegalAction':
      '{side} gewinnt. Der Gegner hat keine legale Aktion mehr.',
  'winnerElimination':
      '{side} gewinnt, nachdem alle gegnerischen Figuren geschlagen wurden.',
  'drawNonCaptureLimit': '{limit} Züge ohne Schlag. Remis.',
  'drawNoLegalActions': 'Keine Seite hat eine legale Aktion. Remis.',
  'drawMutualElimination':
      'Die letzten Figuren haben sich gegenseitig entfernt. Remis.',
  'turnMessage':
      '{side} ist am Zug: aufdecken oder einen Schritt ziehen. Ohne Schlag {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} hat noch {remaining} Figur(en), einschließlich verdeckter Figuren.\n{turn}',
  'currentTurn': 'Aktueller Zug: {side}',
  'victoryHeading': 'Sieg für {side}',
  'sideRemaining': '{side} übrig',
  'piecesCount': '{count} Figur(en)',
  'gameOverWinner': '{side} gewinnt',
  'rule1':
      '1. Das Brett ist 4 x 4 groß und hat 16 Figuren. Rot und Blau besitzen je die Ränge 1 bis 8.',
  'rule2':
      '2. Wähle pro Zug eine Aktion: eine verdeckte Figur aufdecken oder eine eigene offene Figur einen Schritt bewegen.',
  'rule3':
      '3. Figuren ziehen nur hoch, runter, links oder rechts. Keine Diagonalen und keine Mehrfeldzüge.',
  'rule4':
      '4. Geschlagen wird nur eine offene gegnerische Figur mit gleicher oder kleinerer Zahl. Sonderregel: 1 schlägt 8, aber 8 schlägt 1 nicht.',
  'rule5': '5. Bei gleichen Zahlen verschwinden beide Figuren.',
  'rule6':
      '6. Wer alle gegnerischen Figuren schlägt, gewinnt. Verschwinden die letzten Figuren gemeinsam, ist es Remis.',
  'rule7':
      '7. Gibt es keine verdeckten Figuren mehr und eine Seite kann nicht handeln, gewinnt die andere. Können beide nicht handeln, ist es Remis.',
  'rule8':
      '8. {limit} Züge in Folge ohne Schlag ergeben Remis. Nach einem Schlag wird der Zähler zurückgesetzt.',
  'rule9':
      '9. Geschlagene Felder werden leer und können später betreten werden.',
};

const Map<String, String> _portugueseStrings = <String, String>{
  'settingsTooltip': 'Definições',
  'settingsTitle': 'Definições',
  'soundEffects': 'Efeitos sonoros',
  'languageLabel': 'Idioma da interface',
  'done': 'Concluído',
  'resetButton': 'Recomeçar',
  'resetTitle': 'Recomeçar?',
  'resetContent': 'A partida atual será apagada.',
  'continueGame': 'Continuar',
  'undoButton': 'Desfazer',
  'undoUnavailable': 'Já está no início',
  'undoTitle': 'Confirmar desfazer?',
  'undoContent': 'Depois de ver um anúncio, a partida volta uma jogada.',
  'cancel': 'Cancelar',
  'watchAdAndUndo': 'Ver anúncio e desfazer',
  'undoingLabel': 'A desfazer',
  'rulesTitle': 'Regras',
  'drawHeading': 'Empate',
  'gameOverPrompt': 'Toque em recomeçar para iniciar a próxima partida',
  'side.red': 'Vermelho',
  'side.blue': 'Azul',
  'animal.1': 'Rato',
  'animal.2': 'Gato',
  'animal.3': 'Cão',
  'animal.4': 'Lobo',
  'animal.5': 'Leopardo',
  'animal.6': 'Tigre',
  'animal.7': 'Leão',
  'animal.8': 'Elefante',
  'pieceLabel': 'N.º {rank} {animal}',
  'openingTurn':
      '{side} começa: a cada turno, vire uma peça oculta ou mova uma peça sua.',
  'adThenUndo': 'A jogada será desfeita depois do anúncio.',
  'undoingStatus': 'A desfazer...',
  'undoRestoredOpening': 'Desfeito, de volta ao início. {next}',
  'undoRestoredPrevious': 'Desfeito, de volta à jogada anterior. {next}',
  'undoTurn':
      'Turno de {side}: vire ou mova um passo. Sem capturas {count}/{limit}.',
  'selectionCanceled':
      'Seleção cancelada. Pode virar uma peça ou escolher outra.',
  'selectedPiece': '{side} selecionou {piece}.',
  'choosePieceFirst':
      'Vire primeiro uma peça oculta ou selecione uma peça sua para mover.',
  'selectedPieceMissing':
      'A peça selecionada já não existe. Escolha novamente.',
  'flippedPiece': '{actor} virou {piece} de {side}.',
  'oneStepOnly':
      'Só pode mover uma casa para cima, baixo, esquerda ou direita.',
  'movedToEmpty': '{actor} moveu {piece} para uma casa vazia.',
  'cannotMoveToHidden': 'Não pode mover para cima de uma peça oculta. Vire-a.',
  'cannotCaptureOwn': 'Não pode capturar a sua própria peça.',
  'cannotCapture': '{attacker} não pode capturar {defender}.',
  'mutualElimination':
      '{attacker} de {actor} e {defender} de {defenderSide} eliminaram-se.',
  'capturedPiece':
      '{attacker} de {actor} capturou {defender} de {defenderSide}.',
  'winnerNoLegalAction': '{side} vence. O adversário não tem ação legal.',
  'winnerElimination': '{side} vence ao capturar todas as peças adversárias.',
  'drawNonCaptureLimit': '{limit} turnos sem captura. Empate.',
  'drawNoLegalActions': 'Nenhum lado tem ação legal. Empate.',
  'drawMutualElimination': 'As últimas peças eliminaram-se. Empate.',
  'turnMessage':
      'Turno de {side}: vire ou mova um passo. Sem capturas {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} tem {remaining} peça(s) restantes, incluindo ocultas.\n{turn}',
  'currentTurn': 'Turno atual: {side}',
  'victoryHeading': 'Vitória de {side}',
  'sideRemaining': 'Restantes de {side}',
  'piecesCount': '{count} peça(s)',
  'gameOverWinner': '{side} vence',
  'rule1':
      '1. O tabuleiro é 4 x 4, com 16 peças. Vermelho e Azul têm ranks de 1 a 8.',
  'rule2':
      '2. Em cada turno escolha uma ação: virar uma peça oculta ou mover uma peça revelada um passo.',
  'rule3':
      '3. As peças movem apenas para cima, baixo, esquerda ou direita. Sem diagonais nem múltiplas casas.',
  'rule4':
      '4. A captura deve mirar uma peça adversária revelada com número igual ou menor. Regra especial: 1 captura 8, mas 8 não captura 1.',
  'rule5': '5. Se os números forem iguais, ambas as peças desaparecem.',
  'rule6':
      '6. Capture todas as peças adversárias para vencer. Se as últimas desaparecerem juntas, é empate.',
  'rule7':
      '7. Se não houver peças ocultas e um lado não puder agir, o outro vence. Se ambos não puderem agir, é empate.',
  'rule8':
      '8. {limit} turnos seguidos sem captura dão empate. O contador reinicia após uma captura.',
  'rule9': '9. Casas capturadas ficam vazias e podem ser ocupadas depois.',
};

const Map<String, String> _russianStrings = <String, String>{
  'settingsTooltip': 'Настройки',
  'settingsTitle': 'Настройки',
  'soundEffects': 'Звуковые эффекты',
  'languageLabel': 'Язык интерфейса',
  'done': 'Готово',
  'resetButton': 'Начать заново',
  'resetTitle': 'Начать заново?',
  'resetContent': 'Текущая партия будет очищена.',
  'continueGame': 'Продолжить',
  'undoButton': 'Отменить ход',
  'undoUnavailable': 'Уже начальная позиция',
  'undoTitle': 'Отменить ход?',
  'undoContent': 'После рекламы партия вернется на один ход назад.',
  'cancel': 'Отмена',
  'watchAdAndUndo': 'Смотреть рекламу и отменить',
  'undoingLabel': 'Отмена хода',
  'rulesTitle': 'Правила',
  'drawHeading': 'Ничья',
  'gameOverPrompt': 'Нажмите начать заново для следующей партии',
  'side.red': 'Красные',
  'side.blue': 'Синие',
  'animal.1': 'Крыса',
  'animal.2': 'Кот',
  'animal.3': 'Собака',
  'animal.4': 'Волк',
  'animal.5': 'Леопард',
  'animal.6': 'Тигр',
  'animal.7': 'Лев',
  'animal.8': 'Слон',
  'pieceLabel': '№ {rank} {animal}',
  'openingTurn':
      '{side} начинают: за ход откройте скрытую фигуру или передвиньте свою.',
  'adThenUndo': 'Ход будет отменен после рекламы.',
  'undoingStatus': 'Отмена хода...',
  'undoRestoredOpening': 'Ход отменен, возврат к началу. {next}',
  'undoRestoredPrevious': 'Ход отменен, возврат к предыдущему ходу. {next}',
  'undoTurn':
      'Ход {side}: откройте фигуру или сделайте шаг. Без взятий {count}/{limit}.',
  'selectionCanceled': 'Выбор снят. Можно открыть фигуру или выбрать другую.',
  'selectedPiece': '{side} выбрали {piece}.',
  'choosePieceFirst':
      'Сначала откройте скрытую фигуру или выберите свою фигуру для хода.',
  'selectedPieceMissing': 'Выбранной фигуры больше нет. Выберите заново.',
  'flippedPiece': '{actor} открыли {piece} стороны {side}.',
  'oneStepOnly':
      'Можно ходить только на одну клетку вверх, вниз, влево или вправо.',
  'movedToEmpty': '{actor} переместили {piece} на пустую клетку.',
  'cannotMoveToHidden': 'Нельзя ходить на скрытую фигуру. Ее нужно открыть.',
  'cannotCaptureOwn': 'Нельзя брать свою фигуру.',
  'cannotCapture': '{attacker} не может взять {defender}.',
  'mutualElimination':
      '{attacker} стороны {actor} и {defender} стороны {defenderSide} уничтожили друг друга.',
  'capturedPiece':
      '{attacker} стороны {actor} взяла {defender} стороны {defenderSide}.',
  'winnerNoLegalAction': '{side} победили. У соперника нет законных действий.',
  'winnerElimination': '{side} победили, взяв все фигуры соперника.',
  'drawNonCaptureLimit': '{limit} ходов без взятия. Ничья.',
  'drawNoLegalActions': 'Ни у одной стороны нет законных действий. Ничья.',
  'drawMutualElimination': 'Последние фигуры уничтожили друг друга. Ничья.',
  'turnMessage':
      'Ход {side}: откройте фигуру или сделайте шаг. Без взятий {count}/{limit}.',
  'remainingAfterCapture':
      '{action} У {side} осталось {remaining} фигур(ы), включая скрытые.\n{turn}',
  'currentTurn': 'Текущий ход: {side}',
  'victoryHeading': 'Победа: {side}',
  'sideRemaining': 'Осталось у {side}',
  'piecesCount': '{count} фигур(ы)',
  'gameOverWinner': '{side} победили',
  'rule1': '1. Доска 4 x 4, всего 16 фигур. У Красных и Синих ранги от 1 до 8.',
  'rule2':
      '2. За ход выберите одно действие: открыть скрытую фигуру или передвинуть свою открытую фигуру на шаг.',
  'rule3':
      '3. Фигуры ходят только вверх, вниз, влево или вправо. Без диагоналей и дальних ходов.',
  'rule4':
      '4. Брать можно открытую фигуру соперника с равным или меньшим номером. Особое правило: 1 берет 8, но 8 не берет 1.',
  'rule5': '5. Если номера равны, обе фигуры исчезают.',
  'rule6':
      '6. Возьмите все фигуры соперника, чтобы победить. Если последние фигуры исчезают вместе, это ничья.',
  'rule7':
      '7. Если скрытых фигур нет и одна сторона не может действовать, побеждает другая. Если обе не могут действовать, ничья.',
  'rule8':
      '8. {limit} ходов подряд без взятия дают ничью. После взятия счетчик сбрасывается.',
  'rule9':
      '9. Клетки после взятия становятся пустыми, туда можно ходить позже.',
};

const Map<String, String> _hindiStrings = <String, String>{
  'settingsTooltip': 'सेटिंग्स',
  'settingsTitle': 'सेटिंग्स',
  'soundEffects': 'ध्वनि प्रभाव',
  'languageLabel': 'इंटरफेस भाषा',
  'done': 'हो गया',
  'resetButton': 'फिर शुरू करें',
  'resetTitle': 'फिर शुरू करें?',
  'resetContent': 'मौजूदा खेल साफ हो जाएगा।',
  'continueGame': 'खेल जारी रखें',
  'undoButton': 'वापस लें',
  'undoUnavailable': 'पहले से शुरुआत पर है',
  'undoTitle': 'वापस लेना पक्का करें?',
  'undoContent': 'विज्ञापन देखने के बाद खेल एक चाल पीछे जाएगा।',
  'cancel': 'रद्द करें',
  'watchAdAndUndo': 'विज्ञापन देखें और वापस लें',
  'undoingLabel': 'वापस ले रहे हैं',
  'rulesTitle': 'नियम',
  'drawHeading': 'ड्रा',
  'gameOverPrompt': 'अगला खेल शुरू करने के लिए फिर शुरू करें दबाएं',
  'side.red': 'लाल',
  'side.blue': 'नीला',
  'animal.1': 'चूहा',
  'animal.2': 'बिल्ली',
  'animal.3': 'कुत्ता',
  'animal.4': 'भेड़िया',
  'animal.5': 'तेंदुआ',
  'animal.6': 'बाघ',
  'animal.7': 'सिंह',
  'animal.8': 'हाथी',
  'pieceLabel': 'नं. {rank} {animal}',
  'openingTurn':
      '{side} शुरू करता है: हर चाल में एक छिपी गोटी खोलें या अपनी एक गोटी चलें।',
  'adThenUndo': 'विज्ञापन के बाद चाल वापस ली जाएगी।',
  'undoingStatus': 'वापस ले रहे हैं...',
  'undoRestoredOpening': 'वापस लिया, शुरुआत पर लौटे। {next}',
  'undoRestoredPrevious': 'वापस लिया, पिछली चाल पर लौटे। {next}',
  'undoTurn':
      '{side} की बारी: गोटी खोलें या एक कदम चलें। बिना मार {count}/{limit}।',
  'selectionCanceled': 'चयन रद्द। आप गोटी खोल सकते हैं या फिर से चुन सकते हैं।',
  'selectedPiece': '{side} ने {piece} चुना।',
  'choosePieceFirst': 'पहले छिपी गोटी खोलें, या चलने से पहले अपनी गोटी चुनें।',
  'selectedPieceMissing': 'चुनी हुई गोटी नहीं रही। फिर चुनें।',
  'flippedPiece': '{actor} ने {side} की {piece} खोली।',
  'oneStepOnly': 'आप केवल एक खाने ऊपर, नीचे, बाएं या दाएं चल सकते हैं।',
  'movedToEmpty': '{actor} ने {piece} को खाली खाने में चलाया।',
  'cannotMoveToHidden': 'छिपी गोटी पर नहीं चल सकते। उसे खोलें।',
  'cannotCaptureOwn': 'अपनी गोटी नहीं मार सकते।',
  'cannotCapture': '{attacker} {defender} को नहीं मार सकता।',
  'mutualElimination':
      '{actor} का {attacker} और {defenderSide} का {defender} दोनों हट गए।',
  'capturedPiece':
      '{actor} के {attacker} ने {defenderSide} के {defender} को मारा।',
  'winnerNoLegalAction':
      '{side} जीत गया। प्रतिद्वंद्वी के पास कोई वैध चाल नहीं है।',
  'winnerElimination': '{side} ने सभी विरोधी गोटियां मारकर जीत ली।',
  'drawNonCaptureLimit': '{limit} चालों तक कोई मार नहीं। ड्रा।',
  'drawNoLegalActions': 'दोनों पक्षों के पास वैध चाल नहीं है। ड्रा।',
  'drawMutualElimination': 'आखिरी गोटियां साथ हट गईं। ड्रा।',
  'turnMessage':
      '{side} की बारी: गोटी खोलें या एक कदम चलें। बिना मार {count}/{limit}।',
  'remainingAfterCapture':
      '{action} {side} के पास {remaining} गोटी बची हैं, छिपी गोटियों सहित।\n{turn}',
  'currentTurn': 'मौजूदा बारी: {side}',
  'victoryHeading': '{side} की जीत',
  'sideRemaining': '{side} शेष',
  'piecesCount': '{count} गोटी',
  'gameOverWinner': '{side} जीता',
  'rule1':
      '1. बोर्ड 4 x 4 है और कुल 16 गोटियां हैं। लाल और नीले के पास 1 से 8 तक रैंक हैं।',
  'rule2':
      '2. हर चाल में एक काम चुनें: छिपी गोटी खोलना या अपनी खुली गोटी को एक कदम चलाना।',
  'rule3':
      '3. गोटियां केवल ऊपर, नीचे, बाएं या दाएं चलती हैं। तिरछा या कई खाने नहीं।',
  'rule4':
      '4. मारने के लिए विरोधी गोटी खुली और संख्या बराबर या कम होनी चाहिए। विशेष नियम: 1, 8 को मारता है, लेकिन 8, 1 को नहीं।',
  'rule5': '5. संख्या समान हो तो दोनों गोटियां हट जाती हैं।',
  'rule6': '6. सभी विरोधी गोटियां मारकर जीतें। आखिरी गोटियां साथ हटें तो ड्रा।',
  'rule7':
      '7. अगर छिपी गोटियां नहीं बचीं और एक पक्ष नहीं चल सकता, दूसरा जीतता है। दोनों न चल सकें तो ड्रा।',
  'rule8':
      '8. लगातार {limit} चालें बिना मार के ड्रा हैं। मारने पर गिनती रीसेट होती है।',
  'rule9': '9. मारी गई जगह खाली हो जाती है और बाद में वहां चला जा सकता है।',
};

const Map<String, String> _arabicStrings = <String, String>{
  'settingsTooltip': 'الإعدادات',
  'settingsTitle': 'الإعدادات',
  'soundEffects': 'المؤثرات الصوتية',
  'languageLabel': 'لغة الواجهة',
  'done': 'تم',
  'resetButton': 'إعادة البدء',
  'resetTitle': 'إعادة البدء؟',
  'resetContent': 'سيتم مسح اللعبة الحالية.',
  'continueGame': 'متابعة اللعب',
  'undoButton': 'تراجع',
  'undoUnavailable': 'أنت عند البداية بالفعل',
  'undoTitle': 'تأكيد التراجع؟',
  'undoContent': 'بعد مشاهدة إعلان، ستعود اللعبة خطوة واحدة.',
  'cancel': 'إلغاء',
  'watchAdAndUndo': 'شاهد الإعلان وتراجع',
  'undoingLabel': 'جار التراجع',
  'rulesTitle': 'القواعد',
  'drawHeading': 'تعادل',
  'gameOverPrompt': 'اضغط إعادة البدء لبدء اللعبة التالية',
  'side.red': 'الأحمر',
  'side.blue': 'الأزرق',
  'animal.1': 'فأر',
  'animal.2': 'قط',
  'animal.3': 'كلب',
  'animal.4': 'ذئب',
  'animal.5': 'نمر مرقط',
  'animal.6': 'ببر',
  'animal.7': 'أسد',
  'animal.8': 'فيل',
  'pieceLabel': 'رقم {rank} {animal}',
  'openingTurn': '{side} يبدأ: في كل دور، اكشف قطعة مخفية أو حرّك إحدى قطعك.',
  'adThenUndo': 'سيتم التراجع عن الحركة بعد الإعلان.',
  'undoingStatus': 'جار التراجع...',
  'undoRestoredOpening': 'تم التراجع، عودة إلى البداية. {next}',
  'undoRestoredPrevious': 'تم التراجع، عودة إلى الحركة السابقة. {next}',
  'undoTurn':
      'دور {side}: اكشف قطعة أو تحرك خطوة واحدة. بلا أسر {count}/{limit}.',
  'selectionCanceled': 'تم إلغاء التحديد. يمكنك كشف قطعة أو اختيار قطعة أخرى.',
  'selectedPiece': '{side} اختار {piece}.',
  'choosePieceFirst': 'اكشف قطعة مخفية أولا، أو اختر إحدى قطعك قبل الحركة.',
  'selectedPieceMissing': 'القطعة المحددة لم تعد موجودة. اختر مجددا.',
  'flippedPiece': '{actor} كشف {piece} من {side}.',
  'oneStepOnly':
      'يمكنك التحرك خانة واحدة فقط للأعلى أو الأسفل أو اليسار أو اليمين.',
  'movedToEmpty': '{actor} حرّك {piece} إلى خانة فارغة.',
  'cannotMoveToHidden': 'لا يمكنك التحرك فوق قطعة مخفية. اكشفها بدلا من ذلك.',
  'cannotCaptureOwn': 'لا يمكنك أسر قطعتك.',
  'cannotCapture': '{attacker} لا يستطيع أسر {defender}.',
  'mutualElimination':
      '{attacker} من {actor} و {defender} من {defenderSide} أزالا بعضهما.',
  'capturedPiece': '{attacker} من {actor} أسر {defender} من {defenderSide}.',
  'winnerNoLegalAction': '{side} يفوز. لا يملك الخصم أي حركة قانونية.',
  'winnerElimination': '{side} يفوز بعد أسر كل قطع الخصم.',
  'drawNonCaptureLimit': '{limit} أدوار بلا أسر. تعادل.',
  'drawNoLegalActions': 'لا يملك أي طرف حركة قانونية. تعادل.',
  'drawMutualElimination': 'أزالت القطع الأخيرة بعضها. تعادل.',
  'turnMessage':
      'دور {side}: اكشف قطعة أو تحرك خطوة واحدة. بلا أسر {count}/{limit}.',
  'remainingAfterCapture':
      '{action} تبقى لدى {side} {remaining} قطعة، بما فيها المخفية.\n{turn}',
  'currentTurn': 'الدور الحالي: {side}',
  'victoryHeading': 'فوز {side}',
  'sideRemaining': 'المتبقي لدى {side}',
  'piecesCount': '{count} قطعة',
  'gameOverWinner': '{side} يفوز',
  'rule1': '1. اللوحة 4 x 4 وبها 16 قطعة. لدى الأحمر والأزرق رتب من 1 إلى 8.',
  'rule2':
      '2. في كل دور اختر فعلا واحدا: كشف قطعة مخفية أو تحريك قطعة مكشوفة خطوة واحدة.',
  'rule3':
      '3. تتحرك القطع للأعلى أو الأسفل أو اليسار أو اليمين فقط. لا قطرية ولا أكثر من خانة.',
  'rule4':
      '4. يجب أن يكون الأسر لقطعة خصم مكشوفة برقم مساو أو أصغر. قاعدة خاصة: 1 يأسر 8، لكن 8 لا يأسر 1.',
  'rule5': '5. إذا تساوى الرقمان، تختفي القطعتان.',
  'rule6':
      '6. أسر كل قطع الخصم للفوز. إذا اختفت القطع الأخيرة معا، فالنتيجة تعادل.',
  'rule7':
      '7. إذا لم تبق قطع مخفية ولا يستطيع طرف الحركة، يفوز الآخر. إذا عجز الطرفان، فتعادل.',
  'rule8': '8. {limit} دورا متتاليا بلا أسر تعني التعادل. يعاد العد بعد الأسر.',
  'rule9': '9. الخانات التي تؤسر منها القطع تصبح فارغة ويمكن دخولها لاحقا.',
};

const Map<String, String> _japaneseStrings = <String, String>{
  'settingsTooltip': '設定',
  'settingsTitle': '設定',
  'soundEffects': '効果音',
  'languageLabel': '表示言語',
  'done': '完了',
  'resetButton': 'やり直す',
  'resetTitle': 'やり直しますか？',
  'resetContent': '現在の対局は消去されます。',
  'continueGame': '続ける',
  'undoButton': '待った',
  'undoUnavailable': 'すでに開始局面です',
  'undoTitle': '待ったしますか？',
  'undoContent': '広告を見たあと、1手前に戻ります。',
  'cancel': 'キャンセル',
  'watchAdAndUndo': '広告を見て待った',
  'undoingLabel': '戻しています',
  'rulesTitle': 'ルール',
  'drawHeading': '引き分け',
  'gameOverPrompt': 'やり直すをタップして次の対局へ',
  'side.red': '赤',
  'side.blue': '青',
  'animal.1': 'ネズミ',
  'animal.2': 'ネコ',
  'animal.3': 'イヌ',
  'animal.4': 'オオカミ',
  'animal.5': 'ヒョウ',
  'animal.6': 'トラ',
  'animal.7': 'ライオン',
  'animal.8': 'ゾウ',
  'pieceLabel': '{rank}番 {animal}',
  'openingTurn': '{side}の先手：各手番で伏せ駒を開くか、自分の駒を動かします。',
  'adThenUndo': '広告のあとで手を戻します。',
  'undoingStatus': '戻しています...',
  'undoRestoredOpening': '待ったしました。開始局面に戻りました。{next}',
  'undoRestoredPrevious': '待ったしました。前の手に戻りました。{next}',
  'undoTurn': '{side}の手番：駒を開くか1歩動かします。取らない手 {count}/{limit}。',
  'selectionCanceled': '選択を解除しました。駒を開くか、別の駒を選べます。',
  'selectedPiece': '{side}が{piece}を選択しました。',
  'choosePieceFirst': '先に伏せ駒を開くか、自分の駒を選んでから動かしてください。',
  'selectedPieceMissing': '選択した駒がありません。選び直してください。',
  'flippedPiece': '{actor}が{side}の{piece}を開きました。',
  'oneStepOnly': '上下左右に1マスだけ動けます。',
  'movedToEmpty': '{actor}が{piece}を空きマスへ動かしました。',
  'cannotMoveToHidden': '伏せ駒の上には動けません。開いてください。',
  'cannotCaptureOwn': '自分の駒は取れません。',
  'cannotCapture': '{attacker}は{defender}を取れません。',
  'mutualElimination':
      '{actor}の{attacker}と{defenderSide}の{defender}が相打ちになりました。',
  'capturedPiece': '{actor}の{attacker}が{defenderSide}の{defender}を取りました。',
  'winnerNoLegalAction': '{side}の勝ち。相手に合法手がありません。',
  'winnerElimination': '{side}の勝ち。相手の駒をすべて取りました。',
  'drawNonCaptureLimit': '{limit}手連続で取りがありません。引き分け。',
  'drawNoLegalActions': '双方に合法手がありません。引き分け。',
  'drawMutualElimination': '最後の駒が相打ちになりました。引き分け。',
  'turnMessage': '{side}の手番：駒を開くか1歩動かします。取らない手 {count}/{limit}。',
  'remainingAfterCapture': '{action} {side}の残りは伏せ駒を含めて{remaining}枚です。\n{turn}',
  'currentTurn': '現在の手番：{side}',
  'victoryHeading': '{side}の勝利',
  'sideRemaining': '{side}の残り',
  'piecesCount': '{count}枚',
  'gameOverWinner': '{side}の勝ち',
  'rule1': '1. 盤は4 x 4、駒は16枚。赤と青はそれぞれ1から8の駒を持ちます。',
  'rule2': '2. 各手番では伏せ駒を開くか、自分の表向きの駒を1歩動かします。',
  'rule3': '3. 駒は上下左右だけに動きます。斜め移動や複数マス移動はできません。',
  'rule4': '4. 取れるのは表向きの相手駒で、数字が同じか小さい駒です。特別ルール：1は8を取れますが、8は1を取れません。',
  'rule5': '5. 数字が同じなら、両方の駒が消えます。',
  'rule6': '6. 相手の駒をすべて取ると勝ちです。最後の駒が同時に消えたら引き分けです。',
  'rule7': '7. 伏せ駒がなく、一方が動けない場合は相手の勝ちです。双方が動けなければ引き分けです。',
  'rule8': '8. {limit}手連続で駒を取らないと引き分けです。取るとカウントはリセットされます。',
  'rule9': '9. 取られた場所は空きマスになり、あとで移動できます。',
};

const Map<String, String> _koreanStrings = <String, String>{
  'settingsTooltip': '설정',
  'settingsTitle': '설정',
  'soundEffects': '효과음',
  'languageLabel': '인터페이스 언어',
  'done': '완료',
  'resetButton': '다시 시작',
  'resetTitle': '다시 시작할까요?',
  'resetContent': '현재 게임이 초기화됩니다.',
  'continueGame': '계속하기',
  'undoButton': '되돌리기',
  'undoUnavailable': '이미 시작 위치입니다',
  'undoTitle': '되돌릴까요?',
  'undoContent': '광고를 본 뒤 한 수 전으로 돌아갑니다.',
  'cancel': '취소',
  'watchAdAndUndo': '광고 보고 되돌리기',
  'undoingLabel': '되돌리는 중',
  'rulesTitle': '규칙',
  'drawHeading': '무승부',
  'gameOverPrompt': '다시 시작을 눌러 다음 게임을 시작하세요',
  'side.red': '빨강',
  'side.blue': '파랑',
  'animal.1': '쥐',
  'animal.2': '고양이',
  'animal.3': '개',
  'animal.4': '늑대',
  'animal.5': '표범',
  'animal.6': '호랑이',
  'animal.7': '사자',
  'animal.8': '코끼리',
  'pieceLabel': '{rank}번 {animal}',
  'openingTurn': '{side} 선공: 매 턴 숨은 말을 뒤집거나 자신의 말을 이동하세요.',
  'adThenUndo': '광고 후 수를 되돌립니다.',
  'undoingStatus': '되돌리는 중...',
  'undoRestoredOpening': '되돌렸습니다. 시작 위치로 돌아왔습니다. {next}',
  'undoRestoredPrevious': '되돌렸습니다. 이전 수로 돌아왔습니다. {next}',
  'undoTurn': '{side} 차례: 말을 뒤집거나 한 칸 이동하세요. 미포획 {count}/{limit}.',
  'selectionCanceled': '선택을 취소했습니다. 말을 뒤집거나 다시 선택할 수 있습니다.',
  'selectedPiece': '{side}이(가) {piece}을(를) 선택했습니다.',
  'choosePieceFirst': '먼저 숨은 말을 뒤집거나, 이동할 자신의 말을 선택하세요.',
  'selectedPieceMissing': '선택한 말이 없습니다. 다시 선택하세요.',
  'flippedPiece': '{actor}이(가) {side}의 {piece}을(를) 뒤집었습니다.',
  'oneStepOnly': '위, 아래, 왼쪽, 오른쪽으로 한 칸만 이동할 수 있습니다.',
  'movedToEmpty': '{actor}이(가) {piece}을(를) 빈 칸으로 옮겼습니다.',
  'cannotMoveToHidden': '숨은 말 위로 이동할 수 없습니다. 대신 뒤집으세요.',
  'cannotCaptureOwn': '자신의 말은 잡을 수 없습니다.',
  'cannotCapture': '{attacker}은(는) {defender}을(를) 잡을 수 없습니다.',
  'mutualElimination':
      '{actor}의 {attacker}와 {defenderSide}의 {defender}이(가) 함께 사라졌습니다.',
  'capturedPiece':
      '{actor}의 {attacker}이(가) {defenderSide}의 {defender}을(를) 잡았습니다.',
  'winnerNoLegalAction': '{side} 승리. 상대에게 합법적인 행동이 없습니다.',
  'winnerElimination': '{side}이(가) 상대 말을 모두 잡아 승리했습니다.',
  'drawNonCaptureLimit': '{limit}턴 동안 포획이 없습니다. 무승부.',
  'drawNoLegalActions': '양쪽 모두 합법적인 행동이 없습니다. 무승부.',
  'drawMutualElimination': '마지막 말들이 함께 사라졌습니다. 무승부.',
  'turnMessage': '{side} 차례: 말을 뒤집거나 한 칸 이동하세요. 미포획 {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side}에게 숨은 말을 포함해 {remaining}개가 남았습니다.\n{turn}',
  'currentTurn': '현재 차례: {side}',
  'victoryHeading': '{side} 승리',
  'sideRemaining': '{side} 남은 말',
  'piecesCount': '{count}개',
  'gameOverWinner': '{side} 승리',
  'rule1': '1. 보드는 4 x 4이며 말은 16개입니다. 빨강과 파랑은 각각 1부터 8까지의 말을 가집니다.',
  'rule2': '2. 매 턴 숨은 말을 뒤집거나 자신의 공개된 말을 한 칸 이동합니다.',
  'rule3': '3. 말은 위, 아래, 왼쪽, 오른쪽으로만 이동합니다. 대각선이나 여러 칸 이동은 없습니다.',
  'rule4':
      '4. 공개된 상대 말 중 숫자가 같거나 낮은 말만 잡을 수 있습니다. 특수 규칙: 1은 8을 잡지만 8은 1을 잡지 못합니다.',
  'rule5': '5. 숫자가 같으면 두 말 모두 사라집니다.',
  'rule6': '6. 상대 말을 모두 잡으면 승리합니다. 마지막 말들이 함께 사라지면 무승부입니다.',
  'rule7': '7. 숨은 말이 없고 한쪽이 행동할 수 없으면 상대가 승리합니다. 양쪽 모두 행동할 수 없으면 무승부입니다.',
  'rule8': '8. 연속 {limit}턴 동안 포획이 없으면 무승부입니다. 포획하면 카운터가 초기화됩니다.',
  'rule9': '9. 잡힌 자리는 빈 칸이 되며 나중에 이동할 수 있습니다.',
};

const Map<String, String> _indonesianStrings = <String, String>{
  'settingsTooltip': 'Pengaturan',
  'settingsTitle': 'Pengaturan',
  'soundEffects': 'Efek suara',
  'languageLabel': 'Bahasa antarmuka',
  'done': 'Selesai',
  'resetButton': 'Mulai ulang',
  'resetTitle': 'Mulai ulang?',
  'resetContent': 'Permainan saat ini akan dihapus.',
  'continueGame': 'Lanjut bermain',
  'undoButton': 'Urungkan',
  'undoUnavailable': 'Sudah di posisi awal',
  'undoTitle': 'Konfirmasi urungkan?',
  'undoContent': 'Setelah menonton iklan, permainan mundur satu langkah.',
  'cancel': 'Batal',
  'watchAdAndUndo': 'Tonton iklan dan urungkan',
  'undoingLabel': 'Mengurungkan',
  'rulesTitle': 'Aturan',
  'drawHeading': 'Seri',
  'gameOverPrompt': 'Ketuk mulai ulang untuk permainan berikutnya',
  'side.red': 'Merah',
  'side.blue': 'Biru',
  'animal.1': 'Tikus',
  'animal.2': 'Kucing',
  'animal.3': 'Anjing',
  'animal.4': 'Serigala',
  'animal.5': 'Macan tutul',
  'animal.6': 'Harimau',
  'animal.7': 'Singa',
  'animal.8': 'Gajah',
  'pieceLabel': 'No. {rank} {animal}',
  'openingTurn':
      '{side} mulai: tiap giliran, buka bidak tersembunyi atau gerakkan bidak sendiri.',
  'adThenUndo': 'Langkah akan diurungkan setelah iklan.',
  'undoingStatus': 'Mengurungkan...',
  'undoRestoredOpening': 'Diurungkan, kembali ke awal. {next}',
  'undoRestoredPrevious': 'Diurungkan, kembali ke langkah sebelumnya. {next}',
  'undoTurn':
      'Giliran {side}: buka bidak atau bergerak satu langkah. Tanpa tangkap {count}/{limit}.',
  'selectionCanceled':
      'Pilihan dibatalkan. Anda bisa membuka bidak atau memilih lagi.',
  'selectedPiece': '{side} memilih {piece}.',
  'choosePieceFirst':
      'Buka bidak tersembunyi dulu, atau pilih bidak sendiri sebelum bergerak.',
  'selectedPieceMissing': 'Bidak yang dipilih sudah tidak ada. Pilih lagi.',
  'flippedPiece': '{actor} membuka {piece} milik {side}.',
  'oneStepOnly':
      'Anda hanya bisa bergerak satu kotak ke atas, bawah, kiri, atau kanan.',
  'movedToEmpty': '{actor} memindahkan {piece} ke kotak kosong.',
  'cannotMoveToHidden':
      'Tidak bisa bergerak ke bidak tersembunyi. Bukalah bidak itu.',
  'cannotCaptureOwn': 'Tidak bisa menangkap bidak sendiri.',
  'cannotCapture': '{attacker} tidak bisa menangkap {defender}.',
  'mutualElimination':
      '{attacker} milik {actor} dan {defender} milik {defenderSide} saling hilang.',
  'capturedPiece':
      '{attacker} milik {actor} menangkap {defender} milik {defenderSide}.',
  'winnerNoLegalAction': '{side} menang. Lawan tidak punya aksi legal.',
  'winnerElimination': '{side} menang setelah menangkap semua bidak lawan.',
  'drawNonCaptureLimit': '{limit} giliran tanpa tangkapan. Seri.',
  'drawNoLegalActions': 'Tidak ada pihak yang punya aksi legal. Seri.',
  'drawMutualElimination': 'Bidak terakhir saling hilang. Seri.',
  'turnMessage':
      'Giliran {side}: buka bidak atau bergerak satu langkah. Tanpa tangkap {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} masih punya {remaining} bidak, termasuk yang tersembunyi.\n{turn}',
  'currentTurn': 'Giliran saat ini: {side}',
  'victoryHeading': 'Kemenangan {side}',
  'sideRemaining': 'Sisa {side}',
  'piecesCount': '{count} bidak',
  'gameOverWinner': '{side} menang',
  'rule1':
      '1. Papan berukuran 4 x 4, dengan 16 bidak. Merah dan Biru masing-masing punya peringkat 1 sampai 8.',
  'rule2':
      '2. Tiap giliran pilih satu aksi: buka bidak tersembunyi atau gerakkan bidak terbuka sendiri satu langkah.',
  'rule3':
      '3. Bidak hanya bergerak ke atas, bawah, kiri, atau kanan. Tidak diagonal dan tidak beberapa kotak.',
  'rule4':
      '4. Tangkapan harus ke bidak lawan yang terbuka dengan angka sama atau lebih rendah. Aturan khusus: 1 bisa menangkap 8, tetapi 8 tidak bisa menangkap 1.',
  'rule5': '5. Jika angkanya sama, kedua bidak hilang.',
  'rule6':
      '6. Tangkap semua bidak lawan untuk menang. Jika bidak terakhir hilang bersama, hasilnya seri.',
  'rule7':
      '7. Jika tidak ada bidak tersembunyi dan satu pihak tidak bisa bertindak, lawan menang. Jika keduanya tidak bisa bertindak, seri.',
  'rule8':
      '8. {limit} giliran berturut-turut tanpa tangkapan berarti seri. Penghitung direset setelah tangkapan.',
  'rule9':
      '9. Kotak yang bidaknya tertangkap menjadi kosong dan bisa ditempati nanti.',
};

const Map<String, String> _dutchStrings = <String, String>{
  'settingsTooltip': 'Instellingen',
  'settingsTitle': 'Instellingen',
  'soundEffects': 'Geluidseffecten',
  'languageLabel': 'Interfacetaal',
  'done': 'Gereed',
  'resetButton': 'Opnieuw',
  'resetTitle': 'Opnieuw beginnen?',
  'resetContent': 'De huidige partij wordt gewist.',
  'continueGame': 'Verder spelen',
  'undoButton': 'Ongedaan',
  'undoUnavailable': 'Al bij de start',
  'undoTitle': 'Ongedaan maken?',
  'undoContent': 'Na een advertentie gaat de partij één zet terug.',
  'cancel': 'Annuleren',
  'watchAdAndUndo': 'Advertentie kijken en ongedaan',
  'undoingLabel': 'Ongedaan maken',
  'rulesTitle': 'Regels',
  'drawHeading': 'Gelijkspel',
  'gameOverPrompt': 'Tik op opnieuw om de volgende partij te starten',
  'side.red': 'Rood',
  'side.blue': 'Blauw',
  'animal.1': 'Rat',
  'animal.2': 'Kat',
  'animal.3': 'Hond',
  'animal.4': 'Wolf',
  'animal.5': 'Luipaard',
  'animal.6': 'Tijger',
  'animal.7': 'Leeuw',
  'animal.8': 'Olifant',
  'pieceLabel': 'Nr. {rank} {animal}',
  'openingTurn':
      '{side} begint: draai per beurt een verborgen stuk om of verplaats een eigen stuk.',
  'adThenUndo': 'De zet wordt na de advertentie ongedaan gemaakt.',
  'undoingStatus': 'Ongedaan maken...',
  'undoRestoredOpening': 'Ongedaan gemaakt, terug naar de start. {next}',
  'undoRestoredPrevious': 'Ongedaan gemaakt, terug naar de vorige zet. {next}',
  'undoTurn':
      '{side} is aan zet: draai om of zet één stap. Zonder slag {count}/{limit}.',
  'selectionCanceled':
      'Selectie geannuleerd. Je kunt omdraaien of opnieuw kiezen.',
  'selectedPiece': '{side} koos {piece}.',
  'choosePieceFirst':
      'Draai eerst een verborgen stuk om, of kies een eigen stuk om te bewegen.',
  'selectedPieceMissing': 'Het gekozen stuk is weg. Kies opnieuw.',
  'flippedPiece': '{actor} draaide {piece} van {side} om.',
  'oneStepOnly':
      'Je kunt maar één vak omhoog, omlaag, links of rechts bewegen.',
  'movedToEmpty': '{actor} verplaatste {piece} naar een leeg vak.',
  'cannotMoveToHidden':
      'Je kunt niet op een verborgen stuk zetten. Draai het om.',
  'cannotCaptureOwn': 'Je kunt je eigen stuk niet slaan.',
  'cannotCapture': '{attacker} kan {defender} niet slaan.',
  'mutualElimination':
      '{attacker} van {actor} en {defender} van {defenderSide} schakelden elkaar uit.',
  'capturedPiece':
      '{attacker} van {actor} sloeg {defender} van {defenderSide}.',
  'winnerNoLegalAction':
      '{side} wint. De tegenstander heeft geen legale actie.',
  'winnerElimination':
      '{side} wint na het slaan van alle vijandelijke stukken.',
  'drawNonCaptureLimit': '{limit} beurten zonder slag. Gelijkspel.',
  'drawNoLegalActions': 'Geen enkele kant heeft een legale actie. Gelijkspel.',
  'drawMutualElimination':
      'De laatste stukken schakelden elkaar uit. Gelijkspel.',
  'turnMessage':
      '{side} is aan zet: draai om of zet één stap. Zonder slag {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} heeft nog {remaining} stuk(ken), inclusief verborgen stukken.\n{turn}',
  'currentTurn': 'Huidige beurt: {side}',
  'victoryHeading': 'Overwinning voor {side}',
  'sideRemaining': '{side} over',
  'piecesCount': '{count} stuk(ken)',
  'gameOverWinner': '{side} wint',
  'rule1':
      '1. Het bord is 4 x 4, met 16 stukken. Rood en Blauw hebben elk rangen 1 tot 8.',
  'rule2':
      '2. Kies elke beurt één actie: een verborgen stuk omdraaien of een eigen open stuk één stap verplaatsen.',
  'rule3':
      '3. Stukken bewegen alleen omhoog, omlaag, links of rechts. Geen diagonalen en geen meerdere vakken.',
  'rule4':
      '4. Slaan kan alleen op een open vijandelijk stuk met een gelijk of lager nummer. Speciale regel: 1 slaat 8, maar 8 slaat 1 niet.',
  'rule5': '5. Bij gelijke nummers verdwijnen beide stukken.',
  'rule6':
      '6. Sla alle vijandelijke stukken om te winnen. Verdwijnen de laatste stukken samen, dan is het gelijkspel.',
  'rule7':
      '7. Als er geen verborgen stukken zijn en één kant niet kan handelen, wint de andere. Kunnen beide niet handelen, dan is het gelijkspel.',
  'rule8':
      '8. {limit} opeenvolgende beurten zonder slag is gelijkspel. De teller reset na een slag.',
  'rule9': '9. Geslagen vakken worden leeg en kunnen later worden betreden.',
};

const Map<String, String> _polishStrings = <String, String>{
  'settingsTooltip': 'Ustawienia',
  'settingsTitle': 'Ustawienia',
  'soundEffects': 'Efekty dźwiękowe',
  'languageLabel': 'Język interfejsu',
  'done': 'Gotowe',
  'resetButton': 'Restart',
  'resetTitle': 'Rozpocząć od nowa?',
  'resetContent': 'Bieżąca partia zostanie wyczyszczona.',
  'continueGame': 'Graj dalej',
  'undoButton': 'Cofnij',
  'undoUnavailable': 'To już początek',
  'undoTitle': 'Potwierdzić cofnięcie?',
  'undoContent': 'Po obejrzeniu reklamy gra cofnie się o jeden ruch.',
  'cancel': 'Anuluj',
  'watchAdAndUndo': 'Obejrzyj reklamę i cofnij',
  'undoingLabel': 'Cofanie',
  'rulesTitle': 'Zasady',
  'drawHeading': 'Remis',
  'gameOverPrompt': 'Dotknij restart, aby zacząć następną partię',
  'side.red': 'Czerwone',
  'side.blue': 'Niebieskie',
  'animal.1': 'Szczur',
  'animal.2': 'Kot',
  'animal.3': 'Pies',
  'animal.4': 'Wilk',
  'animal.5': 'Lampart',
  'animal.6': 'Tygrys',
  'animal.7': 'Lew',
  'animal.8': 'Słoń',
  'pieceLabel': 'Nr {rank} {animal}',
  'openingTurn':
      '{side} zaczynają: w każdej turze odkryj zakrytą figurę albo przesuń własną.',
  'adThenUndo': 'Ruch zostanie cofnięty po reklamie.',
  'undoingStatus': 'Cofanie...',
  'undoRestoredOpening': 'Cofnięto, powrót do początku. {next}',
  'undoRestoredPrevious': 'Cofnięto, powrót do poprzedniego ruchu. {next}',
  'undoTurn':
      'Tura: {side}. Odkryj figurę lub rusz o krok. Bez bicia {count}/{limit}.',
  'selectionCanceled':
      'Wybór anulowany. Możesz odkryć figurę lub wybrać ponownie.',
  'selectedPiece': '{side} wybrały {piece}.',
  'choosePieceFirst':
      'Najpierw odkryj zakrytą figurę albo wybierz własną figurę do ruchu.',
  'selectedPieceMissing': 'Wybrana figura zniknęła. Wybierz ponownie.',
  'flippedPiece': '{actor} odkryły {piece} strony {side}.',
  'oneStepOnly':
      'Możesz ruszyć tylko o jedno pole w górę, dół, lewo lub prawo.',
  'movedToEmpty': '{actor} przesunęły {piece} na puste pole.',
  'cannotMoveToHidden': 'Nie możesz wejść na zakrytą figurę. Trzeba ją odkryć.',
  'cannotCaptureOwn': 'Nie możesz bić własnej figury.',
  'cannotCapture': '{attacker} nie może zbić {defender}.',
  'mutualElimination':
      '{attacker} strony {actor} i {defender} strony {defenderSide} usunęły się wzajemnie.',
  'capturedPiece':
      '{attacker} strony {actor} zbił {defender} strony {defenderSide}.',
  'winnerNoLegalAction': '{side} wygrywają. Przeciwnik nie ma legalnej akcji.',
  'winnerElimination':
      '{side} wygrywają po zbiciu wszystkich figur przeciwnika.',
  'drawNonCaptureLimit': '{limit} tur bez bicia. Remis.',
  'drawNoLegalActions': 'Żadna strona nie ma legalnej akcji. Remis.',
  'drawMutualElimination': 'Ostatnie figury usunęły się wzajemnie. Remis.',
  'turnMessage':
      'Tura: {side}. Odkryj figurę lub rusz o krok. Bez bicia {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} mają jeszcze {remaining} figur, w tym zakryte.\n{turn}',
  'currentTurn': 'Aktualna tura: {side}',
  'victoryHeading': 'Zwycięstwo: {side}',
  'sideRemaining': 'Pozostało: {side}',
  'piecesCount': '{count} figur',
  'gameOverWinner': '{side} wygrywają',
  'rule1':
      '1. Plansza ma 4 x 4 pola i 16 figur. Czerwone i Niebieskie mają rangi od 1 do 8.',
  'rule2':
      '2. W każdej turze wybierz jedną akcję: odkryj zakrytą figurę albo przesuń własną odkrytą figurę o krok.',
  'rule3':
      '3. Figury poruszają się tylko w górę, dół, lewo lub prawo. Bez skosów i ruchów wielopolowych.',
  'rule4':
      '4. Bić można odkrytą figurę przeciwnika o numerze równym lub niższym. Zasada specjalna: 1 bije 8, ale 8 nie bije 1.',
  'rule5': '5. Jeśli numery są takie same, obie figury znikają.',
  'rule6':
      '6. Zbij wszystkie figury przeciwnika, aby wygrać. Jeśli ostatnie figury znikną razem, jest remis.',
  'rule7':
      '7. Jeśli nie ma zakrytych figur, a jedna strona nie może działać, wygrywa druga. Jeśli obie nie mogą działać, jest remis.',
  'rule8':
      '8. {limit} kolejnych tur bez bicia oznacza remis. Licznik resetuje się po biciu.',
  'rule9':
      '9. Pola po zbitych figurach stają się puste i można na nie później wejść.',
};

const Map<String, String> _romanianStrings = <String, String>{
  'settingsTooltip': 'Setări',
  'settingsTitle': 'Setări',
  'soundEffects': 'Efecte sonore',
  'languageLabel': 'Limba interfeței',
  'done': 'Gata',
  'resetButton': 'Reîncepe',
  'resetTitle': 'Reîncepi?',
  'resetContent': 'Partida curentă va fi ștearsă.',
  'continueGame': 'Continuă jocul',
  'undoButton': 'Anulează',
  'undoUnavailable': 'Ești deja la început',
  'undoTitle': 'Confirmi anularea?',
  'undoContent': 'După o reclamă, partida revine cu o mutare în urmă.',
  'cancel': 'Renunță',
  'watchAdAndUndo': 'Vezi reclama și anulează',
  'undoingLabel': 'Se anulează',
  'rulesTitle': 'Reguli',
  'drawHeading': 'Remiză',
  'gameOverPrompt': 'Atinge reîncepe pentru partida următoare',
  'side.red': 'Roșu',
  'side.blue': 'Albastru',
  'animal.1': 'Șobolan',
  'animal.2': 'Pisică',
  'animal.3': 'Câine',
  'animal.4': 'Lup',
  'animal.5': 'Leopard',
  'animal.6': 'Tigru',
  'animal.7': 'Leu',
  'animal.8': 'Elefant',
  'pieceLabel': 'Nr. {rank} {animal}',
  'openingTurn':
      '{side} începe: la fiecare tură întoarce o piesă ascunsă sau mută o piesă proprie.',
  'adThenUndo': 'Mutarea va fi anulată după reclamă.',
  'undoingStatus': 'Se anulează...',
  'undoRestoredOpening': 'Anulat, înapoi la început. {next}',
  'undoRestoredPrevious': 'Anulat, înapoi la mutarea anterioară. {next}',
  'undoTurn':
      'Rândul lui {side}: întoarce sau mută un pas. Fără capturi {count}/{limit}.',
  'selectionCanceled': 'Selecție anulată. Poți întoarce sau alege altă piesă.',
  'selectedPiece': '{side} a selectat {piece}.',
  'choosePieceFirst':
      'Întoarce întâi o piesă ascunsă sau selectează o piesă proprie înainte de mutare.',
  'selectedPieceMissing': 'Piesa selectată nu mai există. Alege din nou.',
  'flippedPiece': '{actor} a întors {piece} de la {side}.',
  'oneStepOnly': 'Poți muta doar o căsuță în sus, jos, stânga sau dreapta.',
  'movedToEmpty': '{actor} a mutat {piece} pe o căsuță goală.',
  'cannotMoveToHidden': 'Nu poți muta pe o piesă ascunsă. Întoarce-o.',
  'cannotCaptureOwn': 'Nu poți captura propria piesă.',
  'cannotCapture': '{attacker} nu poate captura {defender}.',
  'mutualElimination':
      '{attacker} de la {actor} și {defender} de la {defenderSide} s-au eliminat reciproc.',
  'capturedPiece':
      '{attacker} de la {actor} a capturat {defender} de la {defenderSide}.',
  'winnerNoLegalAction':
      '{side} câștigă. Adversarul nu mai are acțiuni legale.',
  'winnerElimination':
      '{side} câștigă după ce capturează toate piesele adverse.',
  'drawNonCaptureLimit': '{limit} ture fără captură. Remiză.',
  'drawNoLegalActions': 'Nicio parte nu are acțiuni legale. Remiză.',
  'drawMutualElimination': 'Ultimele piese s-au eliminat reciproc. Remiză.',
  'turnMessage':
      'Rândul lui {side}: întoarce sau mută un pas. Fără capturi {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} mai are {remaining} piesă(e), inclusiv ascunse.\n{turn}',
  'currentTurn': 'Rândul curent: {side}',
  'victoryHeading': 'Victorie pentru {side}',
  'sideRemaining': 'Rămase pentru {side}',
  'piecesCount': '{count} piesă(e)',
  'gameOverWinner': '{side} câștigă',
  'rule1':
      '1. Tabla este 4 x 4, cu 16 piese. Roșu și Albastru au ranguri de la 1 la 8.',
  'rule2':
      '2. La fiecare tură alege o acțiune: întoarce o piesă ascunsă sau mută o piesă proprie dezvăluită un pas.',
  'rule3':
      '3. Piesele se mută doar sus, jos, stânga sau dreapta. Fără diagonale sau mai multe căsuțe.',
  'rule4':
      '4. Captura vizează o piesă adversă dezvăluită cu număr egal sau mai mic. Regulă specială: 1 capturează 8, dar 8 nu capturează 1.',
  'rule5': '5. Dacă numerele sunt egale, ambele piese dispar.',
  'rule6':
      '6. Capturează toate piesele adverse ca să câștigi. Dacă ultimele dispar împreună, este remiză.',
  'rule7':
      '7. Dacă nu sunt piese ascunse și o parte nu poate acționa, câștigă cealaltă. Dacă niciuna nu poate acționa, este remiză.',
  'rule8':
      '8. {limit} ture consecutive fără captură duc la remiză. Contorul se resetează după captură.',
  'rule9': '9. Căsuțele capturate devin goale și pot fi ocupate mai târziu.',
};

const Map<String, String> _ukrainianStrings = <String, String>{
  'settingsTooltip': 'Налаштування',
  'settingsTitle': 'Налаштування',
  'soundEffects': 'Звукові ефекти',
  'languageLabel': 'Мова інтерфейсу',
  'done': 'Готово',
  'resetButton': 'Почати знову',
  'resetTitle': 'Почати знову?',
  'resetContent': 'Поточну партію буде очищено.',
  'continueGame': 'Грати далі',
  'undoButton': 'Скасувати',
  'undoUnavailable': 'Вже початкова позиція',
  'undoTitle': 'Підтвердити скасування?',
  'undoContent': 'Після реклами гра повернеться на один хід назад.',
  'cancel': 'Скасувати',
  'watchAdAndUndo': 'Дивитися рекламу і скасувати',
  'undoingLabel': 'Скасування',
  'rulesTitle': 'Правила',
  'drawHeading': 'Нічия',
  'gameOverPrompt': 'Натисніть почати знову для наступної партії',
  'side.red': 'Червоні',
  'side.blue': 'Сині',
  'animal.1': 'Щур',
  'animal.2': 'Кіт',
  'animal.3': 'Пес',
  'animal.4': 'Вовк',
  'animal.5': 'Леопард',
  'animal.6': 'Тигр',
  'animal.7': 'Лев',
  'animal.8': 'Слон',
  'pieceLabel': '№ {rank} {animal}',
  'openingTurn':
      '{side} починають: за хід відкрийте приховану фігуру або пересуньте свою.',
  'adThenUndo': 'Хід буде скасовано після реклами.',
  'undoingStatus': 'Скасування...',
  'undoRestoredOpening': 'Скасовано, повернення до початку. {next}',
  'undoRestoredPrevious': 'Скасовано, повернення до попереднього ходу. {next}',
  'undoTurn':
      'Хід {side}: відкрийте фігуру або зробіть крок. Без взяття {count}/{limit}.',
  'selectionCanceled': 'Вибір знято. Можна відкрити фігуру або вибрати знову.',
  'selectedPiece': '{side} вибрали {piece}.',
  'choosePieceFirst':
      'Спочатку відкрийте приховану фігуру або виберіть свою для ходу.',
  'selectedPieceMissing': 'Вибраної фігури вже немає. Виберіть знову.',
  'flippedPiece': '{actor} відкрили {piece} сторони {side}.',
  'oneStepOnly':
      'Можна ходити лише на одну клітинку вгору, вниз, ліворуч або праворуч.',
  'movedToEmpty': '{actor} пересунули {piece} на порожню клітинку.',
  'cannotMoveToHidden':
      'Не можна ходити на приховану фігуру. Її треба відкрити.',
  'cannotCaptureOwn': 'Не можна брати власну фігуру.',
  'cannotCapture': '{attacker} не може взяти {defender}.',
  'mutualElimination':
      '{attacker} сторони {actor} і {defender} сторони {defenderSide} прибрали одне одного.',
  'capturedPiece':
      '{attacker} сторони {actor} взяв {defender} сторони {defenderSide}.',
  'winnerNoLegalAction': '{side} перемагають. У суперника немає легальної дії.',
  'winnerElimination': '{side} перемагають, узявши всі фігури суперника.',
  'drawNonCaptureLimit': '{limit} ходів без взяття. Нічия.',
  'drawNoLegalActions': 'Жодна сторона не має легальної дії. Нічия.',
  'drawMutualElimination': 'Останні фігури прибрали одна одну. Нічия.',
  'turnMessage':
      'Хід {side}: відкрийте фігуру або зробіть крок. Без взяття {count}/{limit}.',
  'remainingAfterCapture':
      '{action} У {side} залишилось {remaining} фігур(и), включно з прихованими.\n{turn}',
  'currentTurn': 'Поточний хід: {side}',
  'victoryHeading': 'Перемога: {side}',
  'sideRemaining': 'Залишилось у {side}',
  'piecesCount': '{count} фігур(и)',
  'gameOverWinner': '{side} перемагають',
  'rule1':
      '1. Дошка 4 x 4, усього 16 фігур. Червоні й Сині мають ранги від 1 до 8.',
  'rule2':
      '2. За хід виберіть одну дію: відкрити приховану фігуру або пересунути свою відкриту фігуру на крок.',
  'rule3':
      '3. Фігури ходять лише вгору, вниз, ліворуч або праворуч. Без діагоналей і багатоклітинних ходів.',
  'rule4':
      '4. Брати можна відкриту фігуру суперника з рівним або меншим номером. Особливе правило: 1 бере 8, але 8 не бере 1.',
  'rule5': '5. Якщо номери однакові, обидві фігури зникають.',
  'rule6':
      '6. Візьміть усі фігури суперника, щоб перемогти. Якщо останні зникають разом, це нічия.',
  'rule7':
      '7. Якщо прихованих фігур немає і одна сторона не може діяти, перемагає інша. Якщо обидві не можуть діяти, нічия.',
  'rule8':
      '8. {limit} ходів поспіль без взяття дають нічию. Після взяття лічильник скидається.',
  'rule9':
      '9. Клітинки після взяття стають порожніми, на них можна ходити пізніше.',
};

const Map<String, String> _turkishStrings = <String, String>{
  'settingsTooltip': 'Ayarlar',
  'settingsTitle': 'Ayarlar',
  'soundEffects': 'Ses efektleri',
  'languageLabel': 'Arayüz dili',
  'done': 'Bitti',
  'resetButton': 'Yeniden başlat',
  'resetTitle': 'Yeniden başlat?',
  'resetContent': 'Geçerli oyun temizlenecek.',
  'continueGame': 'Oynamaya devam et',
  'undoButton': 'Geri al',
  'undoUnavailable': 'Zaten başlangıçtasın',
  'undoTitle': 'Geri alma onaylansın mı?',
  'undoContent': 'Reklamdan sonra oyun bir hamle geri gider.',
  'cancel': 'İptal',
  'watchAdAndUndo': 'Reklam izle ve geri al',
  'undoingLabel': 'Geri alınıyor',
  'rulesTitle': 'Kurallar',
  'drawHeading': 'Berabere',
  'gameOverPrompt': 'Sonraki oyun için yeniden başlata dokun',
  'side.red': 'Kırmızı',
  'side.blue': 'Mavi',
  'animal.1': 'Fare',
  'animal.2': 'Kedi',
  'animal.3': 'Köpek',
  'animal.4': 'Kurt',
  'animal.5': 'Leopar',
  'animal.6': 'Kaplan',
  'animal.7': 'Aslan',
  'animal.8': 'Fil',
  'pieceLabel': 'No. {rank} {animal}',
  'openingTurn':
      '{side} başlar: her tur gizli bir taşı aç veya kendi taşını hareket ettir.',
  'adThenUndo': 'Hamle reklamdan sonra geri alınacak.',
  'undoingStatus': 'Geri alınıyor...',
  'undoRestoredOpening': 'Geri alındı, başlangıca dönüldü. {next}',
  'undoRestoredPrevious': 'Geri alındı, önceki hamleye dönüldü. {next}',
  'undoTurn':
      'Sıra {side}: taşı aç veya bir adım ilerle. Yakalama yok {count}/{limit}.',
  'selectionCanceled':
      'Seçim iptal edildi. Taş açabilir veya yeniden seçebilirsin.',
  'selectedPiece': '{side}, {piece} seçti.',
  'choosePieceFirst':
      'Önce gizli bir taş aç ya da hareket etmeden önce kendi taşını seç.',
  'selectedPieceMissing': 'Seçilen taş artık yok. Yeniden seç.',
  'flippedPiece': '{actor}, {side} tarafının {piece} taşını açtı.',
  'oneStepOnly':
      'Sadece bir kare yukarı, aşağı, sola veya sağa hareket edebilirsin.',
  'movedToEmpty': '{actor}, {piece} taşını boş kareye taşıdı.',
  'cannotMoveToHidden': 'Gizli taşın üstüne gidemezsin. Önce onu aç.',
  'cannotCaptureOwn': 'Kendi taşını yakalayamazsın.',
  'cannotCapture': '{attacker}, {defender} taşını yakalayamaz.',
  'mutualElimination':
      '{actor} tarafının {attacker} taşı ile {defenderSide} tarafının {defender} taşı birbirini yok etti.',
  'capturedPiece':
      '{actor} tarafının {attacker} taşı, {defenderSide} tarafının {defender} taşını yakaladı.',
  'winnerNoLegalAction': '{side} kazanır. Rakibin yasal hamlesi yok.',
  'winnerElimination': '{side}, rakibin tüm taşlarını yakalayarak kazanır.',
  'drawNonCaptureLimit': '{limit} tur yakalama yok. Berabere.',
  'drawNoLegalActions': 'Hiçbir tarafın yasal hamlesi yok. Berabere.',
  'drawMutualElimination': 'Son taşlar birbirini yok etti. Berabere.',
  'turnMessage':
      'Sıra {side}: taşı aç veya bir adım ilerle. Yakalama yok {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} tarafında gizliler dahil {remaining} taş kaldı.\n{turn}',
  'currentTurn': 'Geçerli sıra: {side}',
  'victoryHeading': '{side} zaferi',
  'sideRemaining': '{side} kalan',
  'piecesCount': '{count} taş',
  'gameOverWinner': '{side} kazandı',
  'rule1':
      '1. Tahta 4 x 4 ve 16 taştan oluşur. Kırmızı ve Mavi 1’den 8’e kadar rütbelere sahiptir.',
  'rule2':
      '2. Her tur bir eylem seç: gizli taşı aç veya açık kendi taşını bir adım hareket ettir.',
  'rule3':
      '3. Taşlar sadece yukarı, aşağı, sola veya sağa gider. Çapraz veya çok kareli hareket yoktur.',
  'rule4':
      '4. Yakalama, açık rakip taşın numarası eşit veya düşükse yapılır. Özel kural: 1, 8’i yakalar; 8, 1’i yakalayamaz.',
  'rule5': '5. Numaralar aynıysa iki taş da kaybolur.',
  'rule6':
      '6. Rakibin tüm taşlarını yakalayarak kazan. Son taşlar birlikte kaybolursa oyun berabere biter.',
  'rule7':
      '7. Gizli taş yoksa ve bir taraf hareket edemiyorsa rakip kazanır. İkisi de hareket edemezse berabere.',
  'rule8':
      '8. Üst üste {limit} tur yakalama olmazsa berabere. Yakalama sonrası sayaç sıfırlanır.',
  'rule9': '9. Yakalanan kareler boşalır ve sonra içine girilebilir.',
};

const Map<String, String> _greekStrings = <String, String>{
  'settingsTooltip': 'Ρυθμίσεις',
  'settingsTitle': 'Ρυθμίσεις',
  'soundEffects': 'Ηχητικά εφέ',
  'languageLabel': 'Γλώσσα διεπαφής',
  'done': 'Τέλος',
  'resetButton': 'Επανεκκίνηση',
  'resetTitle': 'Επανεκκίνηση;',
  'resetContent': 'Η τρέχουσα παρτίδα θα διαγραφεί.',
  'continueGame': 'Συνέχεια',
  'undoButton': 'Αναίρεση',
  'undoUnavailable': 'Ήδη στην αρχή',
  'undoTitle': 'Επιβεβαίωση αναίρεσης;',
  'undoContent': 'Μετά από διαφήμιση, η παρτίδα θα γυρίσει μία κίνηση πίσω.',
  'cancel': 'Άκυρο',
  'watchAdAndUndo': 'Δες διαφήμιση και αναίρεσε',
  'undoingLabel': 'Αναίρεση',
  'rulesTitle': 'Κανόνες',
  'drawHeading': 'Ισοπαλία',
  'gameOverPrompt': 'Πάτησε επανεκκίνηση για την επόμενη παρτίδα',
  'side.red': 'Κόκκινο',
  'side.blue': 'Μπλε',
  'animal.1': 'Αρουραίος',
  'animal.2': 'Γάτα',
  'animal.3': 'Σκύλος',
  'animal.4': 'Λύκος',
  'animal.5': 'Λεοπάρδαλη',
  'animal.6': 'Τίγρη',
  'animal.7': 'Λιοντάρι',
  'animal.8': 'Ελέφαντας',
  'pieceLabel': 'Νο. {rank} {animal}',
  'openingTurn':
      '{side} ξεκινά: κάθε γύρο, γύρισε ένα κρυφό κομμάτι ή κίνησε ένα δικό σου.',
  'adThenUndo': 'Η κίνηση θα αναιρεθεί μετά τη διαφήμιση.',
  'undoingStatus': 'Αναίρεση...',
  'undoRestoredOpening': 'Αναιρέθηκε, πίσω στην αρχή. {next}',
  'undoRestoredPrevious': 'Αναιρέθηκε, πίσω στην προηγούμενη κίνηση. {next}',
  'undoTurn':
      'Σειρά του {side}: γύρισε ή κίνησε ένα βήμα. Χωρίς αιχμαλωσία {count}/{limit}.',
  'selectionCanceled':
      'Η επιλογή ακυρώθηκε. Μπορείς να γυρίσεις ή να επιλέξεις ξανά.',
  'selectedPiece': '{side} επέλεξε {piece}.',
  'choosePieceFirst':
      'Γύρισε πρώτα ένα κρυφό κομμάτι ή επίλεξε δικό σου κομμάτι για κίνηση.',
  'selectedPieceMissing':
      'Το επιλεγμένο κομμάτι δεν υπάρχει πια. Επίλεξε ξανά.',
  'flippedPiece': '{actor} γύρισε {piece} του {side}.',
  'oneStepOnly':
      'Μπορείς να κινηθείς μόνο ένα τετράγωνο πάνω, κάτω, αριστερά ή δεξιά.',
  'movedToEmpty': '{actor} κίνησε {piece} σε άδειο τετράγωνο.',
  'cannotMoveToHidden': 'Δεν μπορείς να πας πάνω σε κρυφό κομμάτι. Γύρισέ το.',
  'cannotCaptureOwn': 'Δεν μπορείς να αιχμαλωτίσεις δικό σου κομμάτι.',
  'cannotCapture': '{attacker} δεν μπορεί να αιχμαλωτίσει {defender}.',
  'mutualElimination':
      '{attacker} του {actor} και {defender} του {defenderSide} εξουδετερώθηκαν μαζί.',
  'capturedPiece':
      '{attacker} του {actor} αιχμαλώτισε {defender} του {defenderSide}.',
  'winnerNoLegalAction':
      '{side} κερδίζει. Ο αντίπαλος δεν έχει νόμιμη ενέργεια.',
  'winnerElimination':
      '{side} κερδίζει αιχμαλωτίζοντας όλα τα αντίπαλα κομμάτια.',
  'drawNonCaptureLimit': '{limit} γύροι χωρίς αιχμαλωσία. Ισοπαλία.',
  'drawNoLegalActions': 'Καμία πλευρά δεν έχει νόμιμη ενέργεια. Ισοπαλία.',
  'drawMutualElimination': 'Τα τελευταία κομμάτια εξουδετερώθηκαν. Ισοπαλία.',
  'turnMessage':
      'Σειρά του {side}: γύρισε ή κίνησε ένα βήμα. Χωρίς αιχμαλωσία {count}/{limit}.',
  'remainingAfterCapture':
      '{action} Το {side} έχει ακόμη {remaining} κομμάτι(α), μαζί με τα κρυφά.\n{turn}',
  'currentTurn': 'Τρέχουσα σειρά: {side}',
  'victoryHeading': 'Νίκη για {side}',
  'sideRemaining': 'Απομένουν για {side}',
  'piecesCount': '{count} κομμάτι(α)',
  'gameOverWinner': '{side} κερδίζει',
  'rule1':
      '1. Το ταμπλό είναι 4 x 4 με 16 κομμάτια. Κόκκινο και Μπλε έχουν βαθμούς 1 έως 8.',
  'rule2':
      '2. Κάθε γύρο διάλεξε μία ενέργεια: γύρισε κρυφό κομμάτι ή κίνησε ανοιχτό δικό σου κομμάτι ένα βήμα.',
  'rule3':
      '3. Τα κομμάτια κινούνται μόνο πάνω, κάτω, αριστερά ή δεξιά. Όχι διαγώνια ή πολλά τετράγωνα.',
  'rule4':
      '4. Η αιχμαλωσία γίνεται σε ανοιχτό αντίπαλο κομμάτι με ίσο ή μικρότερο αριθμό. Ειδικός κανόνας: το 1 πιάνει το 8, αλλά το 8 δεν πιάνει το 1.',
  'rule5': '5. Αν οι αριθμοί είναι ίδιοι, εξαφανίζονται και τα δύο κομμάτια.',
  'rule6':
      '6. Αιχμαλώτισε όλα τα αντίπαλα κομμάτια για να κερδίσεις. Αν τα τελευταία εξαφανιστούν μαζί, είναι ισοπαλία.',
  'rule7':
      '7. Αν δεν υπάρχουν κρυφά κομμάτια και μία πλευρά δεν μπορεί να δράσει, κερδίζει η άλλη. Αν δεν μπορεί καμία, είναι ισοπαλία.',
  'rule8':
      '8. {limit} συνεχόμενοι γύροι χωρίς αιχμαλωσία φέρνουν ισοπαλία. Ο μετρητής μηδενίζεται μετά από αιχμαλωσία.',
  'rule9':
      '9. Τα τετράγωνα αιχμαλωσίας γίνονται άδεια και μπορούν να χρησιμοποιηθούν αργότερα.',
};

const Map<String, String> _swedishStrings = <String, String>{
  'settingsTooltip': 'Inställningar',
  'settingsTitle': 'Inställningar',
  'soundEffects': 'Ljudeffekter',
  'languageLabel': 'Gränssnittsspråk',
  'done': 'Klar',
  'resetButton': 'Starta om',
  'resetTitle': 'Starta om?',
  'resetContent': 'Det aktuella spelet rensas.',
  'continueGame': 'Fortsätt spela',
  'undoButton': 'Ångra',
  'undoUnavailable': 'Redan vid start',
  'undoTitle': 'Bekräfta ångra?',
  'undoContent': 'Efter en annons går spelet tillbaka ett drag.',
  'cancel': 'Avbryt',
  'watchAdAndUndo': 'Se annons och ångra',
  'undoingLabel': 'Ångrar',
  'rulesTitle': 'Regler',
  'drawHeading': 'Oavgjort',
  'gameOverPrompt': 'Tryck starta om för nästa spel',
  'side.red': 'Röd',
  'side.blue': 'Blå',
  'animal.1': 'Råtta',
  'animal.2': 'Katt',
  'animal.3': 'Hund',
  'animal.4': 'Varg',
  'animal.5': 'Leopard',
  'animal.6': 'Tiger',
  'animal.7': 'Lejon',
  'animal.8': 'Elefant',
  'pieceLabel': 'Nr {rank} {animal}',
  'openingTurn':
      '{side} börjar: vänd en dold pjäs eller flytta en egen pjäs varje tur.',
  'adThenUndo': 'Draget ångras efter annonsen.',
  'undoingStatus': 'Ångrar...',
  'undoRestoredOpening': 'Ångrat, tillbaka till start. {next}',
  'undoRestoredPrevious': 'Ångrat, tillbaka till föregående drag. {next}',
  'undoTurn':
      '{side}s tur: vänd eller flytta ett steg. Utan slag {count}/{limit}.',
  'selectionCanceled': 'Valet avbröts. Du kan vända en pjäs eller välja igen.',
  'selectedPiece': '{side} valde {piece}.',
  'choosePieceFirst':
      'Vänd först en dold pjäs eller välj en egen pjäs att flytta.',
  'selectedPieceMissing': 'Den valda pjäsen finns inte längre. Välj igen.',
  'flippedPiece': '{actor} vände {side}s {piece}.',
  'oneStepOnly': 'Du kan bara flytta en ruta upp, ner, vänster eller höger.',
  'movedToEmpty': '{actor} flyttade {piece} till en tom ruta.',
  'cannotMoveToHidden': 'Du kan inte flytta till en dold pjäs. Vänd den.',
  'cannotCaptureOwn': 'Du kan inte slå din egen pjäs.',
  'cannotCapture': '{attacker} kan inte slå {defender}.',
  'mutualElimination':
      '{actor}s {attacker} och {defenderSide}s {defender} slog ut varandra.',
  'capturedPiece': '{actor}s {attacker} slog {defenderSide}s {defender}.',
  'winnerNoLegalAction':
      '{side} vinner. Motståndaren har ingen laglig handling.',
  'winnerElimination':
      '{side} vinner efter att ha slagit alla motståndarens pjäser.',
  'drawNonCaptureLimit': '{limit} turer utan slag. Oavgjort.',
  'drawNoLegalActions': 'Ingen sida har en laglig handling. Oavgjort.',
  'drawMutualElimination': 'De sista pjäserna slog ut varandra. Oavgjort.',
  'turnMessage':
      '{side}s tur: vänd eller flytta ett steg. Utan slag {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} har {remaining} pjäs(er) kvar, inklusive dolda.\n{turn}',
  'currentTurn': 'Aktuell tur: {side}',
  'victoryHeading': 'Seger för {side}',
  'sideRemaining': '{side} kvar',
  'piecesCount': '{count} pjäs(er)',
  'gameOverWinner': '{side} vinner',
  'rule1': '1. Brädet är 4 x 4 med 16 pjäser. Röd och Blå har ranker 1 till 8.',
  'rule2':
      '2. Välj en handling varje tur: vänd en dold pjäs eller flytta en egen synlig pjäs ett steg.',
  'rule3':
      '3. Pjäser går bara upp, ner, vänster eller höger. Inga diagonaler eller flera rutor.',
  'rule4':
      '4. Slag måste vara mot en synlig motståndarpjäs med lika eller lägre nummer. Specialregel: 1 slår 8, men 8 slår inte 1.',
  'rule5': '5. Om numren är samma försvinner båda pjäserna.',
  'rule6':
      '6. Slå alla motståndarens pjäser för att vinna. Om de sista försvinner tillsammans blir det oavgjort.',
  'rule7':
      '7. Om inga dolda pjäser finns och en sida inte kan agera vinner den andra. Om ingen kan agera blir det oavgjort.',
  'rule8':
      '8. {limit} turer i rad utan slag ger oavgjort. Räknaren nollställs efter slag.',
  'rule9': '9. Slagna rutor blir tomma och kan senare flyttas till.',
};

const Map<String, String> _czechStrings = <String, String>{
  'settingsTooltip': 'Nastavení',
  'settingsTitle': 'Nastavení',
  'soundEffects': 'Zvukové efekty',
  'languageLabel': 'Jazyk rozhraní',
  'done': 'Hotovo',
  'resetButton': 'Restartovat',
  'resetTitle': 'Restartovat?',
  'resetContent': 'Aktuální hra bude vymazána.',
  'continueGame': 'Pokračovat',
  'undoButton': 'Zpět',
  'undoUnavailable': 'Už je to začátek',
  'undoTitle': 'Potvrdit krok zpět?',
  'undoContent': 'Po reklamě se hra vrátí o jeden tah.',
  'cancel': 'Zrušit',
  'watchAdAndUndo': 'Zhlédnout reklamu a zpět',
  'undoingLabel': 'Vrací se',
  'rulesTitle': 'Pravidla',
  'drawHeading': 'Remíza',
  'gameOverPrompt': 'Klepni na restart pro další hru',
  'side.red': 'Červená',
  'side.blue': 'Modrá',
  'animal.1': 'Krysa',
  'animal.2': 'Kočka',
  'animal.3': 'Pes',
  'animal.4': 'Vlk',
  'animal.5': 'Leopard',
  'animal.6': 'Tygr',
  'animal.7': 'Lev',
  'animal.8': 'Slon',
  'pieceLabel': 'Č. {rank} {animal}',
  'openingTurn':
      '{side} začíná: každý tah otoč skrytou figurku nebo pohni vlastní.',
  'adThenUndo': 'Tah se vrátí po reklamě.',
  'undoingStatus': 'Vrací se...',
  'undoRestoredOpening': 'Vráceno, zpět na začátek. {next}',
  'undoRestoredPrevious': 'Vráceno, zpět na předchozí tah. {next}',
  'undoTurn':
      'Na tahu je {side}: otoč nebo pohni o krok. Bez braní {count}/{limit}.',
  'selectionCanceled': 'Výběr zrušen. Můžeš otočit figurku nebo vybrat znovu.',
  'selectedPiece': '{side} vybrala {piece}.',
  'choosePieceFirst':
      'Nejprve otoč skrytou figurku nebo vyber vlastní figurku k tahu.',
  'selectedPieceMissing': 'Vybraná figurka už neexistuje. Vyber znovu.',
  'flippedPiece': '{actor} otočila {piece} strany {side}.',
  'oneStepOnly':
      'Můžeš táhnout jen o jedno pole nahoru, dolů, vlevo nebo vpravo.',
  'movedToEmpty': '{actor} posunula {piece} na prázdné pole.',
  'cannotMoveToHidden': 'Nemůžeš táhnout na skrytou figurku. Musíš ji otočit.',
  'cannotCaptureOwn': 'Nemůžeš brát vlastní figurku.',
  'cannotCapture': '{attacker} nemůže vzít {defender}.',
  'mutualElimination':
      '{attacker} strany {actor} a {defender} strany {defenderSide} se vyřadily navzájem.',
  'capturedPiece':
      '{attacker} strany {actor} vzala {defender} strany {defenderSide}.',
  'winnerNoLegalAction': '{side} vítězí. Soupeř nemá legální akci.',
  'winnerElimination': '{side} vítězí po sebrání všech soupeřových figurek.',
  'drawNonCaptureLimit': '{limit} tahů bez braní. Remíza.',
  'drawNoLegalActions': 'Žádná strana nemá legální akci. Remíza.',
  'drawMutualElimination': 'Poslední figurky se vyřadily navzájem. Remíza.',
  'turnMessage':
      'Na tahu je {side}: otoč nebo pohni o krok. Bez braní {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} má ještě {remaining} figurek včetně skrytých.\n{turn}',
  'currentTurn': 'Aktuální tah: {side}',
  'victoryHeading': 'Vítězství: {side}',
  'sideRemaining': 'Zbývá pro {side}',
  'piecesCount': '{count} figurek',
  'gameOverWinner': '{side} vítězí',
  'rule1':
      '1. Deska je 4 x 4 a má 16 figurek. Červená a Modrá mají hodnosti 1 až 8.',
  'rule2':
      '2. Každý tah zvol jednu akci: otoč skrytou figurku nebo posuň vlastní odkrytou figurku o krok.',
  'rule3':
      '3. Figurky se pohybují jen nahoru, dolů, vlevo nebo vpravo. Ne diagonálně ani o více polí.',
  'rule4':
      '4. Brát lze odkrytou soupeřovu figurku se stejným nebo nižším číslem. Zvláštní pravidlo: 1 bere 8, ale 8 nebere 1.',
  'rule5': '5. Pokud jsou čísla stejná, obě figurky zmizí.',
  'rule6':
      '6. Seber všechny soupeřovy figurky a vyhraj. Pokud poslední zmizí spolu, je remíza.',
  'rule7':
      '7. Pokud nejsou skryté figurky a jedna strana nemůže jednat, vyhrává druhá. Pokud nemůže nikdo, je remíza.',
  'rule8':
      '8. {limit} po sobě jdoucích tahů bez braní znamená remízu. Po braní se počítadlo vynuluje.',
  'rule9': '9. Pole po sebrání jsou prázdná a lze na ně později vstoupit.',
};

const Map<String, String> _vietnameseStrings = <String, String>{
  'settingsTooltip': 'Cài đặt',
  'settingsTitle': 'Cài đặt',
  'soundEffects': 'Hiệu ứng âm thanh',
  'languageLabel': 'Ngôn ngữ giao diện',
  'done': 'Xong',
  'resetButton': 'Chơi lại',
  'resetTitle': 'Chơi lại?',
  'resetContent': 'Ván hiện tại sẽ bị xóa.',
  'continueGame': 'Chơi tiếp',
  'undoButton': 'Hoàn tác',
  'undoUnavailable': 'Đã ở thế bắt đầu',
  'undoTitle': 'Xác nhận hoàn tác?',
  'undoContent': 'Sau khi xem quảng cáo, ván sẽ lùi lại một nước.',
  'cancel': 'Hủy',
  'watchAdAndUndo': 'Xem quảng cáo và hoàn tác',
  'undoingLabel': 'Đang hoàn tác',
  'rulesTitle': 'Luật chơi',
  'drawHeading': 'Hòa',
  'gameOverPrompt': 'Chạm chơi lại để bắt đầu ván tiếp theo',
  'side.red': 'Đỏ',
  'side.blue': 'Xanh',
  'animal.1': 'Chuột',
  'animal.2': 'Mèo',
  'animal.3': 'Chó',
  'animal.4': 'Sói',
  'animal.5': 'Báo',
  'animal.6': 'Hổ',
  'animal.7': 'Sư tử',
  'animal.8': 'Voi',
  'pieceLabel': 'Số {rank} {animal}',
  'openingTurn':
      '{side} đi trước: mỗi lượt lật một quân úp hoặc di chuyển quân của mình.',
  'adThenUndo': 'Nước đi sẽ được hoàn tác sau quảng cáo.',
  'undoingStatus': 'Đang hoàn tác...',
  'undoRestoredOpening': 'Đã hoàn tác, quay lại thế đầu. {next}',
  'undoRestoredPrevious': 'Đã hoàn tác, quay lại nước trước. {next}',
  'undoTurn':
      'Đến lượt {side}: lật quân hoặc đi một bước. Không ăn quân {count}/{limit}.',
  'selectionCanceled': 'Đã hủy chọn. Bạn có thể lật quân hoặc chọn lại.',
  'selectedPiece': '{side} đã chọn {piece}.',
  'choosePieceFirst':
      'Hãy lật một quân úp trước, hoặc chọn quân của bạn rồi mới đi.',
  'selectedPieceMissing': 'Quân đã chọn không còn nữa. Hãy chọn lại.',
  'flippedPiece': '{actor} đã lật {piece} của {side}.',
  'oneStepOnly': 'Chỉ được đi một ô lên, xuống, trái hoặc phải.',
  'movedToEmpty': '{actor} đã di chuyển {piece} vào ô trống.',
  'cannotMoveToHidden': 'Không thể đi lên quân úp. Hãy lật nó.',
  'cannotCaptureOwn': 'Không thể ăn quân của mình.',
  'cannotCapture': '{attacker} không thể ăn {defender}.',
  'mutualElimination':
      '{attacker} của {actor} và {defender} của {defenderSide} cùng biến mất.',
  'capturedPiece':
      '{attacker} của {actor} đã ăn {defender} của {defenderSide}.',
  'winnerNoLegalAction': '{side} thắng. Đối thủ không còn nước hợp lệ.',
  'winnerElimination': '{side} thắng sau khi ăn hết quân đối thủ.',
  'drawNonCaptureLimit': '{limit} lượt không ăn quân. Hòa.',
  'drawNoLegalActions': 'Không bên nào có nước hợp lệ. Hòa.',
  'drawMutualElimination': 'Các quân cuối cùng cùng biến mất. Hòa.',
  'turnMessage':
      'Đến lượt {side}: lật quân hoặc đi một bước. Không ăn quân {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} còn {remaining} quân, gồm cả quân úp.\n{turn}',
  'currentTurn': 'Lượt hiện tại: {side}',
  'victoryHeading': '{side} thắng',
  'sideRemaining': '{side} còn lại',
  'piecesCount': '{count} quân',
  'gameOverWinner': '{side} thắng',
  'rule1': '1. Bàn cờ 4 x 4, có 16 quân. Đỏ và Xanh mỗi bên có cấp 1 đến 8.',
  'rule2':
      '2. Mỗi lượt chọn một hành động: lật quân úp hoặc đi một quân đã lật của mình một bước.',
  'rule3':
      '3. Quân chỉ đi lên, xuống, trái hoặc phải. Không đi chéo và không đi nhiều ô.',
  'rule4':
      '4. Chỉ ăn quân đối phương đã lật có số bằng hoặc nhỏ hơn. Luật đặc biệt: 1 ăn được 8, nhưng 8 không ăn được 1.',
  'rule5': '5. Nếu hai số bằng nhau, cả hai quân đều biến mất.',
  'rule6':
      '6. Ăn hết quân đối phương để thắng. Nếu các quân cuối cùng cùng biến mất thì hòa.',
  'rule7':
      '7. Nếu không còn quân úp và một bên không có nước hợp lệ, bên kia thắng. Nếu cả hai không đi được, hòa.',
  'rule8':
      '8. {limit} lượt liên tiếp không ăn quân sẽ hòa. Bộ đếm đặt lại sau khi ăn quân.',
  'rule9': '9. Ô có quân bị ăn sẽ trống và có thể đi vào sau đó.',
};

const Map<String, String> _bengaliStrings = <String, String>{
  'settingsTooltip': 'সেটিংস',
  'settingsTitle': 'সেটিংস',
  'soundEffects': 'শব্দ প্রভাব',
  'languageLabel': 'ইন্টারফেস ভাষা',
  'done': 'শেষ',
  'resetButton': 'আবার শুরু',
  'resetTitle': 'আবার শুরু করবেন?',
  'resetContent': 'বর্তমান খেলা মুছে যাবে।',
  'continueGame': 'খেলা চালিয়ে যান',
  'undoButton': 'ফিরিয়ে নিন',
  'undoUnavailable': 'ইতিমধ্যে শুরুতে আছে',
  'undoTitle': 'ফিরিয়ে নেওয়া নিশ্চিত?',
  'undoContent': 'বিজ্ঞাপন দেখার পরে খেলা এক চাল পিছনে যাবে।',
  'cancel': 'বাতিল',
  'watchAdAndUndo': 'বিজ্ঞাপন দেখুন ও ফিরিয়ে নিন',
  'undoingLabel': 'ফিরিয়ে নেওয়া হচ্ছে',
  'rulesTitle': 'নিয়ম',
  'drawHeading': 'ড্র',
  'gameOverPrompt': 'পরের খেলার জন্য আবার শুরু চাপুন',
  'side.red': 'লাল',
  'side.blue': 'নীল',
  'animal.1': 'ইঁদুর',
  'animal.2': 'বিড়াল',
  'animal.3': 'কুকুর',
  'animal.4': 'নেকড়ে',
  'animal.5': 'চিতাবাঘ',
  'animal.6': 'বাঘ',
  'animal.7': 'সিংহ',
  'animal.8': 'হাতি',
  'pieceLabel': 'নং {rank} {animal}',
  'openingTurn':
      '{side} শুরু করে: প্রতি চালে একটি লুকানো গুটি খুলুন বা নিজের গুটি চালুন।',
  'adThenUndo': 'বিজ্ঞাপনের পরে চাল ফিরিয়ে নেওয়া হবে।',
  'undoingStatus': 'ফিরিয়ে নেওয়া হচ্ছে...',
  'undoRestoredOpening': 'ফিরিয়ে নেওয়া হয়েছে, শুরুতে ফিরে। {next}',
  'undoRestoredPrevious': 'ফিরিয়ে নেওয়া হয়েছে, আগের চালে ফিরে। {next}',
  'undoTurn':
      '{side}-এর পালা: গুটি খুলুন বা এক ধাপ চালুন। না খাওয়া {count}/{limit}।',
  'selectionCanceled':
      'নির্বাচন বাতিল। আপনি গুটি খুলতে বা আবার বেছে নিতে পারেন।',
  'selectedPiece': '{side} {piece} বেছে নিয়েছে।',
  'choosePieceFirst':
      'আগে একটি লুকানো গুটি খুলুন, অথবা চালার আগে নিজের গুটি বেছে নিন।',
  'selectedPieceMissing': 'নির্বাচিত গুটি নেই। আবার বেছে নিন।',
  'flippedPiece': '{actor} {side}-এর {piece} খুলেছে।',
  'oneStepOnly': 'শুধু এক ঘর ওপর, নিচ, বাম বা ডানে যাওয়া যায়।',
  'movedToEmpty': '{actor} {piece} খালি ঘরে চালেছে।',
  'cannotMoveToHidden': 'লুকানো গুটির ওপর যাওয়া যায় না। সেটি খুলুন।',
  'cannotCaptureOwn': 'নিজের গুটি খাওয়া যায় না।',
  'cannotCapture': '{attacker} {defender} খেতে পারে না।',
  'mutualElimination':
      '{actor}-এর {attacker} এবং {defenderSide}-এর {defender} দুটিই সরে গেছে।',
  'capturedPiece':
      '{actor}-এর {attacker} {defenderSide}-এর {defender} খেয়েছে।',
  'winnerNoLegalAction': '{side} জিতেছে। প্রতিপক্ষের কোনো বৈধ চাল নেই।',
  'winnerElimination': '{side} প্রতিপক্ষের সব গুটি খেয়ে জিতেছে।',
  'drawNonCaptureLimit': '{limit} চাল কোনো গুটি খাওয়া হয়নি। ড্র।',
  'drawNoLegalActions': 'কোনো পক্ষের বৈধ চাল নেই। ড্র।',
  'drawMutualElimination': 'শেষ গুটিগুলো একসঙ্গে সরে গেছে। ড্র।',
  'turnMessage':
      '{side}-এর পালা: গুটি খুলুন বা এক ধাপ চালুন। না খাওয়া {count}/{limit}।',
  'remainingAfterCapture':
      '{action} {side}-এর লুকানোসহ {remaining}টি গুটি বাকি।\n{turn}',
  'currentTurn': 'বর্তমান পালা: {side}',
  'victoryHeading': '{side}-এর জয়',
  'sideRemaining': '{side} বাকি',
  'piecesCount': '{count} গুটি',
  'gameOverWinner': '{side} জিতেছে',
  'rule1':
      '1. বোর্ড 4 x 4, মোট 16টি গুটি। লাল ও নীলের 1 থেকে 8 নম্বর গুটি আছে।',
  'rule2':
      '2. প্রতি চালে একটি কাজ বেছে নিন: লুকানো গুটি খুলুন বা নিজের খোলা গুটি এক ধাপ চালুন।',
  'rule3': '3. গুটি শুধু ওপর, নিচ, বাম বা ডানে চলে। তির্যক বা একাধিক ঘর নয়।',
  'rule4':
      '4. খেতে হলে প্রতিপক্ষের খোলা গুটির নম্বর সমান বা কম হতে হবে। বিশেষ নিয়ম: 1, 8 খেতে পারে, কিন্তু 8, 1 খেতে পারে না।',
  'rule5': '5. নম্বর সমান হলে দুই গুটিই সরে যায়।',
  'rule6':
      '6. প্রতিপক্ষের সব গুটি খেলে জয়। শেষ গুটিগুলো একসঙ্গে সরে গেলে ড্র।',
  'rule7':
      '7. লুকানো গুটি না থাকলে এবং এক পক্ষ চালতে না পারলে অন্য পক্ষ জেতে। দুপক্ষই না পারলে ড্র।',
  'rule8':
      '8. টানা {limit} চাল কোনো গুটি না খেলে ড্র। খাওয়ার পর গণনা রিসেট হয়।',
  'rule9': '9. খাওয়া ঘর খালি হয়ে যায় এবং পরে সেখানে যাওয়া যায়।',
};

const Map<String, String> _hungarianStrings = <String, String>{
  'settingsTooltip': 'Beállítások',
  'settingsTitle': 'Beállítások',
  'soundEffects': 'Hangeffektek',
  'languageLabel': 'Felület nyelve',
  'done': 'Kész',
  'resetButton': 'Újrakezdés',
  'resetTitle': 'Újrakezded?',
  'resetContent': 'Az aktuális játék törlődik.',
  'continueGame': 'Játék folytatása',
  'undoButton': 'Visszavonás',
  'undoUnavailable': 'Már a kezdésnél vagy',
  'undoTitle': 'Visszavonás megerősítése?',
  'undoContent': 'Reklám után a játék egy lépéssel visszalép.',
  'cancel': 'Mégse',
  'watchAdAndUndo': 'Reklám és visszavonás',
  'undoingLabel': 'Visszavonás',
  'rulesTitle': 'Szabályok',
  'drawHeading': 'Döntetlen',
  'gameOverPrompt': 'Koppints az újrakezdésre a következő játékhoz',
  'side.red': 'Piros',
  'side.blue': 'Kék',
  'animal.1': 'Patkány',
  'animal.2': 'Macska',
  'animal.3': 'Kutya',
  'animal.4': 'Farkas',
  'animal.5': 'Leopárd',
  'animal.6': 'Tigris',
  'animal.7': 'Oroszlán',
  'animal.8': 'Elefánt',
  'pieceLabel': '{rank}. {animal}',
  'openingTurn':
      '{side} kezd: körönként fordíts fel egy rejtett bábut, vagy lépj egy saját bábuval.',
  'adThenUndo': 'A lépés a reklám után visszavonódik.',
  'undoingStatus': 'Visszavonás...',
  'undoRestoredOpening': 'Visszavonva, vissza a kezdéshez. {next}',
  'undoRestoredPrevious': 'Visszavonva, vissza az előző lépéshez. {next}',
  'undoTurn':
      '{side} következik: fordíts vagy lépj egyet. Ütés nélkül {count}/{limit}.',
  'selectionCanceled':
      'Kijelölés törölve. Fordíthatsz, vagy választhatsz új bábut.',
  'selectedPiece': '{side} kiválasztotta: {piece}.',
  'choosePieceFirst':
      'Előbb fordíts fel egy rejtett bábut, vagy válassz saját bábut a lépéshez.',
  'selectedPieceMissing': 'A kiválasztott bábu már nincs ott. Válassz újra.',
  'flippedPiece': '{actor} felfordította {side} {piece} bábuját.',
  'oneStepOnly': 'Csak egy mezőt léphetsz fel, le, balra vagy jobbra.',
  'movedToEmpty': '{actor} {piece} bábut üres mezőre mozgatta.',
  'cannotMoveToHidden': 'Nem léphetsz rejtett bábura. Fordítsd fel.',
  'cannotCaptureOwn': 'Saját bábut nem üthetsz.',
  'cannotCapture': '{attacker} nem ütheti ezt: {defender}.',
  'mutualElimination':
      '{actor} {attacker} bábuja és {defenderSide} {defender} bábuja kiütötte egymást.',
  'capturedPiece':
      '{actor} {attacker} bábuja leütötte {defenderSide} {defender} bábuját.',
  'winnerNoLegalAction': '{side} nyer. Az ellenfélnek nincs szabályos akciója.',
  'winnerElimination': '{side} nyer, miután minden ellenfél bábut leütött.',
  'drawNonCaptureLimit': '{limit} kör ütés nélkül. Döntetlen.',
  'drawNoLegalActions': 'Egyik oldalnak sincs szabályos akciója. Döntetlen.',
  'drawMutualElimination': 'Az utolsó bábuk kiütötték egymást. Döntetlen.',
  'turnMessage':
      '{side} következik: fordíts vagy lépj egyet. Ütés nélkül {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} oldalán {remaining} bábu maradt, rejtettekkel együtt.\n{turn}',
  'currentTurn': 'Aktuális kör: {side}',
  'victoryHeading': '{side} győzelem',
  'sideRemaining': '{side} maradék',
  'piecesCount': '{count} bábu',
  'gameOverWinner': '{side} nyer',
  'rule1':
      '1. A tábla 4 x 4-es, 16 bábuval. Piros és Kék 1-től 8-ig rangokat kap.',
  'rule2':
      '2. Minden körben válassz egy akciót: rejtett bábu felfordítása vagy saját nyílt bábu egy lépése.',
  'rule3':
      '3. A bábuk csak fel, le, balra vagy jobbra lépnek. Nincs átlós vagy többmezős lépés.',
  'rule4':
      '4. Ütni csak nyílt ellenfél bábut lehet azonos vagy kisebb számmal. Külön szabály: az 1 üti a 8-at, de a 8 nem üti az 1-et.',
  'rule5': '5. Azonos számnál mindkét bábu eltűnik.',
  'rule6':
      '6. Az összes ellenfél bábu leütése győzelem. Ha az utolsók együtt tűnnek el, döntetlen.',
  'rule7':
      '7. Ha nincs rejtett bábu és az egyik oldal nem tud lépni, a másik nyer. Ha egyik sem tud, döntetlen.',
  'rule8':
      '8. {limit} egymást követő kör ütés nélkül döntetlen. Ütés után a számláló nullázódik.',
  'rule9': '9. A leütött mezők üresek lesznek, később be lehet lépni rájuk.',
};

const Map<String, String> _danishStrings = <String, String>{
  'settingsTooltip': 'Indstillinger',
  'settingsTitle': 'Indstillinger',
  'soundEffects': 'Lydeffekter',
  'languageLabel': 'Grænsefladesprog',
  'done': 'Færdig',
  'resetButton': 'Genstart',
  'resetTitle': 'Genstart?',
  'resetContent': 'Det aktuelle spil bliver ryddet.',
  'continueGame': 'Spil videre',
  'undoButton': 'Fortryd',
  'undoUnavailable': 'Allerede ved start',
  'undoTitle': 'Bekræft fortryd?',
  'undoContent': 'Efter en annonce går spillet ét træk tilbage.',
  'cancel': 'Annuller',
  'watchAdAndUndo': 'Se annonce og fortryd',
  'undoingLabel': 'Fortryder',
  'rulesTitle': 'Regler',
  'drawHeading': 'Uafgjort',
  'gameOverPrompt': 'Tryk genstart for næste spil',
  'side.red': 'Rød',
  'side.blue': 'Blå',
  'animal.1': 'Rotte',
  'animal.2': 'Kat',
  'animal.3': 'Hund',
  'animal.4': 'Ulv',
  'animal.5': 'Leopard',
  'animal.6': 'Tiger',
  'animal.7': 'Løve',
  'animal.8': 'Elefant',
  'pieceLabel': 'Nr. {rank} {animal}',
  'openingTurn':
      '{side} starter: vend en skjult brik eller flyt en egen brik hver tur.',
  'adThenUndo': 'Trækket fortrydes efter annoncen.',
  'undoingStatus': 'Fortryder...',
  'undoRestoredOpening': 'Fortrudt, tilbage til start. {next}',
  'undoRestoredPrevious': 'Fortrudt, tilbage til forrige træk. {next}',
  'undoTurn':
      '{side}s tur: vend eller flyt ét skridt. Uden slag {count}/{limit}.',
  'selectionCanceled':
      'Valg annulleret. Du kan vende en brik eller vælge igen.',
  'selectedPiece': '{side} valgte {piece}.',
  'choosePieceFirst':
      'Vend først en skjult brik, eller vælg en egen brik før du flytter.',
  'selectedPieceMissing': 'Den valgte brik er væk. Vælg igen.',
  'flippedPiece': '{actor} vendte {side}s {piece}.',
  'oneStepOnly': 'Du kan kun flytte ét felt op, ned, venstre eller højre.',
  'movedToEmpty': '{actor} flyttede {piece} til et tomt felt.',
  'cannotMoveToHidden': 'Du kan ikke flytte til en skjult brik. Vend den.',
  'cannotCaptureOwn': 'Du kan ikke slå din egen brik.',
  'cannotCapture': '{attacker} kan ikke slå {defender}.',
  'mutualElimination':
      '{actor}s {attacker} og {defenderSide}s {defender} slog hinanden ud.',
  'capturedPiece': '{actor}s {attacker} slog {defenderSide}s {defender}.',
  'winnerNoLegalAction':
      '{side} vinder. Modstanderen har ingen lovlig handling.',
  'winnerElimination':
      '{side} vinder efter at have slået alle modstanderens brikker.',
  'drawNonCaptureLimit': '{limit} ture uden slag. Uafgjort.',
  'drawNoLegalActions': 'Ingen side har en lovlig handling. Uafgjort.',
  'drawMutualElimination': 'De sidste brikker slog hinanden ud. Uafgjort.',
  'turnMessage':
      '{side}s tur: vend eller flyt ét skridt. Uden slag {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} har {remaining} brik(ker) tilbage, inklusive skjulte.\n{turn}',
  'currentTurn': 'Aktuel tur: {side}',
  'victoryHeading': 'Sejr til {side}',
  'sideRemaining': '{side} tilbage',
  'piecesCount': '{count} brik(ker)',
  'gameOverWinner': '{side} vinder',
  'rule1':
      '1. Brættet er 4 x 4 med 16 brikker. Rød og Blå har hver rang 1 til 8.',
  'rule2':
      '2. Vælg én handling hver tur: vend en skjult brik eller flyt en åben egen brik ét skridt.',
  'rule3':
      '3. Brikker flytter kun op, ned, venstre eller højre. Ingen diagonaler eller flere felter.',
  'rule4':
      '4. Slag skal være mod en åben modstanderbrik med samme eller lavere tal. Særregel: 1 slår 8, men 8 slår ikke 1.',
  'rule5': '5. Hvis tallene er ens, forsvinder begge brikker.',
  'rule6':
      '6. Slå alle modstanderens brikker for at vinde. Hvis de sidste forsvinder sammen, er det uafgjort.',
  'rule7':
      '7. Hvis der ikke er skjulte brikker og én side ikke kan handle, vinder den anden. Hvis ingen kan handle, er det uafgjort.',
  'rule8':
      '8. {limit} ture i træk uden slag giver uafgjort. Tælleren nulstilles efter et slag.',
  'rule9': '9. Slagne felter bliver tomme og kan bruges senere.',
};

const Map<String, String> _finnishStrings = <String, String>{
  'settingsTooltip': 'Asetukset',
  'settingsTitle': 'Asetukset',
  'soundEffects': 'Äänitehosteet',
  'languageLabel': 'Käyttöliittymän kieli',
  'done': 'Valmis',
  'resetButton': 'Aloita alusta',
  'resetTitle': 'Aloitetaanko alusta?',
  'resetContent': 'Nykyinen peli tyhjennetään.',
  'continueGame': 'Jatka peliä',
  'undoButton': 'Peru',
  'undoUnavailable': 'Olet jo alussa',
  'undoTitle': 'Vahvista peruminen?',
  'undoContent': 'Mainoksen jälkeen peli palaa yhden siirron.',
  'cancel': 'Peruuta',
  'watchAdAndUndo': 'Katso mainos ja peru',
  'undoingLabel': 'Perutaan',
  'rulesTitle': 'Säännöt',
  'drawHeading': 'Tasapeli',
  'gameOverPrompt': 'Napauta aloita alusta seuraavaa peliä varten',
  'side.red': 'Punainen',
  'side.blue': 'Sininen',
  'animal.1': 'Rotta',
  'animal.2': 'Kissa',
  'animal.3': 'Koira',
  'animal.4': 'Susi',
  'animal.5': 'Leopardi',
  'animal.6': 'Tiikeri',
  'animal.7': 'Leijona',
  'animal.8': 'Norsu',
  'pieceLabel': 'Nro {rank} {animal}',
  'openingTurn':
      '{side} aloittaa: käännä vuorolla piilotettu nappula tai siirrä omaa.',
  'adThenUndo': 'Siirto perutaan mainoksen jälkeen.',
  'undoingStatus': 'Perutaan...',
  'undoRestoredOpening': 'Peruttu, takaisin alkuun. {next}',
  'undoRestoredPrevious': 'Peruttu, takaisin edelliseen siirtoon. {next}',
  'undoTurn':
      '{side} vuorossa: käännä tai siirrä askel. Ilman syöntiä {count}/{limit}.',
  'selectionCanceled':
      'Valinta peruttu. Voit kääntää nappulan tai valita uudelleen.',
  'selectedPiece': '{side} valitsi {piece}.',
  'choosePieceFirst':
      'Käännä ensin piilotettu nappula tai valitse oma nappula siirtoa varten.',
  'selectedPieceMissing': 'Valittu nappula on poissa. Valitse uudelleen.',
  'flippedPiece': '{actor} käänsi {side}n {piece}.',
  'oneStepOnly':
      'Voit siirtyä vain yhden ruudun ylös, alas, vasemmalle tai oikealle.',
  'movedToEmpty': '{actor} siirsi {piece} tyhjään ruutuun.',
  'cannotMoveToHidden': 'Et voi siirtyä piilotetun nappulan päälle. Käännä se.',
  'cannotCaptureOwn': 'Et voi syödä omaa nappulaasi.',
  'cannotCapture': '{attacker} ei voi syödä {defender}.',
  'mutualElimination':
      '{actor}n {attacker} ja {defenderSide}n {defender} poistivat toisensa.',
  'capturedPiece': '{actor}n {attacker} söi {defenderSide}n {defender}.',
  'winnerNoLegalAction':
      '{side} voittaa. Vastustajalla ei ole laillista toimintoa.',
  'winnerElimination': '{side} voittaa syömällä kaikki vastustajan nappulat.',
  'drawNonCaptureLimit': '{limit} vuoroa ilman syöntiä. Tasapeli.',
  'drawNoLegalActions': 'Kummallakaan ei ole laillista toimintoa. Tasapeli.',
  'drawMutualElimination': 'Viimeiset nappulat poistivat toisensa. Tasapeli.',
  'turnMessage':
      '{side} vuorossa: käännä tai siirrä askel. Ilman syöntiä {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side}lla on {remaining} nappulaa jäljellä, myös piilotetut.\n{turn}',
  'currentTurn': 'Nykyinen vuoro: {side}',
  'victoryHeading': '{side} voittaa',
  'sideRemaining': '{side} jäljellä',
  'piecesCount': '{count} nappulaa',
  'gameOverWinner': '{side} voittaa',
  'rule1':
      '1. Lauta on 4 x 4 ja siinä on 16 nappulaa. Punaisella ja Sinisellä on arvot 1-8.',
  'rule2':
      '2. Valitse vuorolla yksi toiminto: käännä piilotettu nappula tai siirrä omaa avointa nappulaa askel.',
  'rule3':
      '3. Nappulat liikkuvat vain ylös, alas, vasemmalle tai oikealle. Ei vinoon eikä useita ruutuja.',
  'rule4':
      '4. Syönnin kohteena on avoin vastustajan nappula, jonka numero on sama tai pienempi. Erikoissääntö: 1 syö 8:n, mutta 8 ei syö 1:tä.',
  'rule5': '5. Jos numerot ovat samat, molemmat nappulat katoavat.',
  'rule6':
      '6. Syö kaikki vastustajan nappulat voittaaksesi. Jos viimeiset katoavat yhdessä, peli on tasapeli.',
  'rule7':
      '7. Jos piilotettuja nappuloita ei ole ja toinen puoli ei voi toimia, toinen voittaa. Jos kumpikaan ei voi, tasapeli.',
  'rule8':
      '8. {limit} peräkkäistä vuoroa ilman syöntiä on tasapeli. Laskuri nollautuu syönnin jälkeen.',
  'rule9': '9. Syödyt ruudut tyhjenevät ja niihin voi siirtyä myöhemmin.',
};

const Map<String, String> _norwegianStrings = <String, String>{
  'settingsTooltip': 'Innstillinger',
  'settingsTitle': 'Innstillinger',
  'soundEffects': 'Lydeffekter',
  'languageLabel': 'Grensesnittspråk',
  'done': 'Ferdig',
  'resetButton': 'Start på nytt',
  'resetTitle': 'Starte på nytt?',
  'resetContent': 'Det nåværende spillet blir slettet.',
  'continueGame': 'Fortsett å spille',
  'undoButton': 'Angre',
  'undoUnavailable': 'Allerede ved start',
  'undoTitle': 'Bekreft angre?',
  'undoContent': 'Etter en annonse går spillet ett trekk tilbake.',
  'cancel': 'Avbryt',
  'watchAdAndUndo': 'Se annonse og angre',
  'undoingLabel': 'Angrer',
  'rulesTitle': 'Regler',
  'drawHeading': 'Uavgjort',
  'gameOverPrompt': 'Trykk start på nytt for neste spill',
  'side.red': 'Rød',
  'side.blue': 'Blå',
  'animal.1': 'Rotte',
  'animal.2': 'Katt',
  'animal.3': 'Hund',
  'animal.4': 'Ulv',
  'animal.5': 'Leopard',
  'animal.6': 'Tiger',
  'animal.7': 'Løve',
  'animal.8': 'Elefant',
  'pieceLabel': 'Nr. {rank} {animal}',
  'openingTurn':
      '{side} starter: snu en skjult brikke eller flytt en egen brikke hver tur.',
  'adThenUndo': 'Trekket angres etter annonsen.',
  'undoingStatus': 'Angrer...',
  'undoRestoredOpening': 'Angret, tilbake til start. {next}',
  'undoRestoredPrevious': 'Angret, tilbake til forrige trekk. {next}',
  'undoTurn':
      '{side}s tur: snu eller flytt ett steg. Uten slag {count}/{limit}.',
  'selectionCanceled':
      'Valget ble avbrutt. Du kan snu en brikke eller velge på nytt.',
  'selectedPiece': '{side} valgte {piece}.',
  'choosePieceFirst':
      'Snu først en skjult brikke, eller velg en egen brikke før du flytter.',
  'selectedPieceMissing': 'Den valgte brikken er borte. Velg på nytt.',
  'flippedPiece': '{actor} snudde {side}s {piece}.',
  'oneStepOnly': 'Du kan bare flytte én rute opp, ned, venstre eller høyre.',
  'movedToEmpty': '{actor} flyttet {piece} til en tom rute.',
  'cannotMoveToHidden': 'Du kan ikke flytte til en skjult brikke. Snu den.',
  'cannotCaptureOwn': 'Du kan ikke slå din egen brikke.',
  'cannotCapture': '{attacker} kan ikke slå {defender}.',
  'mutualElimination':
      '{actor}s {attacker} og {defenderSide}s {defender} slo hverandre ut.',
  'capturedPiece': '{actor}s {attacker} slo {defenderSide}s {defender}.',
  'winnerNoLegalAction':
      '{side} vinner. Motstanderen har ingen lovlig handling.',
  'winnerElimination':
      '{side} vinner etter å ha slått alle motstanderens brikker.',
  'drawNonCaptureLimit': '{limit} turer uten slag. Uavgjort.',
  'drawNoLegalActions': 'Ingen side har en lovlig handling. Uavgjort.',
  'drawMutualElimination': 'De siste brikkene slo hverandre ut. Uavgjort.',
  'turnMessage':
      '{side}s tur: snu eller flytt ett steg. Uten slag {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} har {remaining} brikke(r) igjen, inkludert skjulte.\n{turn}',
  'currentTurn': 'Nåværende tur: {side}',
  'victoryHeading': 'Seier til {side}',
  'sideRemaining': '{side} igjen',
  'piecesCount': '{count} brikke(r)',
  'gameOverWinner': '{side} vinner',
  'rule1': '1. Brettet er 4 x 4 med 16 brikker. Rød og Blå har rang 1 til 8.',
  'rule2':
      '2. Velg én handling hver tur: snu en skjult brikke eller flytt en åpen egen brikke ett steg.',
  'rule3':
      '3. Brikker flytter bare opp, ned, venstre eller høyre. Ingen diagonaler eller flere ruter.',
  'rule4':
      '4. Slag må være mot en åpen motstanderbrikke med likt eller lavere tall. Spesialregel: 1 slår 8, men 8 slår ikke 1.',
  'rule5': '5. Hvis tallene er like, forsvinner begge brikkene.',
  'rule6':
      '6. Slå alle motstanderens brikker for å vinne. Hvis de siste forsvinner sammen, er det uavgjort.',
  'rule7':
      '7. Hvis ingen skjulte brikker finnes og én side ikke kan handle, vinner den andre. Hvis ingen kan handle, er det uavgjort.',
  'rule8':
      '8. {limit} turer på rad uten slag gir uavgjort. Telleren nullstilles etter et slag.',
  'rule9': '9. Slåtte ruter blir tomme og kan brukes senere.',
};

const Map<String, String> _slovakStrings = <String, String>{
  'settingsTooltip': 'Nastavenia',
  'settingsTitle': 'Nastavenia',
  'soundEffects': 'Zvukové efekty',
  'languageLabel': 'Jazyk rozhrania',
  'done': 'Hotovo',
  'resetButton': 'Reštartovať',
  'resetTitle': 'Reštartovať?',
  'resetContent': 'Aktuálna hra sa vymaže.',
  'continueGame': 'Pokračovať',
  'undoButton': 'Späť',
  'undoUnavailable': 'Už je začiatok',
  'undoTitle': 'Potvrdiť krok späť?',
  'undoContent': 'Po reklame sa hra vráti o jeden ťah.',
  'cancel': 'Zrušiť',
  'watchAdAndUndo': 'Pozrieť reklamu a späť',
  'undoingLabel': 'Vracanie',
  'rulesTitle': 'Pravidlá',
  'drawHeading': 'Remíza',
  'gameOverPrompt': 'Ťukni na reštart pre ďalšiu hru',
  'side.red': 'Červená',
  'side.blue': 'Modrá',
  'animal.1': 'Potkan',
  'animal.2': 'Mačka',
  'animal.3': 'Pes',
  'animal.4': 'Vlk',
  'animal.5': 'Leopard',
  'animal.6': 'Tiger',
  'animal.7': 'Lev',
  'animal.8': 'Slon',
  'pieceLabel': 'Č. {rank} {animal}',
  'openingTurn':
      '{side} začína: každý ťah otoč skrytú figúrku alebo pohni vlastnou.',
  'adThenUndo': 'Ťah sa vráti po reklame.',
  'undoingStatus': 'Vracanie...',
  'undoRestoredOpening': 'Vrátené, späť na začiatok. {next}',
  'undoRestoredPrevious': 'Vrátené, späť na predchádzajúci ťah. {next}',
  'undoTurn':
      'Na ťahu je {side}: otoč alebo pohni o krok. Bez brania {count}/{limit}.',
  'selectionCanceled':
      'Výber zrušený. Môžeš otočiť figúrku alebo vybrať znova.',
  'selectedPiece': '{side} vybrala {piece}.',
  'choosePieceFirst':
      'Najprv otoč skrytú figúrku alebo vyber vlastnú figúrku na ťah.',
  'selectedPieceMissing': 'Vybraná figúrka už neexistuje. Vyber znova.',
  'flippedPiece': '{actor} otočila {piece} strany {side}.',
  'oneStepOnly': 'Môžeš ťahať len o jedno pole hore, dole, vľavo alebo vpravo.',
  'movedToEmpty': '{actor} presunula {piece} na prázdne pole.',
  'cannotMoveToHidden': 'Nemôžeš ťahať na skrytú figúrku. Otoč ju.',
  'cannotCaptureOwn': 'Nemôžeš brať vlastnú figúrku.',
  'cannotCapture': '{attacker} nemôže vziať {defender}.',
  'mutualElimination':
      '{attacker} strany {actor} a {defender} strany {defenderSide} sa vyradili navzájom.',
  'capturedPiece':
      '{attacker} strany {actor} vzala {defender} strany {defenderSide}.',
  'winnerNoLegalAction': '{side} víťazí. Súper nemá legálnu akciu.',
  'winnerElimination': '{side} víťazí po zobratí všetkých súperových figúrok.',
  'drawNonCaptureLimit': '{limit} ťahov bez brania. Remíza.',
  'drawNoLegalActions': 'Žiadna strana nemá legálnu akciu. Remíza.',
  'drawMutualElimination': 'Posledné figúrky sa vyradili navzájom. Remíza.',
  'turnMessage':
      'Na ťahu je {side}: otoč alebo pohni o krok. Bez brania {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} má ešte {remaining} figúrok vrátane skrytých.\n{turn}',
  'currentTurn': 'Aktuálny ťah: {side}',
  'victoryHeading': 'Víťazstvo: {side}',
  'sideRemaining': 'Zostáva pre {side}',
  'piecesCount': '{count} figúrok',
  'gameOverWinner': '{side} víťazí',
  'rule1':
      '1. Doska je 4 x 4 a má 16 figúrok. Červená a Modrá majú hodnosti 1 až 8.',
  'rule2':
      '2. Každý ťah vyber jednu akciu: otoč skrytú figúrku alebo posuň vlastnú odkrytú figúrku o krok.',
  'rule3':
      '3. Figúrky sa pohybujú len hore, dole, vľavo alebo vpravo. Nie diagonálne ani o viac polí.',
  'rule4':
      '4. Brať možno odkrytú súperovu figúrku s rovnakým alebo nižším číslom. Špeciálne pravidlo: 1 berie 8, ale 8 neberie 1.',
  'rule5': '5. Ak sú čísla rovnaké, obe figúrky zmiznú.',
  'rule6':
      '6. Zober všetky súperove figúrky a vyhraj. Ak posledné zmiznú spolu, je remíza.',
  'rule7':
      '7. Ak nie sú skryté figúrky a jedna strana nemôže konať, vyhráva druhá. Ak nemôže nikto, je remíza.',
  'rule8':
      '8. {limit} po sebe idúcich ťahov bez brania znamená remízu. Po braní sa počítadlo vynuluje.',
  'rule9': '9. Polia po zobratí sú prázdne a možno na ne neskôr vstúpiť.',
};

const Map<String, String> _bulgarianStrings = <String, String>{
  'settingsTooltip': 'Настройки',
  'settingsTitle': 'Настройки',
  'soundEffects': 'Звукови ефекти',
  'languageLabel': 'Език на интерфейса',
  'done': 'Готово',
  'resetButton': 'Рестарт',
  'resetTitle': 'Рестарт?',
  'resetContent': 'Текущата игра ще бъде изчистена.',
  'continueGame': 'Продължи',
  'undoButton': 'Отмени ход',
  'undoUnavailable': 'Вече е началото',
  'undoTitle': 'Потвърди отмяна?',
  'undoContent': 'След реклама играта ще се върне с един ход.',
  'cancel': 'Отказ',
  'watchAdAndUndo': 'Гледай реклама и отмени',
  'undoingLabel': 'Отмяна',
  'rulesTitle': 'Правила',
  'drawHeading': 'Равенство',
  'gameOverPrompt': 'Докосни рестарт за следващата игра',
  'side.red': 'Червени',
  'side.blue': 'Сини',
  'animal.1': 'Плъх',
  'animal.2': 'Котка',
  'animal.3': 'Куче',
  'animal.4': 'Вълк',
  'animal.5': 'Леопард',
  'animal.6': 'Тигър',
  'animal.7': 'Лъв',
  'animal.8': 'Слон',
  'pieceLabel': '№ {rank} {animal}',
  'openingTurn':
      '{side} започват: на ход отвори скрита фигура или премести своя.',
  'adThenUndo': 'Ходът ще бъде отменен след рекламата.',
  'undoingStatus': 'Отмяна...',
  'undoRestoredOpening': 'Отменено, връщане в началото. {next}',
  'undoRestoredPrevious': 'Отменено, връщане към предишния ход. {next}',
  'undoTurn':
      'Ход на {side}: отвори фигура или премести с една стъпка. Без вземане {count}/{limit}.',
  'selectionCanceled':
      'Изборът е отменен. Можеш да отвориш фигура или да избереш пак.',
  'selectedPiece': '{side} избраха {piece}.',
  'choosePieceFirst':
      'Първо отвори скрита фигура или избери своя фигура за ход.',
  'selectedPieceMissing': 'Избраната фигура вече я няма. Избери отново.',
  'flippedPiece': '{actor} отвориха {piece} на {side}.',
  'oneStepOnly':
      'Можеш да се движиш само с едно поле нагоре, надолу, наляво или надясно.',
  'movedToEmpty': '{actor} преместиха {piece} на празно поле.',
  'cannotMoveToHidden': 'Не можеш да стъпиш върху скрита фигура. Отвори я.',
  'cannotCaptureOwn': 'Не можеш да вземеш своя фигура.',
  'cannotCapture': '{attacker} не може да вземе {defender}.',
  'mutualElimination':
      '{attacker} на {actor} и {defender} на {defenderSide} се премахнаха взаимно.',
  'capturedPiece': '{attacker} на {actor} взе {defender} на {defenderSide}.',
  'winnerNoLegalAction': '{side} печелят. Противникът няма законен ход.',
  'winnerElimination':
      '{side} печелят, след като взеха всички противникови фигури.',
  'drawNonCaptureLimit': '{limit} хода без вземане. Равенство.',
  'drawNoLegalActions': 'Никоя страна няма законен ход. Равенство.',
  'drawMutualElimination':
      'Последните фигури се премахнаха взаимно. Равенство.',
  'turnMessage':
      'Ход на {side}: отвори фигура или премести с една стъпка. Без вземане {count}/{limit}.',
  'remainingAfterCapture':
      '{action} {side} имат още {remaining} фигури, включително скрити.\n{turn}',
  'currentTurn': 'Текущ ход: {side}',
  'victoryHeading': 'Победа за {side}',
  'sideRemaining': 'Остават за {side}',
  'piecesCount': '{count} фигури',
  'gameOverWinner': '{side} печелят',
  'rule1':
      '1. Дъската е 4 x 4 с 16 фигури. Червени и Сини имат рангове от 1 до 8.',
  'rule2':
      '2. На всеки ход избери едно действие: отвори скрита фигура или премести своя открита фигура с една стъпка.',
  'rule3':
      '3. Фигурите се движат само нагоре, надолу, наляво или надясно. Без диагонали и без повече полета.',
  'rule4':
      '4. Вземането е срещу открита противникова фигура с равен или по-нисък номер. Специално правило: 1 взема 8, но 8 не взема 1.',
  'rule5': '5. Ако номерата са равни, двете фигури изчезват.',
  'rule6':
      '6. Вземи всички противникови фигури, за да спечелиш. Ако последните изчезнат заедно, играта е равна.',
  'rule7':
      '7. Ако няма скрити фигури и една страна не може да действа, другата печели. Ако и двете не могат, е равенство.',
  'rule8':
      '8. {limit} последователни хода без вземане са равенство. Броячът се нулира след вземане.',
  'rule9':
      '9. Полетата след вземане стават празни и могат да се заемат по-късно.',
};

const Map<String, String> _urduStrings = <String, String>{
  'settingsTooltip': 'ترتیبات',
  'settingsTitle': 'ترتیبات',
  'soundEffects': 'آواز کے اثرات',
  'languageLabel': 'انٹرفیس زبان',
  'done': 'مکمل',
  'resetButton': 'دوبارہ شروع',
  'resetTitle': 'دوبارہ شروع کریں؟',
  'resetContent': 'موجودہ کھیل صاف ہو جائے گا۔',
  'continueGame': 'کھیل جاری رکھیں',
  'undoButton': 'واپس کریں',
  'undoUnavailable': 'پہلے ہی آغاز پر ہے',
  'undoTitle': 'واپس کرنے کی تصدیق؟',
  'undoContent': 'اشتہار دیکھنے کے بعد کھیل ایک چال پیچھے جائے گا۔',
  'cancel': 'منسوخ',
  'watchAdAndUndo': 'اشتہار دیکھیں اور واپس کریں',
  'undoingLabel': 'واپس کیا جا رہا ہے',
  'rulesTitle': 'قواعد',
  'drawHeading': 'برابر',
  'gameOverPrompt': 'اگلا کھیل شروع کرنے کے لیے دوبارہ شروع دبائیں',
  'side.red': 'سرخ',
  'side.blue': 'نیلا',
  'animal.1': 'چوہا',
  'animal.2': 'بلی',
  'animal.3': 'کتا',
  'animal.4': 'بھیڑیا',
  'animal.5': 'چیتا',
  'animal.6': 'ببر',
  'animal.7': 'شیر',
  'animal.8': 'ہاتھی',
  'pieceLabel': 'نمبر {rank} {animal}',
  'openingTurn':
      '{side} شروع کرتا ہے: ہر باری میں چھپا مہرہ کھولیں یا اپنا مہرہ چلائیں۔',
  'adThenUndo': 'اشتہار کے بعد چال واپس ہو جائے گی۔',
  'undoingStatus': 'واپس کیا جا رہا ہے...',
  'undoRestoredOpening': 'واپس کر دیا، آغاز پر واپس۔ {next}',
  'undoRestoredPrevious': 'واپس کر دیا، پچھلی چال پر واپس۔ {next}',
  'undoTurn':
      '{side} کی باری: مہرہ کھولیں یا ایک قدم چلیں۔ بغیر مارے {count}/{limit}۔',
  'selectionCanceled':
      'انتخاب منسوخ۔ آپ مہرہ کھول سکتے ہیں یا دوبارہ چن سکتے ہیں۔',
  'selectedPiece': '{side} نے {piece} چنا۔',
  'choosePieceFirst': 'پہلے چھپا مہرہ کھولیں، یا چلنے سے پہلے اپنا مہرہ چنیں۔',
  'selectedPieceMissing': 'چنا ہوا مہرہ موجود نہیں۔ دوبارہ چنیں۔',
  'flippedPiece': '{actor} نے {side} کا {piece} کھولا۔',
  'oneStepOnly': 'صرف ایک خانہ اوپر، نیچے، بائیں یا دائیں چل سکتے ہیں۔',
  'movedToEmpty': '{actor} نے {piece} کو خالی خانے میں چلایا۔',
  'cannotMoveToHidden': 'چھپے مہرے پر نہیں جا سکتے۔ اسے کھولیں۔',
  'cannotCaptureOwn': 'اپنا مہرہ نہیں مار سکتے۔',
  'cannotCapture': '{attacker} {defender} کو نہیں مار سکتا۔',
  'mutualElimination':
      '{actor} کا {attacker} اور {defenderSide} کا {defender} دونوں ختم ہو گئے۔',
  'capturedPiece':
      '{actor} کے {attacker} نے {defenderSide} کے {defender} کو مارا۔',
  'winnerNoLegalAction': '{side} جیت گیا۔ حریف کے پاس کوئی قانونی چال نہیں۔',
  'winnerElimination': '{side} نے تمام حریف مہروں کو مار کر جیتا۔',
  'drawNonCaptureLimit': '{limit} باریوں تک کوئی مار نہیں۔ برابر۔',
  'drawNoLegalActions': 'کسی طرف کے پاس قانونی چال نہیں۔ برابر۔',
  'drawMutualElimination': 'آخری مہرے ایک ساتھ ختم ہو گئے۔ برابر۔',
  'turnMessage':
      '{side} کی باری: مہرہ کھولیں یا ایک قدم چلیں۔ بغیر مارے {count}/{limit}۔',
  'remainingAfterCapture':
      '{action} {side} کے پاس چھپے مہروں سمیت {remaining} مہرے باقی ہیں۔\n{turn}',
  'currentTurn': 'موجودہ باری: {side}',
  'victoryHeading': '{side} کی جیت',
  'sideRemaining': '{side} باقی',
  'piecesCount': '{count} مہرے',
  'gameOverWinner': '{side} جیتا',
  'rule1':
      '1. تختہ 4 x 4 ہے، کل 16 مہرے ہیں۔ سرخ اور نیلے کے پاس 1 سے 8 تک رتبے ہیں۔',
  'rule2':
      '2. ہر باری میں ایک عمل چنیں: چھپا مہرہ کھولیں یا اپنا کھلا مہرہ ایک قدم چلائیں۔',
  'rule3':
      '3. مہرے صرف اوپر، نیچے، بائیں یا دائیں چلتے ہیں۔ ترچھا یا کئی خانے نہیں۔',
  'rule4':
      '4. مارنے کے لیے حریف کا کھلا مہرہ برابر یا کم نمبر کا ہونا چاہیے۔ خاص اصول: 1، 8 کو مارتا ہے، مگر 8، 1 کو نہیں۔',
  'rule5': '5. نمبر برابر ہوں تو دونوں مہرے ختم ہو جاتے ہیں۔',
  'rule6':
      '6. حریف کے سب مہرے مار کر جیتیں۔ اگر آخری مہرے ساتھ ختم ہوں تو برابر۔',
  'rule7':
      '7. اگر چھپے مہرے نہ ہوں اور ایک طرف چل نہ سکے تو دوسری جیتتی ہے۔ دونوں نہ چل سکیں تو برابر۔',
  'rule8':
      '8. مسلسل {limit} باریوں تک کوئی مار نہ ہو تو برابر۔ مار کے بعد گنتی ری سیٹ ہوتی ہے۔',
  'rule9': '9. مارا گیا خانہ خالی ہو جاتا ہے اور بعد میں وہاں جایا جا سکتا ہے۔',
};

const Map<String, String> _punjabiStrings = <String, String>{
  'settingsTooltip': 'ਸੈਟਿੰਗਾਂ',
  'settingsTitle': 'ਸੈਟਿੰਗਾਂ',
  'soundEffects': 'ਧੁਨੀ ਪ੍ਰਭਾਵ',
  'languageLabel': 'ਇੰਟਰਫੇਸ ਭਾਸ਼ਾ',
  'done': 'ਮੁਕੰਮਲ',
  'resetButton': 'ਫਿਰ ਸ਼ੁਰੂ',
  'resetTitle': 'ਫਿਰ ਸ਼ੁਰੂ ਕਰਨਾ?',
  'resetContent': 'ਮੌਜੂਦਾ ਖੇਡ ਸਾਫ ਹੋ ਜਾਵੇਗੀ।',
  'continueGame': 'ਖੇਡ ਜਾਰੀ ਰੱਖੋ',
  'undoButton': 'ਵਾਪਸ',
  'undoUnavailable': 'ਪਹਿਲਾਂ ਹੀ ਸ਼ੁਰੂਆਤ ਤੇ ਹੈ',
  'undoTitle': 'ਵਾਪਸ ਕਰਨ ਦੀ ਪੁਸ਼ਟੀ?',
  'undoContent': 'ਇਸ਼ਤਿਹਾਰ ਦੇਖਣ ਤੋਂ ਬਾਅਦ ਖੇਡ ਇੱਕ ਚਾਲ ਪਿੱਛੇ ਜਾਵੇਗੀ।',
  'cancel': 'ਰੱਦ',
  'watchAdAndUndo': 'ਇਸ਼ਤਿਹਾਰ ਦੇਖੋ ਅਤੇ ਵਾਪਸ ਕਰੋ',
  'undoingLabel': 'ਵਾਪਸ ਕੀਤਾ ਜਾ ਰਿਹਾ',
  'rulesTitle': 'ਨਿਯਮ',
  'drawHeading': 'ਡਰਾਅ',
  'gameOverPrompt': 'ਅਗਲੀ ਖੇਡ ਲਈ ਫਿਰ ਸ਼ੁਰੂ ਦਬਾਓ',
  'side.red': 'ਲਾਲ',
  'side.blue': 'ਨੀਲਾ',
  'animal.1': 'ਚੂਹਾ',
  'animal.2': 'ਬਿੱਲੀ',
  'animal.3': 'ਕੁੱਤਾ',
  'animal.4': 'ਭੇੜੀਆ',
  'animal.5': 'ਚੀਤਾ',
  'animal.6': 'ਬਾਘ',
  'animal.7': 'ਸ਼ੇਰ',
  'animal.8': 'ਹਾਥੀ',
  'pieceLabel': 'ਨੰ. {rank} {animal}',
  'openingTurn':
      '{side} ਸ਼ੁਰੂ ਕਰਦਾ ਹੈ: ਹਰ ਵਾਰੀ ਛੁਪਿਆ ਮੋਹਰਾ ਖੋਲ੍ਹੋ ਜਾਂ ਆਪਣਾ ਮੋਹਰਾ ਚਲਾਓ।',
  'adThenUndo': 'ਇਸ਼ਤਿਹਾਰ ਤੋਂ ਬਾਅਦ ਚਾਲ ਵਾਪਸ ਹੋਵੇਗੀ।',
  'undoingStatus': 'ਵਾਪਸ ਕੀਤਾ ਜਾ ਰਿਹਾ...',
  'undoRestoredOpening': 'ਵਾਪਸ ਹੋ ਗਿਆ, ਸ਼ੁਰੂਆਤ ਤੇ ਆ ਗਏ। {next}',
  'undoRestoredPrevious': 'ਵਾਪਸ ਹੋ ਗਿਆ, ਪਿਛਲੀ ਚਾਲ ਤੇ ਆ ਗਏ। {next}',
  'undoTurn':
      '{side} ਦੀ ਵਾਰੀ: ਮੋਹਰਾ ਖੋਲ੍ਹੋ ਜਾਂ ਇੱਕ ਕਦਮ ਚਲੋ। ਬਿਨਾਂ ਮਾਰ {count}/{limit}।',
  'selectionCanceled':
      'ਚੋਣ ਰੱਦ। ਤੁਸੀਂ ਮੋਹਰਾ ਖੋਲ੍ਹ ਸਕਦੇ ਹੋ ਜਾਂ ਮੁੜ ਚੁਣ ਸਕਦੇ ਹੋ।',
  'selectedPiece': '{side} ਨੇ {piece} ਚੁਣਿਆ।',
  'choosePieceFirst':
      'ਪਹਿਲਾਂ ਛੁਪਿਆ ਮੋਹਰਾ ਖੋਲ੍ਹੋ, ਜਾਂ ਚਲਣ ਤੋਂ ਪਹਿਲਾਂ ਆਪਣਾ ਮੋਹਰਾ ਚੁਣੋ।',
  'selectedPieceMissing': 'ਚੁਣਿਆ ਮੋਹਰਾ ਨਹੀਂ ਰਿਹਾ। ਮੁੜ ਚੁਣੋ।',
  'flippedPiece': '{actor} ਨੇ {side} ਦਾ {piece} ਖੋਲ੍ਹਿਆ।',
  'oneStepOnly': 'ਸਿਰਫ ਇੱਕ ਘਰ ਉੱਪਰ, ਹੇਠਾਂ, ਖੱਬੇ ਜਾਂ ਸੱਜੇ ਜਾ ਸਕਦੇ ਹੋ।',
  'movedToEmpty': '{actor} ਨੇ {piece} ਨੂੰ ਖਾਲੀ ਘਰ ਵਿੱਚ ਚਲਾਇਆ।',
  'cannotMoveToHidden': 'ਛੁਪੇ ਮੋਹਰੇ ਤੇ ਨਹੀਂ ਜਾ ਸਕਦੇ। ਉਸਨੂੰ ਖੋਲ੍ਹੋ।',
  'cannotCaptureOwn': 'ਆਪਣਾ ਮੋਹਰਾ ਨਹੀਂ ਮਾਰ ਸਕਦੇ।',
  'cannotCapture': '{attacker} {defender} ਨੂੰ ਨਹੀਂ ਮਾਰ ਸਕਦਾ।',
  'mutualElimination':
      '{actor} ਦਾ {attacker} ਅਤੇ {defenderSide} ਦਾ {defender} ਦੋਵੇਂ ਹਟ ਗਏ।',
  'capturedPiece':
      '{actor} ਦੇ {attacker} ਨੇ {defenderSide} ਦੇ {defender} ਨੂੰ ਮਾਰਿਆ।',
  'winnerNoLegalAction': '{side} ਜਿੱਤ ਗਿਆ। ਵਿਰੋਧੀ ਕੋਲ ਕੋਈ ਕਾਨੂੰਨੀ ਚਾਲ ਨਹੀਂ।',
  'winnerElimination': '{side} ਨੇ ਸਾਰੇ ਵਿਰੋਧੀ ਮੋਹਰੇ ਮਾਰ ਕੇ ਜਿੱਤਿਆ।',
  'drawNonCaptureLimit': '{limit} ਵਾਰੀਆਂ ਤੱਕ ਕੋਈ ਮਾਰ ਨਹੀਂ। ਡਰਾਅ।',
  'drawNoLegalActions': 'ਕਿਸੇ ਪਾਸੇ ਕੋਲ ਕਾਨੂੰਨੀ ਚਾਲ ਨਹੀਂ। ਡਰਾਅ।',
  'drawMutualElimination': 'ਆਖਰੀ ਮੋਹਰੇ ਇਕੱਠੇ ਹਟ ਗਏ। ਡਰਾਅ।',
  'turnMessage':
      '{side} ਦੀ ਵਾਰੀ: ਮੋਹਰਾ ਖੋਲ੍ਹੋ ਜਾਂ ਇੱਕ ਕਦਮ ਚਲੋ। ਬਿਨਾਂ ਮਾਰ {count}/{limit}।',
  'remainingAfterCapture':
      '{action} {side} ਕੋਲ ਛੁਪਿਆਂ ਸਮੇਤ {remaining} ਮੋਹਰੇ ਬਾਕੀ ਹਨ।\n{turn}',
  'currentTurn': 'ਮੌਜੂਦਾ ਵਾਰੀ: {side}',
  'victoryHeading': '{side} ਦੀ ਜਿੱਤ',
  'sideRemaining': '{side} ਬਾਕੀ',
  'piecesCount': '{count} ਮੋਹਰੇ',
  'gameOverWinner': '{side} ਜਿੱਤਿਆ',
  'rule1':
      '1. ਬੋਰਡ 4 x 4 ਹੈ, ਕੁੱਲ 16 ਮੋਹਰੇ। ਲਾਲ ਅਤੇ ਨੀਲੇ ਕੋਲ 1 ਤੋਂ 8 ਤੱਕ ਦਰਜੇ ਹਨ।',
  'rule2':
      '2. ਹਰ ਵਾਰੀ ਇੱਕ ਕੰਮ ਚੁਣੋ: ਛੁਪਿਆ ਮੋਹਰਾ ਖੋਲ੍ਹੋ ਜਾਂ ਆਪਣਾ ਖੁੱਲ੍ਹਾ ਮੋਹਰਾ ਇੱਕ ਕਦਮ ਚਲਾਓ।',
  'rule3':
      '3. ਮੋਹਰੇ ਸਿਰਫ ਉੱਪਰ, ਹੇਠਾਂ, ਖੱਬੇ ਜਾਂ ਸੱਜੇ ਚਲਦੇ ਹਨ। ਤਿਰਛਾ ਜਾਂ ਕਈ ਘਰ ਨਹੀਂ।',
  'rule4':
      '4. ਮਾਰਣ ਲਈ ਵਿਰੋਧੀ ਮੋਹਰਾ ਖੁੱਲ੍ਹਾ ਅਤੇ ਨੰਬਰ ਬਰਾਬਰ ਜਾਂ ਘੱਟ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ। ਖਾਸ ਨਿਯਮ: 1, 8 ਨੂੰ ਮਾਰਦਾ ਹੈ, ਪਰ 8, 1 ਨੂੰ ਨਹੀਂ।',
  'rule5': '5. ਨੰਬਰ ਬਰਾਬਰ ਹੋਣ ਤਾਂ ਦੋਵੇਂ ਮੋਹਰੇ ਹਟ ਜਾਂਦੇ ਹਨ।',
  'rule6': '6. ਸਾਰੇ ਵਿਰੋਧੀ ਮੋਹਰੇ ਮਾਰ ਕੇ ਜਿੱਤੋ। ਆਖਰੀ ਮੋਹਰੇ ਇਕੱਠੇ ਹਟਣ ਤਾਂ ਡਰਾਅ।',
  'rule7':
      '7. ਜੇ ਛੁਪੇ ਮੋਹਰੇ ਨਹੀਂ ਅਤੇ ਇੱਕ ਪਾਸਾ ਨਹੀਂ ਚੱਲ ਸਕਦਾ, ਦੂਜਾ ਜਿੱਤਦਾ ਹੈ। ਦੋਵੇਂ ਨਾ ਚੱਲ ਸਕਣ ਤਾਂ ਡਰਾਅ।',
  'rule8':
      '8. ਲਗਾਤਾਰ {limit} ਵਾਰੀਆਂ ਬਿਨਾਂ ਮਾਰ ਦੇ ਡਰਾਅ ਹਨ। ਮਾਰ ਤੋਂ ਬਾਅਦ ਗਿਣਤੀ ਰੀਸੈਟ ਹੁੰਦੀ ਹੈ।',
  'rule9': '9. ਮਾਰੇ ਘਰ ਖਾਲੀ ਹੋ ਜਾਂਦੇ ਹਨ ਅਤੇ ਬਾਅਦ ਵਿੱਚ ਉਥੇ ਜਾਇਆ ਜਾ ਸਕਦਾ ਹੈ।',
};

const Map<String, Map<String, String>> _localizedStrings =
    <String, Map<String, String>>{
      'zh': _chineseStrings,
      'es': _spanishStrings,
      'fr': _frenchStrings,
      'de': _germanStrings,
      'it': _italianStrings,
      'pt': _portugueseStrings,
      'nl': _dutchStrings,
      'pl': _polishStrings,
      'ro': _romanianStrings,
      'ru': _russianStrings,
      'uk': _ukrainianStrings,
      'tr': _turkishStrings,
      'el': _greekStrings,
      'sv': _swedishStrings,
      'cs': _czechStrings,
      'hu': _hungarianStrings,
      'da': _danishStrings,
      'fi': _finnishStrings,
      'no': _norwegianStrings,
      'sk': _slovakStrings,
      'bg': _bulgarianStrings,
      'hi': _hindiStrings,
      'ar': _arabicStrings,
      'bn': _bengaliStrings,
      'ur': _urduStrings,
      'id': _indonesianStrings,
      'ja': _japaneseStrings,
      'pa': _punjabiStrings,
      'vi': _vietnameseStrings,
      'ko': _koreanStrings,
    };
