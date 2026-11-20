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

  testWidgets('miner stays centered while the board follows each step',
      (tester) async {
    await _startMinerOnPhone(tester);
    final board = find.byKey(const ValueKey('minesweeper-board'));
    final miner = find.byKey(const ValueKey('miner-player'));
    final stick = tester.getCenter(
      find.byKey(const ValueKey('miner-joystick-knob')),
    );
    final center = tester.getCenter(board);
    final initialGridX = _gridX(tester, board);
    expect(tester.getCenter(miner), center);

    await tester.dragFrom(center, const Offset(-80, 0));
    await tester.pumpAndSettle();
    expect(_gridX(tester, board), initialGridX);

    final gesture = await tester.startGesture(stick);
    await gesture.moveBy(const Offset(38, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getCenter(miner), center);
    expect(tester.widget<Text>(miner).data, '→⛏️');
    expect(
      _gridX(tester, board),
      closeTo(initialGridX - tester.getSize(board).width / 9, 0.01),
    );
    await gesture.up();
  });

  testWidgets(
      'stick repeats while held, stabilizes diagonals and stops in neutral',
      (tester) async {
    await _startMinerOnPhone(tester);
    final board = find.byKey(const ValueKey('minesweeper-board'));
    final miner = find.byKey(const ValueKey('miner-player'));
    final stick = tester.getCenter(
      find.byKey(const ValueKey('miner-joystick-knob')),
    );
    final initialGridX = _gridX(tester, board);
    final cellSize = tester.getSize(board).width / 9;

    // The generated opening always reveals one tile on each side.
    final left = await tester.startGesture(stick);
    await left.moveBy(const Offset(-35, 0));
    await left.up();
    await tester.pumpAndSettle();
    expect(_gridX(tester, board), closeTo(initialGridX + cellSize, 0.01));

    final right = await tester.startGesture(stick);
    await right.moveTo(stick + const Offset(45, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 95));
    expect(_gridX(tester, board), closeTo(initialGridX, 0.01));
    await right.moveTo(stick + const Offset(31, 33));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<Text>(miner).data, '→⛏️');
    expect(_gridX(tester, board), closeTo(initialGridX - cellSize, 0.01));

    await right.moveTo(stick);
    await tester.pump(const Duration(milliseconds: 400));
    expect(_gridX(tester, board), closeTo(initialGridX - cellSize, 0.01));
    expect(tester.getCenter(find.byIcon(Icons.open_with)), stick);

    await right.moveTo(stick + const Offset(-14, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<Text>(miner).data, '←⛏️');
    expect(_gridX(tester, board), closeTo(initialGridX, 0.01));
    await right.cancel();
    await tester.pump(const Duration(milliseconds: 400));
    expect(_gridX(tester, board), closeTo(initialGridX, 0.01));
    expect(tester.getCenter(find.byIcon(Icons.open_with)), stick);
  });
}

Future<void> _startMinerOnPhone(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: MinesweeperApp()));
  await tester.tap(find.text('礦工模式'));
  await tester.tap(find.text('16 × 16'));
  await tester.pump();
  await tester.tap(find.text('開始遊戲'));
  await tester.pumpAndSettle();
}

double _gridX(WidgetTester tester, Finder board) => tester
    .widget<Transform>(
      find.descendant(of: board, matching: find.byType(Transform)).first,
    )
    .transform
    .getTranslation()
    .x;
