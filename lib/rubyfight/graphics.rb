# Canvas 前処理の純粋計算（index.html の clamp / シート / スプライト枠）
require 'rubyfight/game_config'

module Rubyfight
  module Graphics
    def self.clamp(val, min_v, max_v)
      [[val, min_v].max, max_v].min
    end

    def self.blink_even_phase?(now_ms, period_ms)
      return false if period_ms <= 0

      (now_ms.to_f / period_ms).floor % 2 == 0
    end

    def self.asset_sheet_cell_pair(name)
      sheet = GameConfig.to_browser_hash['ASSET_SHEET']
      cells = sheet['cells']
      nm = name.to_s
      c = cells[nm]
      c.nil? ? [0, 0] : c
    end

    # index.html getUniformSpriteFrameRect
    def self.uniform_sprite_frame_rect(img_w, img_h, cols, rows, frame_index)
      col = frame_index % cols
      row = frame_index / cols
      base_w = img_w / cols
      base_h = img_h / rows
      sx = col * base_w
      sy = row * base_h
      sw = col == cols - 1 ? img_w - sx : base_w
      sh = row == rows - 1 ? img_h - sy : base_h
      [sx, sy, sw, sh]
    end

    # drawTitleCharSpriteSheet のフレーム index
    def self.title_char_frame_index(now_ms, fps, frame_start, frame_count, cols, rows)
      total = cols * rows
      tick = (now_ms.to_f / (1000.0 / fps)).floor
      span = [frame_count, 1].max
      raw = frame_start + (tick % span)
      [raw, total - 1].min
    end

    def self.sprite_fit_scale(sw, sh, box_w, box_h, fit)
      if fit.to_s == 'cover'
        [box_w.to_f / sw, box_h.to_f / sh].max
      else
        [box_w.to_f / sw, box_h.to_f / sh].min
      end
    end

    # index.html clampSheetSource（画像内に矩形をクリップ）
    def self.clamp_sheet_source(iw, ih, sx, sy, sw, sh)
      x = sx
      y = sy
      w = sw
      h = sh
      if x < 0
        w += x
        x = 0
      end
      if y < 0
        h += y
        y = 0
      end
      w = iw - x if x + w > iw
      h = ih - y if y + h > ih
      [x, y, [w, 0].max, [h, 0].max]
    end

    # getScaledGridRect
    def self.scale_grid_rect_to_image(gx, gy, gw, gh, img_nat_w, img_nat_h, sheet_w, sheet_h)
      fx = img_nat_w.to_f / sheet_w
      fy = img_nat_h.to_f / sheet_h
      [(gx * fx).round, (gy * fy).round, (gw * fx).round, (gh * fy).round]
    end

    # getSheetCellRect（g はスケール済み gridRect）
    def self.sheet_cell_rect(gx, gy, gw, gh, cols, rows, col, row, cell_inset)
      cw = (gw.to_f / cols).floor
      ch = (gh.to_f / rows).floor
      sx = gx + col * cw
      sy = gy + row * ch
      sw = col == cols - 1 ? gx + gw - sx : cw
      sh = row == rows - 1 ? gy + gh - sy : ch
      ins = cell_inset.to_i
      if ins > 0
        sx += ins
        sy += ins
        sw -= ins * 2
        sh -= ins * 2
      end
      [sx, sy, sw, sh]
    end
  end
end
