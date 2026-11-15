// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taiwan_brawl_minesweeper/taiwan_brawl_minesweeper_flutter.dart';

void main() {
  testWidgets('Minesweeper app renders the start screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MinesweeperApp()),
    );

    expect(find.text('踩地雷'), findsOneWidget);
    expect(find.text('開始遊戲'), findsOneWidget);
    expect(find.text('9 × 9'), findsOneWidget);
  });
}
