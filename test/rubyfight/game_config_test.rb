# frozen_string_literal: true

require 'minitest/autorun'
require 'rubyfight/game_config'

class GameConfigTest < Minitest::Test
  def test_dimensions_match_expected
    h = Rubyfight::GameConfig.to_browser_hash
    assert_equal 960, h['WIDTH']
    assert_equal 540, h['HEIGHT']
    assert_equal 32, h['GRID_COLS']
    assert_equal 18, h['GRID_ROWS']
    assert_equal 20, h['TILE_SIZE']
  end

  def test_field_derived_sizes
    assert_equal 640, Rubyfight::GameConfig.field_width
    assert_equal 360, Rubyfight::GameConfig.field_height
  end

  def test_nested_colors
    h = Rubyfight::GameConfig.to_browser_hash
    assert_equal '#e65c5c', h['COLORS']['p1']['tile']
    assert_equal '#6ea2e4', h['COLORS']['p2']['tile']
  end
end
