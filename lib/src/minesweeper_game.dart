import 'dart:math';

enum BoardSize {
  nine(9, 10),
  sixteen(16, 40),
  twentyFive(25, 99);

  const BoardSize(this.cellsPerSide, this.mineCount);
  final int cellsPerSide;
  final int mineCount;
}

enum CellState { covered, revealed, flagged }

enum GameStatus { ready, playing, won, lost }

class MinesweeperCell {
  MinesweeperCell(
      {this.state = CellState.covered,
      this.adjacentMines = 0,
      this.isMine = false});
  CellState state;
  int adjacentMines;
  bool isMine;
}

class MinesweeperGame {
  MinesweeperGame({required this.selectedSize, int? seed})
      : _random = Random(seed),
        cells = List.generate(
            selectedSize.cellsPerSide * selectedSize.cellsPerSide,
            (_) => MinesweeperCell());

  final BoardSize selectedSize;
  final List<MinesweeperCell> cells;
  final Random _random;
  GameStatus status = GameStatus.ready;
  double viewportX = 0;
  double viewportY = 0;
  DateTime? startedAt;
  int elapsedSeconds = 0;

  int get sideLength => selectedSize.cellsPerSide;
  int get flaggedCount =>
      cells.where((cell) => cell.state == CellState.flagged).length;
  int get remainingMines => selectedSize.mineCount - flaggedCount;

  void start() {
    if (status != GameStatus.ready) return;
    status = GameStatus.playing;
    startedAt = DateTime.now();
  }

  void reveal(int index) {
    if (status != GameStatus.playing || !_validIndex(index)) return;
    final cell = cells[index];
    if (cell.state != CellState.covered) return;
    if (!_hasMines) _placeMines(index);
    if (cell.isMine) {
      cell.state = CellState.revealed;
      for (final mine in cells.where((item) => item.isMine)) {
        mine.state = CellState.revealed;
      }
      status = GameStatus.lost;
      return;
    }
    _floodReveal(index);
    if (cells
        .where((item) => !item.isMine)
        .every((item) => item.state == CellState.revealed))
      status = GameStatus.won;
  }

  void toggleFlag(int index) {
    if (status != GameStatus.playing || !_validIndex(index)) return;
    final cell = cells[index];
    if (cell.state == CellState.covered) {
      cell.state = CellState.flagged;
    } else if (cell.state == CellState.flagged) {
      cell.state = CellState.covered;
    }
  }

  void panBy(double dx, double dy,
      {required double viewportSize, required double cellSize}) {
    if (status == GameStatus.ready) return;
    final boardExtent = sideLength * cellSize;
    final maxOffset = max(0, boardExtent - viewportSize).toDouble();
    final edgeAllowance = cellSize;
    viewportX = (viewportX - dx)
        .clamp(-edgeAllowance, maxOffset + edgeAllowance)
        .toDouble();
    viewportY = (viewportY - dy)
        .clamp(-edgeAllowance, maxOffset + edgeAllowance)
        .toDouble();
  }

  void centerViewport(
      {required double viewportSize, required double cellSize}) {
    final boardExtent = sideLength * cellSize;
    viewportX = max(0, (boardExtent - viewportSize) / 2).toDouble();
    viewportY = max(0, (boardExtent - viewportSize) / 2).toDouble();
  }

  bool get _hasMines => cells.any((cell) => cell.isMine);
  bool _validIndex(int index) => index >= 0 && index < cells.length;

  void _placeMines(int safeIndex) {
    final candidates = List<int>.generate(cells.length, (index) => index)
      ..removeWhere((index) =>
          index == safeIndex || _neighbors(safeIndex).contains(index))
      ..shuffle(_random);
    for (final index in candidates.take(selectedSize.mineCount))
      cells[index].isMine = true;
    for (var index = 0; index < cells.length; index++) {
      cells[index].adjacentMines =
          _neighbors(index).where((item) => cells[item].isMine).length;
    }
  }

  void _floodReveal(int start) {
    final pending = <int>[start];
    final visited = <int>{};
    while (pending.isNotEmpty) {
      final index = pending.removeLast();
      if (!visited.add(index)) continue;
      final cell = cells[index];
      if (cell.state == CellState.flagged || cell.isMine) continue;
      cell.state = CellState.revealed;
      if (cell.adjacentMines == 0) pending.addAll(_neighbors(index));
    }
  }

  Iterable<int> _neighbors(int index) sync* {
    final row = index ~/ sideLength;
    final column = index % sideLength;
    for (var rowDelta = -1; rowDelta <= 1; rowDelta++) {
      for (var columnDelta = -1; columnDelta <= 1; columnDelta++) {
        if (rowDelta == 0 && columnDelta == 0) continue;
        final neighborRow = row + rowDelta;
        final neighborColumn = column + columnDelta;
        if (neighborRow >= 0 &&
            neighborRow < sideLength &&
            neighborColumn >= 0 &&
            neighborColumn < sideLength)
          yield neighborRow * sideLength + neighborColumn;
      }
    }
  }
}
