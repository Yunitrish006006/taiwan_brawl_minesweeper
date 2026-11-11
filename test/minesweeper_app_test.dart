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

    expect(find.text('拖曳移動視角 · 點擊翻開 · 雙擊插旗'), findsOneWidget);
    expect(find.text('雷 40'), findsOneWidget);
  });

  testWidgets('double tap flags a covered cell without revealing it',
      (tester) async {
    await tester.pumpWidget(const MinesweeperApp());
    await tester.tap(find.text('開始遊戲'));
    await tester.pump();

    final board = find.byKey(const ValueKey('minesweeper-board'));
    await tester.tap(board);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(board);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('⚑'), findsOneWidget);
  });
}
