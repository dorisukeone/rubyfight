# フィールド座標（フィールドローカル px / グリッド gx,gy）。Canvas の OFFSET は描画側。
module Rubyfight
  module Layout
    P1_SPAWN_GRID = [8, 8].freeze
    P2_SPAWN_GRID = [23, 8].freeze

    def self.cfg
      GameConfig.to_browser_hash
    end

    def self.tile_size
      cfg['TILE_SIZE']
    end

    def self.grid_cols
      cfg['GRID_COLS']
    end

    def self.grid_rows
      cfg['GRID_ROWS']
    end

    # JS: Math.floor(px / TILE_SIZE)
    def self.pixel_to_grid(px, py)
      ts = tile_size
      [(px.to_f / ts).floor, (py.to_f / ts).floor]
    end

    # タイル中心のフィールドローカル座標（JS と同じ式）
    def self.grid_to_tile_center(gx, gy)
      ts = tile_size
      [gx * ts + ts / 2.0, gy * ts + ts / 2.0]
    end

    def self.in_grid?(gx, gy)
      gx >= 0 && gx < grid_cols && gy >= 0 && gy < grid_rows
    end

    # index.html isValidPosition と同一（プレイヤー四角の 4 頂点がマスク内）
    def self.player_position_valid?(px, py, mask_rows)
      c = cfg
      tile = c['TILE_SIZE'].to_i
      cols = c['GRID_COLS'].to_i
      rows = c['GRID_ROWS'].to_i
      player_size = c['PLAYER_SIZE'].to_i
      rad = (player_size / 2) - 2
      corners = [
        [px - rad, py - rad],
        [px + rad, py - rad],
        [px - rad, py + rad],
        [px + rad, py + rad]
      ]
      corners.all? do |cx, cy|
        gx = (cx.to_f / tile).floor
        gy = (cy.to_f / tile).floor
        next false if gx < 0 || gx >= cols || gy < 0 || gy >= rows
        next false if mask_rows[gy].nil? || mask_rows[gy][gx] == ' '

        true
      end
    end

    def self.default_spawn(which)
      gx, gy = which == :p1 ? P1_SPAWN_GRID : P2_SPAWN_GRID
      grid_to_tile_center(gx, gy)
    end
  end
end
