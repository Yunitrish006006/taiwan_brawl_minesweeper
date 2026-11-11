enum BoardSize {
  nine(9),
  sixteen(16),
  twentyFive(25);

  const BoardSize(this.cellsPerSide);
  final int cellsPerSide;
}

enum CellState { covered, revealed, flagged }

class MinesweeperCell {
  MinesweeperCell({this.state = CellState.covered, this.adjacentMines = 0});

  CellState state;
  final int adjacentMines;
}

enum GameStatus { ready, playing, won, lost }

class MinesweeperGame {
  MinesweeperGame({required this.selectedSize})
      : cells = List.generate(
          selectedSize.cellsPerSide * selectedSize.cellsPerSide,
          (_) => MinesweeperCell(),
        );

  final BoardSize selectedSize;
  final List<MinesweeperCell> cells;
  GameStatus status = GameStatus.ready;
  double viewportX = 0;
  double viewportY = 0;

  int get sideLength => selectedSize.cellsPerSide;

  void start() {
    if (status != GameStatus.ready) return;
    status = GameStatus.playing;
  }

  void panBy(double dx, double dy, {required double viewportSize, required double cellSize}) {
    if (status != GameStatus.playing) return;
    final boardExtent = sideLength * cellSize;
    final maxOffset = (boardExtent - viewportSize).clamp(0, double.infinity).toDouble();
    viewportX = (viewportX - dx).clamp(0, maxOffset).toDouble();
    viewportY = (viewportY - dy).clamp(0, maxOffset).toDouble();
  }

  void toggleFlag(int index) {
    if (status != GameStatus.playing) return;
    final cell = cells[index];
    if (cell.state == CellState.covered) {
      cell.state = CellState.flagged;
    } else if (cell.state == CellState.flagged) {
      cell.state = CellState.covered;
    }
  }
}
