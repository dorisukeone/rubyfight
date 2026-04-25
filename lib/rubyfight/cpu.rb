# CPU：P1 圧力に加え、旗 2 本時は第 3 点で塗れるマス数（大きい三角形）を最優先
require 'rubyfight/game_config'
require 'rubyfight/territory'

module Rubyfight
  module Cpu
    # 隣接 P1 マス 1 つにつき重み（奪取・圧力）
    W_ADJ_P1 = 4.2
    # 隣接空マス
    W_ADJ_0 = 0.75
    # そのマス自身が P1
    W_CELL_P1 = 1.35
    # そのマス自身が空
    W_CELL_0 = 0.55
    # フィールド中心（px）に近いほど
    W_CENTER = 0.65
    # 旗 1 本目から 2 本目：マンハッタン距離を大きく（のちの第 3 点で大きい三角形に）
    W_SPAN = 0.14

    def self.normalize_flag_pairs(cpu_flags)
      return [] if cpu_flags.nil?

      a = cpu_flags
      a = a.to_a if a.respond_to?(:to_a)
      return [] unless a.is_a?(Array)

      a.map do |p|
        if p.is_a?(Array) && p.length >= 2
          [p[0].to_i, p[1].to_i]
        elsif p.respond_to?(:[]) && p['gx']
          [p['gx'].to_i, p['gy'].to_i]
        else
          nil
        end
      end.compact
    end

    def self.heur_score(p1n, p0n, c, cbonus)
      (W_ADJ_P1 * p1n) + (W_ADJ_0 * p0n) + (c == 1 ? W_CELL_P1 : 0) + (c == 0 ? W_CELL_0 : 0) + (W_CENTER * cbonus)
    end

    # cpu_flags: [[gx,gy],...] 0〜2 本（Opal: JS から [ [gx,gy], ... ] ）
    # 旗 2 本時は「塗れるマス数」gain を常に最大に。同点は h（陣取り系）、さらに (gy, gx) で固定
    def self.pick_target_center(grid, mask_rows, cpu_flags = nil, random: Random.new)
      fp = normalize_flag_pairs(cpu_flags)

      tile = Layout.tile_size
      rows = Layout.grid_rows
      cols = Layout.grid_cols
      cfg = GameConfig.to_browser_hash
      fw = cfg['FIELD_WIDTH'].to_f
      fh = cfg['FIELD_HEIGHT'].to_f
      cx0 = fw / 2.0
      cy0 = fh / 2.0
      mxy = [fw, fh].max / 2.0
      mxy = 1.0 if mxy < 1.0

      entries = []
      rows.times do |y|
        cols.times do |x|
          next if mask_rows[y][x] == ' '
          next if grid[y][x] == 2

          cx = x * tile + tile / 2.0
          cy = y * tile + tile / 2.0
          next unless Layout.player_position_valid?(cx, cy, mask_rows)

          c = grid[y][x]
          p1n = 0
          p0n = 0
          [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |dx, dy|
            nx = x + dx
            ny = y + dy
            next if nx < 0 || ny < 0 || nx >= cols || ny >= rows
            next if mask_rows[ny][nx] == ' '

            p1n += 1 if grid[ny][nx] == 1
            p0n += 1 if grid[ny][nx] == 0
          end

          d = Math.hypot(cx - cx0, cy - cy0)
          cbonus = 1.0 - [d / mxy, 1.0].min

          h = heur_score(p1n, p0n, c, cbonus)

          if fp.length == 2
            tri = [fp[0], fp[1], [x, y]]
            gain = Territory.simulated_fill_count(grid, 2, tri, mask_rows)
            entries << { tri: true, pos: [cx, cy], gx: x, gy: y, gain: gain, h: h }
          elsif fp.length == 1
            fx = fp[0][0]
            fy = fp[0][1]
            span = (x - fx).abs + (y - fy).abs
            s = (W_SPAN * span) + 0.9 * h
            entries << { tri: false, pos: [cx, cy], gx: x, gy: y, s: s }
          else
            entries << { tri: false, pos: [cx, cy], gx: x, gy: y, s: h }
          end
        end
      end
      return nil if entries.empty?

      if entries[0][:tri]
        gmax = entries.map { |e| e[:gain] }.max
        t = entries.select { |e| e[:gain] == gmax }
        hmax = t.map { |e| e[:h] }.max
        t = t.select { |e| e[:h] == hmax }
        return t.min_by { |e| [e[:gy], e[:gx]] }[:pos]
      end

      best = entries.map { |e| e[:s] }.max
      t = entries.select { |e| e[:s] == best }
      t.min_by { |e| [e[:gy], e[:gx]] }[:pos]
    end

    def self.wait_after_flag_sec(random: Random.new)
      0.03 + random.rand * 0.07
    end

    def self.wait_after_stuck_sec
      0.1
    end
  end
end
