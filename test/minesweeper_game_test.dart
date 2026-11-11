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

  test('the first reveal has zero mines in its surrounding eight cells', () {
    final game = MinesweeperGame(selectedSize: BoardSize.nine, seed: 19)
      ..start();
    const firstIndex = 40;

    game.reveal(firstIndex);

    expect(game.cells[firstIndex].isMine, isFalse);
    expect(game.cells[firstIndex].adjacentMines, 0);
    for (final cell in game.cells) {
      if (cell.state == CellState.revealed) {
        expect(cell.isMine, isFalse);
      }
    }
  });

  test('large boards pan inside a fixed-size viewport', () {
    final game = MinesweeperGame(selectedSize: BoardSize.twentyFive)..start();

    game.panBy(-100, -80, viewportSize: 216, cellSize: 24);
    expect(game.viewportX, 100);
    expect(game.viewportY, 80);

    game.panBy(-9999, -9999, viewportSize: 216, cellSize: 24);
    expect(game.viewportX, 408);
    expect(game.viewportY, 408);

    game.panBy(9999, 9999, viewportSize: 216, cellSize: 24);
    expect(game.viewportX, -24);
    expect(game.viewportY, -24);
  });

  test('large boards begin with a centered viewport', () {
    final game = MinesweeperGame(selectedSize: BoardSize.sixteen)..start();

    game.centerViewport(viewportSize: 216, cellSize: 24);

    expect(game.viewportX, 84);
    expect(game.viewportY, 84);
  });

  test('long press without movement can toggle a flag', () {
    final game = MinesweeperGame(selectedSize: BoardSize.nine)..start();

    game.toggleFlag(4);
    expect(game.cells[4].state, CellState.flagged);
    game.toggleFlag(4);
    expect(game.cells[4].state, CellState.covered);
  });

  test('a lost large board can still pan to inspect every revealed mine', () {
    final game = MinesweeperGame(selectedSize: BoardSize.sixteen, seed: 7)
      ..start();
    game.reveal(0);
    final mineIndex = game.cells.indexWhere((cell) => cell.isMine);
    game.reveal(mineIndex);

    expect(game.status, GameStatus.lost);
    game.panBy(-100, -100, viewportSize: 216, cellSize: 24);
    expect(game.viewportX, 100);
    expect(game.viewportY, 100);
    expect(
        game.cells.where((cell) => cell.isMine),
        everyElement(predicate<MinesweeperCell>(
            (cell) => cell.state == CellState.revealed)));
  });

  test('flag subtraction is optional and never makes a number negative', () {
    final game = MinesweeperGame(
        selectedSize: BoardSize.nine, autoSubtractFlagged: true, seed: 19)
      ..start();
    game.reveal(40);
    final numbered = game.cells.indexWhere((cell) =>
        cell.state == CellState.revealed &&
        !cell.isMine &&
        cell.adjacentMines > 0);
    expect(numbered, isNonNegative);
    final before = game.displayedAdjacentMines(numbered);
    final neighbor =
        game.cells.indexWhere((cell) => cell.state == CellState.covered);
    game.toggleFlag(neighbor);
    expect(game.displayedAdjacentMines(numbered), lessThanOrEqualTo(before));
    expect(game.displayedAdjacentMines(numbered), greaterThanOrEqualTo(0));
  });

  test('an incorrect flag immediately loses when the rule is enabled', () {
    final game = MinesweeperGame(
        selectedSize: BoardSize.nine, autoSubtractFlagged: true, seed: 19)
      ..start();
    game.reveal(40);
    final wrongFlag = game.cells
        .indexWhere((cell) => !cell.isMine && cell.state == CellState.covered);

    game.toggleFlag(wrongFlag);

    expect(game.status, GameStatus.lost);
    expect(game.cells[wrongFlag].state, CellState.revealed);
    expect(
        game.cells.where((cell) => cell.isMine),
        everyElement(predicate<MinesweeperCell>(
            (cell) => cell.state == CellState.revealed)));
  });
}
