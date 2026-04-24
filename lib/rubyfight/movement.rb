# プレイヤー / CPU の移動速度と HUD 用ヘルパ（GameConfig 由来）
module Rubyfight
  module Movement
    ARRIVAL_EPSILON_PX = 5.0
    NUDGE_CENTER_FACTOR = 0.05

    def self.speed_for_time_remaining(time_remaining)
      c = GameConfig.to_browser_hash
      rush = c['RUSH_TIME'].to_f
      base = c['BASE_SPEED'].to_f
      mult = c['SPEED_UP_MULTIPLIER'].to_f
      time_remaining <= rush ? base * mult : base
    end

    def self.cpu_speed_for_time_remaining(time_remaining)
      cpu_mult = GameConfig.to_browser_hash['CPU_SPEED_MULTIPLIER'].to_f
      speed_for_time_remaining(time_remaining) * cpu_mult
    end

    # index.html CPU: dist < cpuSpeed * dt || dist < 5
    def self.cpu_reached_target?(dist, cpu_speed, delta, epsilon: ARRIVAL_EPSILON_PX)
      dist < cpu_speed * delta || dist < epsilon
    end

    def self.nudge_toward_field_center(px, py, factor: NUDGE_CENTER_FACTOR)
      c = GameConfig.to_browser_hash
      fw = c['FIELD_WIDTH'].to_f
      fh = c['FIELD_HEIGHT'].to_f
      cx = fw / 2.0
      cy = fh / 2.0
      [px + (cx - px) * factor, py + (cy - py) * factor]
    end

    # 残り時間が RUSH 以下のとき 100ms 周期で交互（タイマー色）
    def self.rush_hud_blink_primary?(time_remaining, now_ms)
      c = GameConfig.to_browser_hash
      return false if time_remaining > c['RUSH_TIME'].to_f

      (now_ms / 100).floor % 2 == 0
    end
  end
end
