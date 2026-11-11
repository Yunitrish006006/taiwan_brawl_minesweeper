import 'package:test/test.dart';
import 'package:taiwan_brawl_minesweeper/taiwan_brawl_minesweeper.dart';

void main() {
  test('size is selected before start and remains fixed', () {
    final game = MinesweeperGame(selectedSize: BoardSize.twentyFive);

    expect(game.sideLength, 25);
    expect(game.cells, hasLength(625));
    expect(game.status, GameStatus.ready);

    game.start();

    expect(game.status, GameStatus.playing);
    expect(game.selectedSize, BoardSize.twentyFive);
  });

  test('large boards pan inside a fixed-size viewport', () {
    final game = MinesweeperGame(selectedSize: BoardSize.twentyFive)..start();

    game.panBy(-100, -80, viewportSize: 216, cellSize: 24);
    expect(game.viewportX, 100);
    expect(game.viewportY, 80);

    game.panBy(-9999, -9999, viewportSize: 216, cellSize: 24);
    expect(game.viewportX, 384);
    expect(game.viewportY, 384);
  });

  test('long press without movement can toggle a flag', () {
    final game = MinesweeperGame(selectedSize: BoardSize.nine)..start();

    game.toggleFlag(4);
    expect(game.cells[4].state, CellState.flagged);
    game.toggleFlag(4);
    expect(game.cells[4].state, CellState.covered);
  });
}
