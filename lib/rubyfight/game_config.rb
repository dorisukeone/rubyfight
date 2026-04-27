# ゲーム定数（index.html の CONFIG と同一ソースになるよう維持）
# Opal / MRI 共通で require 可能（Opal 専用構文なし）
module Rubyfight
  module GameConfig
    # JS の CONFIG と同じキー（大文字）で JSON 化しやすくする
    def self.to_browser_hash
      width = 960
      height = 540
      tile = 20
      grid_cols = 32
      grid_rows = 18
      field_w = tile * grid_cols
      field_h = tile * grid_rows
      {
        'WIDTH' => width,
        'HEIGHT' => height,
        'TILE_SIZE' => tile,
        'GRID_COLS' => grid_cols,
        'GRID_ROWS' => grid_rows,
        'PLAYER_SIZE' => 28,
        'BASE_SPEED' => 160,
        'SPEED_UP_MULTIPLIER' => 1.4,
        'CPU_SPEED_MULTIPLIER' => 1.42,
        'PLAYER_VIS_SMOOTH' => 0,
        'COLORS' => {
          'bg' => '#2e0f0f',
          'fieldBg' => '#4a1a1a',
          'p1' => { 'tile' => '#e65c5c', 'player' => '#c44848' },
          'p2' => { 'tile' => '#6ea2e4', 'player' => '#487ec4' },
          'ui' => '#ffdddd',
          'highlight' => '#ffffff',
          'hudGold' => '#f5b042',
          'hudGoldDim' => '#c98a2c'
        },
        'GAME_TIME' => 55,
        'RUSH_TIME' => 15,
        # タイトルから試合開始までのカウント（秒）。1 秒ごとに 5→…→1 表示
        'PREPLAY_COUNTDOWN_SEC' => 5,
        # プレイ中の歩行（左・右で別シート、各 1x4）
        'PLAY_P1_SHEET' => {
          'urlLeft' => 'assets/play/p1_walk_left.png',
          'urlRight' => 'assets/play/p1_walk_right.png',
          'cols' => 4,
          'rows' => 1,
          'frameLayout' => 'row',
          'walkCyclesPerSec' => 10,
          'removeMatte' => true,
          'matteDarkMax' => 40,
          'matteColorMin' => 45
        },
        'PLAY_P2_SHEET' => {
          'url' => 'assets/play/p2_walk.png',
          'cols' => 4,
          'rows' => 1,
          'frameLayout' => 'row',
          'walkCyclesPerSec' => 10,
          'removeEdgeWhite' => true,
          'keyMinRgb' => 248
        },
        'TITLE_PARTS' => {
          'background' => '',
          'logo' => 'assets/title/logo.png',
          'charLeft' => '',
          'charRight' => ''
        },
        'LOGO_REMOVE_EDGE_BLACK' => true,
        'LOGO_KEY_MAX_RGB' => 32,
        # max(r,g,b) <= この値なら透過（周縁 BFS では届かない文字の穴のベタ黒用）。影が欠ける時は下げる / null で無効
        'LOGO_KEY_BY_MAX_CHANNEL' => 24,
        'TITLE_CHAR_RED_SHEET' => {
          'url' => 'assets/title/char_red_sheet.png?v=17',
          # 実寸 1368×80 = 24×57（元 1365 に右 3px: script/pad_char_red_sheet_to_24_cols.rb）
          'cols' => 24,
          'rows' => 1,
          'frameWidth' => 57,
          'frameHeight' => 80,
          'frameLayout' => 'row',
          'fps' => 24,
          'frameStart' => 0,
          'frameCount' => 24,
          'fit' => 'contain',
          'clip' => false,
          'sheetVAlign' => 'bottom',
          # 帯地が近黒（a=255）のベタ地のため max(r,g,b) で一括キー。輪郭が欠ける時は 22〜32 で調整
          'keyByMaxChannel' => 24,
          'removeEdgeBlack' => false,
          'removeMatte' => false,
          'matteDarkMax' => 40,
          'matteColorMin' => 34
        },
        'TITLE_CHAR_BLUE_SHEET' => {
          'url' => 'assets/title/char_blue_sheet.png?v=40',
          'cols' => 24,
          'rows' => 1,
          'frameLayout' => 'row',
          'fps' => 24,
          'frameStart' => 0,
          'frameCount' => 24,
          'fit' => 'contain',
          'clip' => false,
          'sheetVAlign' => 'center',
          'sheetSourceUniformMax' => false,
          'atlasSourceExact' => false,
          'sheetSourceTrimEndX' => 4,
          'keyByMaxChannel' => 32,
          'removeEdgeBlack' => false,
          'removeMatte' => false
        },
        'TITLE_BACKGROUND_URL' => 'assets/title/title_background.png',
        'ASSET_SHEET' => {
          'url' => 'assets/title/asset_sheet.png',
          'sheetW' => 1024,
          'sheetH' => 571,
          'cols' => 3,
          'rows' => 2,
          'gridRect' => { 'x' => 12, 'y' => 54, 'w' => 1000, 'h' => 476 },
          'cellInset' => 2,
          'tileScale' => 0.55,
          'cells' => {
            'logo' => [0, 0],
            'charRed' => [1, 0],
            'charBlue' => [2, 0],
            'backgroundPattern' => [0, 1],
            'fieldGrid' => [1, 1],
            'uiRef' => [2, 1]
          }
        },
        'FIELD_WIDTH' => field_w,
        'FIELD_HEIGHT' => field_h,
        'OFFSET_X' => (width - field_w) / 2,
        'OFFSET_Y' => 110
      }
    end

    def self.field_width
      to_browser_hash['FIELD_WIDTH']
    end

    def self.field_height
      to_browser_hash['FIELD_HEIGHT']
    end
  end
end
