import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:taiwan_brawl_minesweeper/taiwan_brawl_minesweeper_flutter.dart';

void main() {
  testWidgets('selects board size before starting the game', (tester) async {
    await tester.pumpWidget(const MinesweeperApp());

    expect(find.text('選擇棋盤尺寸後開始遊戲'), findsOneWidget);
    expect(find.text('9 × 9'), findsOneWidget);

    await tester.tap(find.text('16 × 16'));
    await tester.pump();
    await tester.tap(find.text('開始遊戲'));
    await tester.pump();

    expect(find.text('長按後滑動移動視角 · 點擊翻開 · 長按不移動插旗'), findsOneWidget);
    expect(find.text('雷 40'), findsOneWidget);
  });

  testWidgets('long press flags a covered cell without revealing it',
      (tester) async {
    await tester.pumpWidget(const MinesweeperApp());
    await tester.tap(find.text('開始遊戲'));
    await tester.pump();

    await tester.longPress(find.byKey(const ValueKey('minesweeper-board')));
    await tester.pump();

    expect(find.text('⚑'), findsOneWidget);
  });
}
