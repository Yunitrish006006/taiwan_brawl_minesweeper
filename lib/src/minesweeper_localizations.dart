/// Package-owned player-facing copy for Minesweeper.
class MinesweeperLocalizations {
  const MinesweeperLocalizations(this.locale);

  final String locale;

  String text(String key, String fallback) {
    final normalized = locale.toLowerCase().replaceAll('_', '-');
    final table = normalized == 'en' || normalized.startsWith('en-')
        ? _en
        : normalized == 'ja' || normalized.startsWith('ja-')
            ? _ja
            : _zhHant;
    return table[key] ?? fallback;
  }

  String mineCountLabel(int count) {
    final normalized = locale.toLowerCase().replaceAll('_', '-');
    if (normalized == 'en' || normalized.startsWith('en-')) {
      return '$count mines';
    }
    if (normalized == 'ja' || normalized.startsWith('ja-')) {
      return '$count個の地雷';
    }
    return '$count 顆地雷';
  }
}

const _zhHant = <String, String>{
  'minesweeper.title': '踩地雷',
  'minesweeper.description': '選擇棋盤尺寸，找出所有地雷。',
  'minesweeper.selectBoard': '選擇棋盤尺寸後開始遊戲',
  'minesweeper.gameMode': '遊戲模式',
  'minesweeper.classic': '標準模式',
  'minesweeper.miner': '礦工模式',
  'minesweeper.boardSize': '棋盤尺寸',
  'minesweeper.start': '開始遊戲',
  'minesweeper.minerHint': '中心預挖 · 只能挖掘 · 踩雷爆炸',
  'minesweeper.classicHint': '大棋盤會維持固定格子大小，拖曳即可滑動視角',
  'minesweeper.dig': '挖掘',
  'minesweeper.flag': '插旗',
  'minesweeper.direction': '拖曳方向',
  'minesweeper.autoSubtract': '插旗自動扣除數字',
  'minesweeper.mines': '雷',
  'minesweeper.status.ready': '準備中',
  'minesweeper.status.won': '挑戰成功',
  'minesweeper.status.lost': '踩到地雷',
  'minesweeper.facing': '朝向',
  'minesweeper.direction.up': '上',
  'minesweeper.direction.down': '下',
  'minesweeper.direction.left': '左',
  'minesweeper.direction.right': '右',
  'minesweeper.gestureHint': '拖曳移動視角 · 點擊翻開 · 雙擊插旗',
  'minesweeper.minerGestureHint': '按挖掘／插旗直接作用前方格子 · 只能走已揭開的格子',
  'minesweeper.restart': '重新開始',
  'minesweeper.playAgain': '再玩一次',
  'minesweeper.status.readyShort': '準備',
  'minesweeper.minerShort': '礦工',
  'minesweeper.status.wonShort': '完成',
  'minesweeper.status.lostShort': '失敗',
};

const _en = <String, String>{
  'minesweeper.title': 'Minesweeper',
  'minesweeper.description': 'Choose a board size and find all the mines.',
  'minesweeper.selectBoard': 'Choose a board size to start',
  'minesweeper.gameMode': 'GAME MODE',
  'minesweeper.classic': 'Classic',
  'minesweeper.miner': 'Miner mode',
  'minesweeper.boardSize': 'BOARD SIZE',
  'minesweeper.start': 'Start game',
  'minesweeper.minerHint': 'Pre-dug center · dig only · mines explode',
  'minesweeper.classicHint': 'Large boards keep fixed cell sizes; drag to pan',
  'minesweeper.dig': 'Dig',
  'minesweeper.flag': 'Flag',
  'minesweeper.direction': 'Drag direction',
  'minesweeper.autoSubtract': 'Flags subtract from numbers',
  'minesweeper.mines': 'Mines',
  'minesweeper.status.ready': 'Ready',
  'minesweeper.status.won': 'Complete',
  'minesweeper.status.lost': 'Mine hit',
  'minesweeper.facing': 'Facing',
  'minesweeper.direction.up': 'Up',
  'minesweeper.direction.down': 'Down',
  'minesweeper.direction.left': 'Left',
  'minesweeper.direction.right': 'Right',
  'minesweeper.gestureHint': 'Drag to pan · tap to reveal · double tap to flag',
  'minesweeper.minerGestureHint':
      'Dig or flag the cell ahead · walk only on revealed cells',
  'minesweeper.restart': 'Restart',
  'minesweeper.playAgain': 'Play again',
  'minesweeper.status.readyShort': 'Ready',
  'minesweeper.minerShort': 'Miner',
  'minesweeper.status.wonShort': 'Done',
  'minesweeper.status.lostShort': 'Failed',
};

const _ja = <String, String>{
  'minesweeper.title': 'マインスイーパー',
  'minesweeper.description': '盤面サイズを選んで、すべての地雷を見つけよう。',
  'minesweeper.selectBoard': '盤面サイズを選んで開始',
  'minesweeper.gameMode': 'ゲームモード',
  'minesweeper.classic': 'クラシック',
  'minesweeper.miner': 'マイナーモード',
  'minesweeper.boardSize': '盤面サイズ',
  'minesweeper.start': 'ゲーム開始',
  'minesweeper.minerHint': '中央は開放済み・掘削のみ・地雷で爆発',
  'minesweeper.classicHint': '大きな盤面は固定セルサイズ。ドラッグで移動',
  'minesweeper.dig': '掘削',
  'minesweeper.flag': '旗を置く',
  'minesweeper.direction': 'ドラッグ方向',
  'minesweeper.autoSubtract': '旗を数字から自動減算',
  'minesweeper.mines': '地雷',
  'minesweeper.status.ready': '準備中',
  'minesweeper.status.won': 'クリア',
  'minesweeper.status.lost': '地雷に当たりました',
  'minesweeper.facing': '向き',
  'minesweeper.direction.up': '上',
  'minesweeper.direction.down': '下',
  'minesweeper.direction.left': '左',
  'minesweeper.direction.right': '右',
  'minesweeper.gestureHint': 'ドラッグで移動・タップで開く・ダブルタップで旗',
  'minesweeper.minerGestureHint': '前のセルを掘削／旗設置・開いたセルだけ移動',
  'minesweeper.restart': '再スタート',
  'minesweeper.playAgain': 'もう一度遊ぶ',
  'minesweeper.status.readyShort': '準備',
  'minesweeper.minerShort': 'マイナー',
  'minesweeper.status.wonShort': '完了',
  'minesweeper.status.lostShort': '失敗',
};
