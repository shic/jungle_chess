import 'package:flutter_test/flutter_test.dart';
import 'package:jungle_chess/main.dart';

void main() {
  testWidgets('renders jungle chess game screen', (tester) async {
    await tester.pumpWidget(const JungleChessApp());

    expect(find.text('斗兽棋'), findsOneWidget);
    expect(find.text('重新开始'), findsOneWidget);
    expect(find.text('规则说明'), findsOneWidget);
  });
}
