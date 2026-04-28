# 1 試合開始時の初期状態（index.html startGame と同一数値・形）
require 'rubyfight/territory'

module Rubyfight
  module Session
    def self.initial_time_remaining
      GameConfig.to_browser_hash['GAME_TIME'].to_f
    end

    def self.p1_spawn_xy
      Layout.default_spawn(:p1)
    end

    def self.p2_spawn_xy
      Layout.default_spawn(:p2)
    end

    # 空グリッド 2 枚の正本。ブラウザは main.rb sessionBootstrapGrids が本メソッドを呼び Opal 配列を JS に写す。
    def self.ruby_empty_grid_pair
      rows = Layout.grid_rows
      cols = Layout.grid_cols
      a = Territory.empty_grid(rows, cols)
      b = Territory.empty_grid(rows, cols)
      [a, b]
    end
  end
end
