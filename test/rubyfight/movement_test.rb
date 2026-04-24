require 'minitest/autorun'
require 'rubyfight/game_config'
require 'rubyfight/movement'

class MovementTest < Minitest::Test
  def test_speed_normal_vs_rush
    m = Rubyfight::Movement
    c = Rubyfight::GameConfig.to_browser_hash
    rush = c['RUSH_TIME']
    base = c['BASE_SPEED']
    mult = c['SPEED_UP_MULTIPLIER']
    assert_in_delta base, m.speed_for_time_remaining(rush + 1.0), 1e-9
    assert_in_delta base * mult, m.speed_for_time_remaining(rush), 1e-9
  end

  def test_cpu_speed_scales
    m = Rubyfight::Movement
    cpu = Rubyfight::GameConfig.to_browser_hash['CPU_SPEED_MULTIPLIER']
    tr = 100.0
    assert_in_delta m.speed_for_time_remaining(tr) * cpu, m.cpu_speed_for_time_remaining(tr), 1e-9
  end

  def test_cpu_reached_target
    m = Rubyfight::Movement
    assert m.cpu_reached_target?(3.0, 100.0, 0.016)
    refute m.cpu_reached_target?(100.0, 10.0, 0.016)
    assert m.cpu_reached_target?(4.0, 100.0, 0.001)
  end

  def test_nudge_moves_toward_center
    nx, ny = Rubyfight::Movement.nudge_toward_field_center(0.0, 0.0)
    c = Rubyfight::GameConfig.to_browser_hash
    cx = c['FIELD_WIDTH'] / 2.0
    cy = c['FIELD_HEIGHT'] / 2.0
    assert nx > 0.0
    assert ny > 0.0
    assert_operator nx, :<, cx
    assert_operator ny, :<, cy
  end

  def test_rush_hud_blink_only_in_rush_window
    m = Rubyfight::Movement
    rush = Rubyfight::GameConfig.to_browser_hash['RUSH_TIME']
    refute m.rush_hud_blink_primary?(rush + 1.0, 250)
    t = m.rush_hud_blink_primary?(rush - 1.0, 250)
    t2 = m.rush_hud_blink_primary?(rush - 1.0, 350)
    assert_equal t, (250 / 100).floor.even?
    assert_equal t2, (350 / 100).floor.even?
  end
end
