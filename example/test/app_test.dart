import 'package:flutter_test/flutter_test.dart';
import 'package:taiwan_brawl_minesweeper/taiwan_brawl_minesweeper_flutter.dart';

void main() {
  testWidgets('example boots the minesweeper start screen', (tester) async {
    await tester.pumpWidget(const MinesweeperApp());
    expect(find.text('踩地雷'), findsOneWidget);
    expect(find.text('開始遊戲'), findsOneWidget);
  });
}
