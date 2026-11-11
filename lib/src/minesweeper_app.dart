import 'dart:async';
import 'package:flutter/material.dart';
import 'minesweeper_game.dart';

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const MinesweeperHome());
}

class MinesweeperHome extends StatefulWidget {
  const MinesweeperHome({super.key});
  @override
  State<MinesweeperHome> createState() => _MinesweeperHomeState();
}

class _MinesweeperHomeState extends State<MinesweeperHome> {
  BoardSize _selected = BoardSize.nine;
  MinesweeperGame? _game;

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return Scaffold(
      backgroundColor: const Color(0xff162b2b),
      body: SafeArea(
          child: game == null
              ? _StartView(
                  selected: _selected,
                  onSelected: (value) => setState(() => _selected = value),
                  onStart: () => setState(() {
                        _game = MinesweeperGame(selectedSize: _selected)
                          ..start();
                      }))
              : _GameView(
                  game: game,
                  onRestart: () => setState(() {
                        _game = MinesweeperGame(selectedSize: _selected)
                          ..start();
                      }))),
    );
  }
}

class _StartView extends StatelessWidget {
  const _StartView(
      {required this.selected,
      required this.onSelected,
      required this.onStart});
  final BoardSize selected;
  final ValueChanged<BoardSize> onSelected;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('踩地雷',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xfff6e7b4))),
        const SizedBox(height: 8),
        const Text('選擇棋盤尺寸後開始遊戲', style: TextStyle(color: Color(0xff9db5a2))),
        const Spacer(),
        const Text('BOARD SIZE',
            style: TextStyle(
                color: Color(0xff9db5a2),
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        for (final size in BoardSize.values)
          Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SizeCard(
                  size: size,
                  selected: size == selected,
                  onTap: () => onSelected(size))),
        const SizedBox(height: 8),
        SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xffe6be5b),
                    foregroundColor: const Color(0xff294a40)),
                child: const Text('開始遊戲',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))),
        const Spacer(),
        const Center(
            child: Text('大棋盤會維持固定格子大小，拖曳即可滑動視角',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xff789184), fontSize: 12))),
      ]));
}

class _SizeCard extends StatelessWidget {
  const _SizeCard(
      {required this.size, required this.selected, required this.onTap});
  final BoardSize size;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color:
                  selected ? const Color(0xffe6be5b) : const Color(0xff294a40),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: selected
                      ? const Color(0xffe6be5b)
                      : const Color(0xff688873))),
          child: Row(children: [
            Text('${size.cellsPerSide} × ${size.cellsPerSide}',
                style: TextStyle(
                    color: selected
                        ? const Color(0xff294a40)
                        : const Color(0xfff6e7b4),
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const Spacer(),
            Text('${size.mineCount} 顆地雷',
                style: TextStyle(
                    color: selected
                        ? const Color(0xff345449)
                        : const Color(0xff9db5a2)))
          ])));
}

class _GameView extends StatefulWidget {
  const _GameView({required this.game, required this.onRestart});
  final MinesweeperGame game;
  final VoidCallback onRestart;
  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  // Matches the content width after the 24px horizontal page padding on Pixel 7a.
  static const viewport = 382.0;
  // The mobile viewport always shows exactly 9x9 cells. Larger boards keep
  // this same cell size and are explored by long-press dragging.
  static const cellSize = viewport / 9;
  static const dragSlop = 12.0;
  Timer? _timer;
  bool _moved = false;
  int _doubleTapIndex = 0;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.game.status == GameStatus.playing)
        setState(() => widget.game.elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(children: [
        Row(children: [
          const Text('踩地雷',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xfff6e7b4))),
          const Spacer(),
          Text(_statusLabel(widget.game.status),
              style: const TextStyle(
                  color: Color(0xfff6e7b4),
                  fontSize: 22,
                  fontWeight: FontWeight.bold))
        ]),
        const SizedBox(height: 16),
        _InfoBar(game: widget.game),
        const SizedBox(height: 16),
        GestureDetector(
          key: const ValueKey('minesweeper-board'),
          onTapUp: (details) {
            setState(() => widget.game.reveal(_cellAt(details.localPosition)));
          },
          onDoubleTapDown: (details) {
            _doubleTapIndex = _cellAt(details.localPosition);
          },
          onDoubleTap: () {
            setState(() => widget.game.toggleFlag(_doubleTapIndex));
          },
          onPanStart: (details) {
            _moved = false;
          },
          onPanUpdate: (details) {
            if (details.delta.distance > dragSlop) _moved = true;
            if (_moved) {
              setState(() => widget.game.panBy(
                  details.delta.dx, details.delta.dy,
                  viewportSize: viewport, cellSize: cellSize));
            }
          },
          child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                  width: viewport,
                  height: viewport,
                  color: const Color(0xff294a40),
                  child: _Board(game: widget.game))),
        ),
        const SizedBox(height: 18),
        const Text('拖曳移動視角 · 點擊翻開 · 雙擊插旗',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff9db5a2), fontSize: 12)),
        const SizedBox(height: 18),
        SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
                onPressed: widget.onRestart,
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xffe6be5b),
                    foregroundColor: const Color(0xff294a40)),
                child: Text(
                    widget.game.status == GameStatus.playing ? '重新開始' : '再玩一次',
                    style: TextStyle(fontWeight: FontWeight.w900)))),
      ]));
  String _statusLabel(GameStatus status) => switch (status) {
        GameStatus.ready => '準備',
        GameStatus.playing => '${widget.game.remainingMines}',
        GameStatus.won => '完成',
        GameStatus.lost => '失敗',
      };
  int _cellAt(Offset local) {
    final x = (local.dx + widget.game.viewportX) ~/ cellSize;
    final y = (local.dy + widget.game.viewportY) ~/ cellSize;
    return y * widget.game.sideLength + x;
  }
}

class _InfoBar extends StatelessWidget {
  const _InfoBar({required this.game});
  final MinesweeperGame game;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xfff6e7b4),
          borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(_statusText,
            style: const TextStyle(
                color: Color(0xff294a40), fontWeight: FontWeight.bold)),
        Text(
            '${game.elapsedSeconds ~/ 60}:${(game.elapsedSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
                color: Color(0xff294a40), fontWeight: FontWeight.bold))
      ]));

  String get _statusText => switch (game.status) {
        GameStatus.ready => '準備中',
        GameStatus.playing => '雷 ${game.remainingMines}',
        GameStatus.won => '挑戰成功',
        GameStatus.lost => '踩到地雷',
      };
}

class _Board extends StatelessWidget {
  const _Board({required this.game});
  final MinesweeperGame game;
  @override
  Widget build(BuildContext context) => ClipRect(
      child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0,
          maxWidth: double.infinity,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Transform.translate(
              offset: Offset(-game.viewportX, -game.viewportY),
              child: SizedBox(
                  width: game.sideLength * _GameViewState.cellSize,
                  height: game.sideLength * _GameViewState.cellSize,
                  child: Stack(children: [
                    for (var index = 0; index < game.cells.length; index++)
                      Positioned(
                          left: (index % game.sideLength) *
                              _GameViewState.cellSize,
                          top: (index ~/ game.sideLength) *
                              _GameViewState.cellSize,
                          width: _GameViewState.cellSize,
                          height: _GameViewState.cellSize,
                          child: _Cell(cell: game.cells[index]))
                  ])))));
}

class _Cell extends StatelessWidget {
  const _Cell({required this.cell});
  final MinesweeperCell cell;
  @override
  Widget build(BuildContext context) {
    final revealed = cell.state == CellState.revealed;
    return Container(
        decoration: BoxDecoration(
            color: revealed ? const Color(0xfff2e2ac) : const Color(0xff5d806b),
            border: Border.all(color: const Color(0xffd2bd7a), width: 1)),
        alignment: Alignment.center,
        child: cell.state == CellState.flagged
            ? const Text('⚑', style: TextStyle(fontSize: 15))
            : revealed && !cell.isMine && cell.adjacentMines > 0
                ? Text('${cell.adjacentMines}',
                    style: const TextStyle(
                        color: Color(0xff3b72a1),
                        fontSize: 14,
                        fontWeight: FontWeight.bold))
                : revealed && cell.isMine
                    ? const Text('✹',
                        style:
                            TextStyle(color: Color(0xffd46e4c), fontSize: 14))
                    : null);
  }
}
