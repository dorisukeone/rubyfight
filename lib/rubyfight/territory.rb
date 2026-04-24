# 領土：三角形内塗り・スコア（index.html の fillPolygon / calcScore と同じアルゴリズム）
module Rubyfight
  module Territory
    # 空グリッド（行=gy, 列=gx）— JS の grid[y][x] と同じ向き
    def self.empty_grid(rows, cols)
      Array.new(rows) { Array.new(cols, 0) }
    end

    # JS isPointInTriangle と同一（バリセントリック + eps = -0.01）
    def self.point_in_triangle?(px, py, x0, y0, x1, y1, x2, y2)
      d = (y1 - y2) * (x0 - x2) + (x2 - x1) * (y0 - y2)
      if d == 0
        return (px == x0 && py == y0) || (px == x1 && py == y1) || (px == x2 && py == y2)
      end
      d = d.to_f
      a = ((y1 - y2) * (px - x2) + (x2 - x1) * (py - y2)) / d
      b = ((y2 - y0) * (px - x2) + (x0 - x2) * (py - y2)) / d
      c = 1.0 - a - b
      eps = -0.01
      a >= eps && b >= eps && c >= eps
    end

    # flags: [[gx0, gy0], [gx1, gy1], [gx2, gy2]]（ちょうど 3 点）
    # grid を破壊的に更新し、新規に塗ったセル数を返す（JS fillPolygon の filledCount）
    def self.fill_triangle!(grid, player_id, flags, mask_rows)
      return 0 if flags.length != 3

      p0, p1, p2 = flags
      x0, y0 = p0
      x1, y1 = p1
      x2, y2 = p2
      min_x = [x0, x1, x2].min
      max_x = [x0, x1, x2].max
      min_y = [y0, y1, y2].min
      max_y = [y0, y1, y2].max

      filled = 0
      (min_y..max_y).each do |y|
        (min_x..max_x).each do |x|
          next if mask_rows[y].nil? || mask_rows[y][x] == ' '
          next unless point_in_triangle?(x, y, x0, y0, x1, y1, x2, y2)

          if grid[y][x] != player_id
            grid[y][x] = player_id
            filled += 1
          end
        end
      end
      filled
    end

    # JS calcScore と同一（マスク外は数えない）
    def self.calc_scores(grid, mask_rows)
      p1 = 0
      p2 = 0
      grid.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          next if mask_rows[y][x] == ' '

          p1 += 1 if cell == 1
          p2 += 1 if cell == 2
        end
      end
      [p1, p2]
    end

    # 旗を足す。同一マスは nil（無視）。[[gx,gy],...] を返す
    def self.push_flag(flags, gx, gy)
      return nil if flags.any? { |fx, fy| fx == gx && fy == gy }

      flags + [[gx, gy]]
    end
  end
end
