import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:user_ui_settings/user_ui_settings.dart';

import 'minesweeper_game.dart';
import 'minesweeper_localizations.dart';

// Flutter 3.50 release builds can jump to an unresolved deferred closure
// from State.setState. Schedule the same rebuild after synchronous mutations.
mixin _DeferredGameState<T extends StatefulWidget> on State<T> {
  void rebuildAfterMutation() {
    if (mounted) (context as Element).markNeedsBuild();
  }
}

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

class _MinesweeperHomeState extends State<MinesweeperHome>
    with _DeferredGameState<MinesweeperHome> {
  BoardSize _selected = BoardSize.nine;
  MinesweeperMode _mode = MinesweeperMode.classic;
  MinesweeperGame? _game;

  void _selectSize(BoardSize value) {
    _selected = value;
    rebuildAfterMutation();
  }

  void _selectMode(MinesweeperMode value) {
    _mode = value;
    rebuildAfterMutation();
  }

  void _startGame() {
    _game = MinesweeperGame(selectedSize: _selected, mode: _mode)..start();
    rebuildAfterMutation();
  }

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
                onSelected: _selectSize,
                mode: _mode,
                onModeSelected: _selectMode,
                onStart: _startGame)
            : _GameView(game: game, onRestart: _startGame),
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

class _GameViewState extends State<_GameView>
    with _DeferredGameState<_GameView> {
  static const dragSlop = 12.0;
  Timer? _timer;
  bool _moved = false;
  int _doubleTapIndex = 0;
  bool _initialViewportCentered = false;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.game.status == GameStatus.playing) {
        widget.game.elapsedSeconds++;
        rebuildAfterMutation();
      }
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
    final minerMode = widget.game.mode == MinesweeperMode.miner;
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
          if (!minerMode)
            _FlagSubtractionSwitch(
                game: widget.game,
                onChanged: (value) {
                  widget.game.autoSubtractFlagged = value;
                  rebuildAfterMutation();
                }),
          if (minerMode) ...[
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final viewport = constraints.maxWidth;
            final cellSize = viewport / 9;
            if (!minerMode && !_initialViewportCentered) {
              widget.game
                  .centerViewport(viewportSize: viewport, cellSize: cellSize);
              _initialViewportCentered = true;
            }
            final minerIndex = widget.game.minerIndex;
            final cameraOffset = minerIndex == null
                ? Offset(widget.game.viewportX, widget.game.viewportY)
                : Offset(
                    (minerIndex % widget.game.sideLength + 0.5) * cellSize -
                        viewport / 2,
                    (minerIndex ~/ widget.game.sideLength + 0.5) * cellSize -
                        viewport / 2,
                  );
            final animateCamera = minerMode &&
                !(GameUiSettingsScope.maybeOf(context)?.disableAnimations ??
                    false) &&
                !MediaQuery.disableAnimationsOf(context);
            final viewportWidget = ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox.square(
                dimension: viewport,
                child: ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _Board(
                        key: ObjectKey(widget.game),
                        game: widget.game,
                        cellSize: cellSize,
                        cameraOffset: cameraOffset,
                        animateCamera: animateCamera,
                      ),
                      if (minerIndex != null)
                        Center(
                          child: Text(
                            '${widget.game.minerFacing.arrow}⛏️',
                            key: const ValueKey('miner-player'),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
            const boardKey = ValueKey('minesweeper-board');
            if (minerMode) {
              return KeyedSubtree(key: boardKey, child: viewportWidget);
            }
            return GestureDetector(
              key: boardKey,
              onTapUp: (details) {
                final index = _cellAt(details.localPosition, cellSize);
                widget.game.reveal(index);
                rebuildAfterMutation();
              },
              onDoubleTapDown: (details) {
                _doubleTapIndex = _cellAt(details.localPosition, cellSize);
              },
              onDoubleTap: () {
                widget.game.toggleFlag(_doubleTapIndex);
                rebuildAfterMutation();
              },
              onPanStart: (_) {
                _moved = false;
              },
              onPanUpdate: (details) {
                if (details.delta.distance > dragSlop) _moved = true;
                if (_moved) {
                  widget.game.panBy(details.delta.dx, details.delta.dy,
                      viewportSize: viewport, cellSize: cellSize);
                  rebuildAfterMutation();
                }
              },
              child: viewportWidget,
            );
          }),
          if (minerMode) ...[
            const SizedBox(height: 12),
            _MinerMovementControls(
              key: ObjectKey(widget.game),
              enabled: widget.game.status == GameStatus.playing,
              onMove: (direction) {
                final turned = widget.game.minerFacing != direction;
                if (widget.game.moveMiner(direction) || turned)
                  rebuildAfterMutation();
              },
              onDig: () {
                widget.game.digMinerFacing();
                rebuildAfterMutation();
              },
              onFlag: () {
                widget.game.flagMinerFacing();
                rebuildAfterMutation();
              },
            ),
          ],
          const SizedBox(height: 18),
          Text(
              minerMode
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
    super.key,
    required this.enabled,
    required this.onMove,
    required this.onDig,
    required this.onFlag,
  });

  final bool enabled;
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
        _MinerJoystick(enabled: enabled, onMove: onMove),
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
  const _MinerJoystick({required this.enabled, required this.onMove});

  final bool enabled;
  final ValueChanged<MinerDirection> onMove;

  @override
  State<_MinerJoystick> createState() => _MinerJoystickState();
}

class _MinerJoystickState extends State<_MinerJoystick>
    with _DeferredGameState<_MinerJoystick> {
  static const _size = 150.0;
  static const _knobSize = 48.0;
  static const _maxTravel = 43.0;
  static const _engageDistance = 9.0;
  static const _releaseDistance = 6.0;
  static const _sectorWidth = math.pi / 4;
  static const _turnMargin = math.pi / 36;
  static const _clockwiseDirections = [
    MinerDirection.right,
    MinerDirection.downRight,
    MinerDirection.down,
    MinerDirection.downLeft,
    MinerDirection.left,
    MinerDirection.upLeft,
    MinerDirection.up,
    MinerDirection.upRight,
  ];
  static const _slowRepeatMs = 280;
  static const _fastRepeatMs = 110;
  late final AppLifecycleListener _lifecycle;
  Offset _knobOffset = Offset.zero;
  int? _pointer;
  MinerDirection? _direction;
  Timer? _repeat;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onInactive: _release);
  }

  @override
  void didUpdateWidget(covariant _MinerJoystick oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _clearInput();
  }

  @override
  void dispose() {
    _repeat?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  void _pointerDown(PointerDownEvent event) {
    if (!widget.enabled || _pointer != null) return;
    _pointer = event.pointer;
    _updateKnob(event.localPosition);
  }

  void _pointerMove(PointerMoveEvent event) {
    if (event.pointer == _pointer) _updateKnob(event.localPosition);
  }

  void _pointerEnd(PointerEvent event) {
    if (event.pointer == _pointer) _release();
  }

  void _updateKnob(Offset localPosition) {
    final delta = localPosition - const Offset(_size / 2, _size / 2);
    final distance = delta.distance;
    final offset =
        distance > _maxTravel ? delta * (_maxTravel / distance) : delta;
    final threshold = _direction == null ? _engageDistance : _releaseDistance;
    final direction = distance < threshold ? null : _directionFor(delta);
    _knobOffset = offset;
    rebuildAfterMutation();
    if (_direction == direction) return;
    _repeat?.cancel();
    _direction = direction;
    _step();
  }

  MinerDirection _directionFor(Offset delta) {
    final angle = math.atan2(delta.dy, delta.dx);
    final current = _direction;
    if (current != null) {
      final center = _clockwiseDirections.indexOf(current) * _sectorWidth;
      final difference =
          (angle - center + 3 * math.pi) % (2 * math.pi) - math.pi;
      if (difference.abs() <= _sectorWidth / 2 + _turnMargin) return current;
    }
    final sector = (angle / _sectorWidth).round();
    return _clockwiseDirections[sector % _clockwiseDirections.length];
  }

  void _step() {
    final direction = _direction;
    if (direction == null || !widget.enabled) return;
    widget.onMove(direction);
    final strength = ((_knobOffset.distance - _engageDistance) /
            (_maxTravel - _engageDistance))
        .clamp(0.0, 1.0);
    final delay = _slowRepeatMs - (_slowRepeatMs - _fastRepeatMs) * strength;
    // A diagonal tile is farther away, so keep the same travel speed.
    final stepDelay = direction.isDiagonal ? delay * math.sqrt2 : delay;
    _repeat = Timer(Duration(milliseconds: stepDelay.round()), _step);
  }

  void _clearInput() {
    _repeat?.cancel();
    _repeat = null;
    _pointer = null;
    _direction = null;
    _knobOffset = Offset.zero;
  }

  void _release() {
    if (_pointer != null) {
      _clearInput();
      rebuildAfterMutation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: _size,
      height: _size,
      child: Listener(
        key: const ValueKey('miner-joystick-knob'),
        behavior: HitTestBehavior.opaque,
        onPointerDown: _pointerDown,
        onPointerMove: _pointerMove,
        onPointerUp: _pointerEnd,
        onPointerCancel: _pointerEnd,
        child: RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          // The surrounding page can scroll, but a drag that begins on the
          // stick belongs to the stick until that finger is lifted.
          gestures: {
            EagerGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
              EagerGestureRecognizer.new,
              (_) {},
            ),
          },
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
                  child:
                      Icon(Icons.open_with, color: scheme.onPrimary, size: 22),
                ),
              ),
            ],
          ),
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

String _mineDirectionText(BuildContext context, MinerDirection direction) =>
    _mineText(
        context, 'minesweeper.direction.${direction.name}', direction.label);

class _Board extends StatelessWidget {
  const _Board({
    super.key,
    required this.game,
    required this.cellSize,
    required this.cameraOffset,
    required this.animateCamera,
  });
  final MinesweeperGame game;
  final double cellSize;
  final Offset cameraOffset;
  final bool animateCamera;

  @override
  Widget build(BuildContext context) {
    final grid = SizedBox.square(
      dimension: game.sideLength * cellSize,
      child: Stack(children: [
        for (var index = 0; index < game.cells.length; index++)
          Positioned(
            left: (index % game.sideLength) * cellSize,
            top: (index ~/ game.sideLength) * cellSize,
            width: cellSize,
            height: cellSize,
            child: _Cell(game: game, index: index, cell: game.cells[index]),
          ),
      ]),
    );
    return OverflowBox(
      alignment: Alignment.topLeft,
      minWidth: 0,
      maxWidth: double.infinity,
      minHeight: 0,
      maxHeight: double.infinity,
      child: animateCamera
          ? TweenAnimationBuilder<Offset>(
              tween: Tween(begin: -cameraOffset, end: -cameraOffset),
              duration: const Duration(milliseconds: 95),
              curve: Curves.easeOut,
              child: grid,
              builder: (context, offset, child) =>
                  Transform.translate(offset: offset, child: child),
            )
          : Transform.translate(offset: -cameraOffset, child: grid),
    );
  }
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
        child: cell.state == CellState.flagged
            ? const Text('⚑', style: TextStyle(fontSize: 15))
            : revealed && !cell.isMine && game.displayedAdjacentMines(index) > 0
                ? Text('${game.displayedAdjacentMines(index)}',
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
