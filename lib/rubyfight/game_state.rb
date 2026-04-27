# 画面状態（index.html の state 文字列と同一）
require 'rubyfight/graphics'

module Rubyfight
  module GameState
    TITLE = 'TITLE'
    COUNTDOWN = 'COUNTDOWN'
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

    # リザルト画面「PRESS SPACE…」の点滅（500ms 周期）
    def self.blink_500ms_primary?(now_ms)
      Graphics.blink_even_phase?(now_ms, 500)
    end

    def self.menu_prev_index(index, menu_size)
      (index + menu_size - 1) % menu_size
    end

    def self.menu_next_index(index, menu_size)
      (index + 1) % menu_size
    end

    # タイトルで Space/Enter 時の選択（index.html titleMenuIndex と対応）
    def self.title_confirm_action(menu_index)
      case menu_index
      when 0 then 'vs_cpu'
      when 1 then 'vs_2p'
      end
    end
  end
end
