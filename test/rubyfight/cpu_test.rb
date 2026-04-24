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
end
