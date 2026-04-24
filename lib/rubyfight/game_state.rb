# 画面状態（index.html の state 文字列と同一）
module Rubyfight
  module GameState
    TITLE = 'TITLE'
    PLAYING = 'PLAYING'
    RESULT = 'RESULT'

    COOLDOWN_MS_BEFORE_RESULT_ADVANCE = 2000

    # @return [Array(Float, String or nil)] 新しい残り時間、RESULT へ遷移するなら RESULT 定数
    def self.tick_playing(time_remaining, delta)
      next_remaining = time_remaining - delta
      if next_remaining <= 0
        [0.0, RESULT]
      else
        [next_remaining, nil]
      end
    end

    def self.can_advance_from_result?(now_ms, state_started_ms)
      (now_ms - state_started_ms) > COOLDOWN_MS_BEFORE_RESULT_ADVANCE
    end

    def self.menu_prev_index(index, menu_size)
      (index + menu_size - 1) % menu_size
    end

    def self.menu_next_index(index, menu_size)
      (index + 1) % menu_size
    end
  end
end
