# ゲーム定数（index.html の CONFIG と同一ソースになるよう維持）
# Opal / MRI 共通で require 可能（Opal 専用構文なし）
module Rubyfight
  module GameConfig
    # JS の CONFIG と同じキー（大文字）で JSON 化しやすくする
    def self.to_browser_hash
      {
        'WIDTH' => 960,
        'HEIGHT' => 540,
        'TILE_SIZE' => 20,
        'GRID_COLS' => 32,
        'GRID_ROWS' => 18,
        'PLAYER_SIZE' => 28,
        'BASE_SPEED' => 160,
        'SPEED_UP_MULTIPLIER' => 1.3,
        'CPU_SPEED_MULTIPLIER' => 1.15,
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
        'GAME_TIME' => 60,
        'RUSH_TIME' => 10,
        'TITLE_PARTS' => {
          'background' => '',
          'logo' => 'assets/title/logo.png',
          'charLeft' => '',
          'charRight' => ''
        },
        'LOGO_REMOVE_EDGE_BLACK' => true,
        'LOGO_KEY_MAX_RGB' => 32,
        'TITLE_CHAR_RED_SHEET' => {
          'url' => 'assets/title/char_red_sheet.png',
          'cols' => 4,
          'rows' => 4,
          'fps' => 6,
          'frameStart' => 0,
          'frameCount' => 16,
          'removeEdgeBlack' => true,
          'keyMaxRgb' => 32
        },
        'TITLE_CHAR_BLUE_SHEET' => {
          'url' => 'assets/title/char_blue_sheet.png',
          'cols' => 4,
          'rows' => 4,
          'fps' => 6,
          'frameStart' => 0,
          'frameCount' => 16,
          'removeEdgeBlack' => false,
          'removeMatte' => true,
          'matteDarkMax' => 40,
          'matteColorMin' => 45,
          'keyMaxRgb' => 32
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
        # レイアウト（JS では CONFIG 外の定数。整合チェック用）
        'OFFSET_Y' => 110
      }
    end

    def self.field_width
      to_browser_hash['TILE_SIZE'] * to_browser_hash['GRID_COLS']
    end

    def self.field_height
      to_browser_hash['TILE_SIZE'] * to_browser_hash['GRID_ROWS']
    end
  end
end
