import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:taiwan_brawl_minesweeper/taiwan_brawl_minesweeper_flutter.dart';
import 'package:user_ui_settings/user_ui_settings.dart';

void main() {
  test('localizes mine count labels', () {
    expect(MinesweeperLocalizations('zh-Hant').mineCountLabel(10), '10 顆地雷');
    expect(MinesweeperLocalizations('en').mineCountLabel(10), '10 mines');
    expect(MinesweeperLocalizations('ja').mineCountLabel(10), '10個の地雷');
    expect(
      MinesweeperLocalizations('en').text('minesweeper.direction.right', ''),
      'Right',
    );
  });

  testWidgets('accepts host settings and the active locale', (tester) async {
    final settings = GameUiSettings(
      locale: 'en',
      themeId: 'light',
      themeMode: ThemeMode.light,
      activeTheme: ThemeData.light(useMaterial3: true),
      fontScale: 1.2,
      disableAnimations: true,
      accessibleNavigation: true,
    );

    await tester.pumpWidget(
      MaterialApp(home: MinesweeperApp(settings: settings)),
    );

    final title = find.text('Minesweeper');
    expect(title, findsOneWidget);
    expect(
      Theme.of(tester.element(title)).brightness,
      Brightness.light,
    );
    final startButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start game'),
    );
    expect(
      startButton.style?.backgroundColor?.resolve({}),
      settings.activeTheme.colorScheme.primary,
    );
  });

  testWidgets('selects board size before starting the game', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MinesweeperApp()));

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
    await tester.pumpWidget(const MaterialApp(home: MinesweeperApp()));
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

  testWidgets('miner mode starts with a pre-dug center and dig/flag controls',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MinesweeperApp()));
    await tester.tap(find.text('礦工模式'));
    await tester.pump();
    await tester.tap(find.text('開始遊戲'));
    await tester.pump();

    expect(find.text('礦工模式'), findsOneWidget);
    expect(find.text('挖掘'), findsOneWidget);
    expect(find.text('插旗'), findsOneWidget);
    expect(find.text('插旗自動扣除數字'), findsNothing);
    expect(find.byKey(const ValueKey('miner-joystick-knob')), findsOneWidget);
    expect(find.text('拖曳方向'), findsOneWidget);
  });
}
