# CPU：到達可能なマスからタイル中心をランダムに選ぶ（index.html の CPU ターゲット列挙と同一）
module Rubyfight
  module Cpu
    def self.pick_target_center(grid, mask_rows, random: Random.new)
      tile = Layout.tile_size
      rows = Layout.grid_rows
      cols = Layout.grid_cols
      candidates = []
      rows.times do |y|
        cols.times do |x|
          next if mask_rows[y][x] == ' '
          next if grid[y][x] == 2

          cx = x * tile + tile / 2.0
          cy = y * tile + tile / 2.0
          next unless Layout.player_position_valid?(cx, cy, mask_rows)

          candidates << [cx, cy]
        end
      end
      return nil if candidates.empty?

      candidates[random.rand(candidates.length)]
    end
  end
end
