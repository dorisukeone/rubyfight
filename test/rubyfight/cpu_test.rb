require 'minitest/autorun'
require 'rubyfight/game_config'
require 'rubyfight/field_mask'
require 'rubyfight/territory'
require 'rubyfight/cpu'

class CpuTest < Minitest::Test
  MASK = Rubyfight::FieldMask::ROWS
  ROWS = Rubyfight::GameConfig.to_browser_hash['GRID_ROWS']
  COLS = Rubyfight::GameConfig.to_browser_hash['GRID_COLS']

  def test_pick_returns_tile_center_on_empty_grid
    g = Rubyfight::Territory.empty_grid(ROWS, COLS)
    pt = Rubyfight::Cpu.pick_target_center(g, MASK)
    assert pt
    cx, cy = pt
    ts = Rubyfight::Layout.tile_size
    assert_equal 0, ((cx - ts / 2.0) % ts).round(6)
    assert_equal 0, ((cy - ts / 2.0) % ts).round(6)
  end

  def test_pick_nil_when_cpu_has_nowhere_to_go
    g = Array.new(ROWS) { Array.new(COLS, 2) }
    assert_nil Rubyfight::Cpu.pick_target_center(g, MASK)
  end

  def test_pick_deterministic_with_same_rng
    g = Rubyfight::Territory.empty_grid(ROWS, COLS)
    r = Random.new(12345)
    a = Rubyfight::Cpu.pick_target_center(g, MASK, random: r)
    b = Rubyfight::Cpu.pick_target_center(g, MASK, random: Random.new(12345))
    assert_equal a, b
  end

  def test_wait_after_flag_in_range
    r = Random.new(1)
    20.times do
      w = Rubyfight::Cpu.wait_after_flag_sec(random: r)
      assert_operator w, :>=, 0.1
      assert_operator w, :<, 0.3
    end
  end

  def test_wait_after_stuck
    assert_in_delta 0.3, Rubyfight::Cpu.wait_after_stuck_sec, 1e-9
  end
end
