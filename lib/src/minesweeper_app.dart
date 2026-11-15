import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:user_ui_settings/user_ui_settings.dart';
import 'minesweeper_game.dart';
import 'minesweeper_localizations.dart';

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key, this.settings});

  final GameUiSettings? settings;

  @override
  Widget build(BuildContext context) {
    final app = MinesweeperHome(settings: settings);
    return settings == null
        ? app
        : GameUiSettingsScope(settings: settings!, child: app);
  }
}

class MinesweeperHome extends StatefulWidget {
  const MinesweeperHome({super.key, this.settings});

  /// Optional explicit injection for host routes, previews, and tests.
  /// Bundled navigation normally obtains the same value from the host scope.
  final GameUiSettings? settings;

  @override
  State<MinesweeperHome> createState() => _MinesweeperHomeState();
}

class _MinesweeperHomeState extends State<MinesweeperHome> {
  BoardSize _selected = BoardSize.nine;
  MinesweeperMode _mode = MinesweeperMode.classic;
  MinesweeperGame? _game;

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings ?? GameUiSettingsScope.maybeOf(context);
    final game = _game;
    final child = Scaffold(
      backgroundColor: settings?.activeTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: game == null
            ? _StartView(
                selected: _selected,
                onSelected: (value) => setState(() => _selected = value),
                mode: _mode,
                onModeSelected: (value) => setState(() => _mode = value),
                onStart: () => setState(() {
                      _game =
                          MinesweeperGame(selectedSize: _selected, mode: _mode)
                            ..start();
                    }))
            : _GameView(
                game: game,
                onRestart: () => setState(() {
                      _game =
                          MinesweeperGame(selectedSize: _selected, mode: _mode)
                            ..start();
                    })),
      ),
    );
    return settings == null
        ? child
        : Theme(data: settings.activeTheme, child: child);
  }
}

class _StartView extends StatelessWidget {
  const _StartView(
      {required this.selected,
      required this.onSelected,
      required this.mode,
      required this.onModeSelected,
      required this.onStart});
  final BoardSize selected;
  final ValueChanged<BoardSize> onSelected;
  final MinesweeperMode mode;
  final ValueChanged<MinesweeperMode> onModeSelected;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_mineText(context, 'minesweeper.title', '踩地雷'),
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: scheme.onSurface)),
        const SizedBox(height: 8),
        Text(_mineText(context, 'minesweeper.selectBoard', '選擇棋盤尺寸後開始遊戲'),
            style: TextStyle(color: scheme.onSurfaceVariant)),
        const Spacer(),
        Text(_mineText(context, 'minesweeper.gameMode', 'GAME MODE'),
            style: TextStyle(
                color: scheme.onSurfaceVariant,
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        SegmentedButton<MinesweeperMode>(
          segments: [
            ButtonSegment(
                value: MinesweeperMode.classic,
                label: Text(_mineText(context, 'minesweeper.classic', '標準模式'))),
            ButtonSegment(
                value: MinesweeperMode.miner,
                label: Text(_mineText(context, 'minesweeper.miner', '礦工模式'))),
          ],
          selected: {mode},
          onSelectionChanged: (selection) => onModeSelected(selection.single),
        ),
        const SizedBox(height: 22),
        Text(_mineText(context, 'minesweeper.boardSize', 'BOARD SIZE'),
            style: TextStyle(
                color: scheme.onSurfaceVariant,
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
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary),
                child: Text(_mineText(context, 'minesweeper.start', '開始遊戲'),
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))),
        const Spacer(),
        Center(
            child: Text(
                mode == MinesweeperMode.miner
                    ? _mineText(context, 'minesweeper.minerHint',
                        '礦工模式：中心預挖 · 只能挖掘 · 踩雷爆炸')
                    : _mineText(context, 'minesweeper.classicHint',
                        '大棋盤會維持固定格子大小，拖曳即可滑動視角'),
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: scheme.onSurfaceVariant, fontSize: 12))),
      ]),
    );
  }
}

class _SizeCard extends StatelessWidget {
  const _SizeCard(
      {required this.size, required this.selected, required this.onTap});
  final BoardSize size;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: selected
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: selected ? scheme.primary : scheme.outlineVariant)),
            child: Row(children: [
              Text('${size.cellsPerSide} × ${size.cellsPerSide}',
                  style: TextStyle(
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              const Spacer(),
              Text(
                  MinesweeperLocalizations(
                    GameUiSettingsScope.maybeOf(context)?.locale ?? 'zh-Hant',
                  ).mineCountLabel(size.mineCount),
                  style: TextStyle(
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant))
            ])));
  }
}

class _GameView extends StatefulWidget {
  const _GameView({required this.game, required this.onRestart});
  final MinesweeperGame game;
  final VoidCallback onRestart;
  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  static const dragSlop = 12.0;
  Timer? _timer;
  bool _moved = false;
  int _doubleTapIndex = 0;
  bool _initialViewportCentered = false;
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        child: Column(children: [
          Row(children: [
            Text(_mineText(context, 'minesweeper.title', '踩地雷'),
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface)),
            const Spacer(),
            Text(_statusLabel(context, widget.game.status),
                style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 16),
          _InfoBar(game: widget.game),
          const SizedBox(height: 16),
          if (widget.game.mode == MinesweeperMode.classic)
            _FlagSubtractionSwitch(
                game: widget.game,
                onChanged: (value) =>
                    setState(() => widget.game.autoSubtractFlagged = value)),
          if (widget.game.mode == MinesweeperMode.miner) ...[
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final viewport = constraints.maxWidth;
            final cellSize = viewport / 9;
            if (!_initialViewportCentered) {
              widget.game
                  .centerViewport(viewportSize: viewport, cellSize: cellSize);
              _initialViewportCentered = true;
            }
            return GestureDetector(
              key: const ValueKey('minesweeper-board'),
              onTapUp: (details) {
                if (widget.game.mode == MinesweeperMode.miner) return;
                final index = _cellAt(details.localPosition, cellSize);
                setState(() {
                  widget.game.reveal(index);
                });
              },
              onDoubleTapDown: (details) {
                _doubleTapIndex = _cellAt(details.localPosition, cellSize);
              },
              onDoubleTap: () {
                if (widget.game.mode == MinesweeperMode.miner) return;
                setState(() => widget.game.toggleFlag(_doubleTapIndex));
              },
              onPanStart: (_) {
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
                child: SizedBox(
                  width: viewport,
                  height: viewport,
                  child: ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: _Board(game: widget.game, cellSize: cellSize),
                  ),
                ),
              ),
            );
          }),
          if (widget.game.mode == MinesweeperMode.miner) ...[
            const SizedBox(height: 12),
            _MinerMovementControls(
              onMove: (direction) =>
                  setState(() => widget.game.moveMiner(direction)),
              onDig: () => setState(() => widget.game.digMinerFacing()),
              onFlag: () => setState(() => widget.game.flagMinerFacing()),
            ),
          ],
          const SizedBox(height: 18),
          Text(
              widget.game.mode == MinesweeperMode.miner
                  ? '${_mineText(context, 'minesweeper.facing', '朝向')}：${_mineDirectionText(context, widget.game.minerFacing)} · ${_mineText(context, 'minesweeper.minerGestureHint', '按挖掘／插旗直接作用前方格子 · 只能走已揭開的格子')}'
                  : _mineText(context, 'minesweeper.gestureHint',
                      '拖曳移動視角 · 點擊翻開 · 雙擊插旗'),
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 18),
          SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                  onPressed: widget.onRestart,
                  style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary),
                  child: Text(
                      widget.game.status == GameStatus.playing
                          ? _mineText(context, 'minesweeper.restart', '重新開始')
                          : _mineText(context, 'minesweeper.playAgain', '再玩一次'),
                      style: TextStyle(fontWeight: FontWeight.w900)))),
        ]));
  }

  String _statusLabel(BuildContext context, GameStatus status) =>
      switch (status) {
        GameStatus.ready =>
          _mineText(context, 'minesweeper.status.readyShort', '準備'),
        GameStatus.playing => widget.game.mode == MinesweeperMode.miner
            ? _mineText(context, 'minesweeper.minerShort', '礦工')
            : '${widget.game.remainingMines}',
        GameStatus.won =>
          _mineText(context, 'minesweeper.status.wonShort', '完成'),
        GameStatus.lost =>
          _mineText(context, 'minesweeper.status.lostShort', '失敗'),
      };
  int _cellAt(Offset local, double cellSize) {
    final x = (local.dx + widget.game.viewportX) ~/ cellSize;
    final y = (local.dy + widget.game.viewportY) ~/ cellSize;
    return y * widget.game.sideLength + x;
  }
}

class _MinerMovementControls extends StatelessWidget {
  const _MinerMovementControls({
    required this.onMove,
    required this.onDig,
    required this.onFlag,
  });

  final ValueChanged<MinerDirection> onMove;
  final VoidCallback onDig;
  final VoidCallback onFlag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _MinerJoystick(onMove: onMove),
        Column(
          children: [
            FilledButton.icon(
              onPressed: onDig,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              icon: const Icon(Icons.construction),
              label: Text(_mineText(context, 'minesweeper.dig', '挖掘')),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onFlag,
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.primary,
              ),
              icon: const Icon(Icons.flag),
              label: Text(_mineText(context, 'minesweeper.flag', '插旗')),
            ),
          ],
        ),
      ],
    );
  }
}

class _MinerJoystick extends StatefulWidget {
  const _MinerJoystick({required this.onMove});

  final ValueChanged<MinerDirection> onMove;

  @override
  State<_MinerJoystick> createState() => _MinerJoystickState();
}

class _MinerJoystickState extends State<_MinerJoystick> {
  static const _size = 150.0;
  static const _knobSize = 48.0;
  static const _maxTravel = 43.0;
  Offset _knobOffset = Offset.zero;
  MinerDirection? _lastDirection;

  void _updateKnob(Offset localPosition) {
    final center = const Offset(_size / 2, _size / 2);
    final delta = localPosition - center;
    final distance = delta.distance;
    final offset = distance <= _maxTravel
        ? delta
        : Offset.fromDirection(math.atan2(delta.dy, delta.dx), _maxTravel);
    if (distance < 10) return;
    final direction = offset.dx.abs() >= offset.dy.abs()
        ? (offset.dx >= 0 ? MinerDirection.right : MinerDirection.left)
        : (offset.dy >= 0 ? MinerDirection.down : MinerDirection.up);
    setState(() => _knobOffset = offset);
    if (_lastDirection != direction) {
      _lastDirection = direction;
      widget.onMove(direction);
    }
  }

  void _resetKnob() {
    setState(() {
      _knobOffset = Offset.zero;
      _lastDirection = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: _size,
      height: _size,
      child: GestureDetector(
        key: const ValueKey('miner-joystick-knob'),
        onPanStart: (details) => _updateKnob(details.localPosition),
        onPanUpdate: (details) => _updateKnob(details.localPosition),
        onPanEnd: (_) => _resetKnob(),
        onPanCancel: _resetKnob,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(_mineText(context, 'minesweeper.direction', '拖曳方向'),
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ),
            Transform.translate(
              offset: _knobOffset,
              child: Container(
                width: _knobSize,
                height: _knobSize,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.open_with, color: scheme.onPrimary, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlagSubtractionSwitch extends StatelessWidget {
  const _FlagSubtractionSwitch({required this.game, required this.onChanged});
  final MinesweeperGame game;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant)),
        child: Row(children: [
          Expanded(
              child: Text(
                  _mineText(context, 'minesweeper.autoSubtract', '插旗自動扣除數字'),
                  style: TextStyle(
                      color: scheme.onSurface, fontWeight: FontWeight.bold))),
          Switch(
              value: game.autoSubtractFlagged,
              onChanged: onChanged,
              activeThumbColor: scheme.primary)
        ]));
  }
}

class _InfoBar extends StatelessWidget {
  const _InfoBar({required this.game});
  final MinesweeperGame game;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text(_statusText(context),
              style: TextStyle(
                  color: scheme.onSurface, fontWeight: FontWeight.bold)),
          Text(
              '${game.elapsedSeconds ~/ 60}:${(game.elapsedSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                  color: scheme.onSurface, fontWeight: FontWeight.bold))
        ]));
  }

  String _statusText(BuildContext context) => switch (game.status) {
        GameStatus.ready =>
          _mineText(context, 'minesweeper.status.ready', '準備中'),
        GameStatus.playing => game.mode == MinesweeperMode.miner
            ? _mineText(context, 'minesweeper.miner', '礦工模式')
            : '${_mineText(context, 'minesweeper.mines', '雷')} ${game.remainingMines}',
        GameStatus.won => _mineText(context, 'minesweeper.status.won', '挑戰成功'),
        GameStatus.lost =>
          _mineText(context, 'minesweeper.status.lost', '踩到地雷'),
      };
}

String _mineText(BuildContext context, String key, String fallback) =>
    MinesweeperLocalizations(
      GameUiSettingsScope.maybeOf(context)?.locale ?? 'zh-Hant',
    ).text(key, fallback);

String _mineDirectionText(BuildContext context, MinerDirection direction) {
  final key = switch (direction) {
    MinerDirection.up => 'minesweeper.direction.up',
    MinerDirection.down => 'minesweeper.direction.down',
    MinerDirection.left => 'minesweeper.direction.left',
    MinerDirection.right => 'minesweeper.direction.right',
  };
  return _mineText(context, key, direction.name);
}

class _Board extends StatelessWidget {
  const _Board({required this.game, required this.cellSize});
  final MinesweeperGame game;
  final double cellSize;
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
                  width: game.sideLength * cellSize,
                  height: game.sideLength * cellSize,
                  child: Stack(children: [
                    for (var index = 0; index < game.cells.length; index++)
                      Positioned(
                          left: (index % game.sideLength) * cellSize,
                          top: (index ~/ game.sideLength) * cellSize,
                          width: cellSize,
                          height: cellSize,
                          child: _Cell(
                              game: game,
                              index: index,
                              cell: game.cells[index]))
                  ])))));
}

class _Cell extends StatelessWidget {
  const _Cell({required this.game, required this.index, required this.cell});
  final MinesweeperGame game;
  final int index;
  final MinesweeperCell cell;
  @override
  Widget build(BuildContext context) {
    final revealed = cell.state == CellState.revealed;
    return Container(
        decoration: BoxDecoration(
            color: revealed ? const Color(0xfff2e2ac) : const Color(0xff5d806b),
            border: Border.all(color: const Color(0xffd2bd7a), width: 1)),
        alignment: Alignment.center,
        child: game.mode == MinesweeperMode.miner && game.minerIndex == index
            ? Text('${_minerArrow(game.minerFacing)}⛏️',
                style: const TextStyle(fontSize: 15))
            : cell.state == CellState.flagged
                ? const Text('⚑', style: TextStyle(fontSize: 15))
                : revealed &&
                        !cell.isMine &&
                        game.displayedAdjacentMines(index) > 0
                    ? Text('${game.displayedAdjacentMines(index)}',
                        style: const TextStyle(
                            color: Color(0xff3b72a1),
                            fontSize: 14,
                            fontWeight: FontWeight.bold))
                    : revealed && cell.isMine
                        ? const Text('✹',
                            style: TextStyle(
                                color: Color(0xffd46e4c), fontSize: 14))
                        : null);
  }

  String _minerArrow(MinerDirection direction) => switch (direction) {
        MinerDirection.up => '↑',
        MinerDirection.down => '↓',
        MinerDirection.left => '←',
        MinerDirection.right => '→',
      };
}
