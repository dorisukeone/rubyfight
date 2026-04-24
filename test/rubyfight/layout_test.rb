require 'minitest/autorun'
require 'rubyfight/game_config'
require 'rubyfight/field_mask'
require 'rubyfight/layout'

class LayoutTest < Minitest::Test
  MASK = Rubyfight::FieldMask::ROWS
  def test_field_metrics_match_js
    h = Rubyfight::GameConfig.to_browser_hash
    assert_equal 640, h['FIELD_WIDTH']
    assert_equal 360, h['FIELD_HEIGHT']
    assert_equal 160, h['OFFSET_X']
    assert_equal 110, h['OFFSET_Y']
  end

  def test_pixel_to_grid
    assert_equal [8, 8], Rubyfight::Layout.pixel_to_grid(170, 170)
    assert_equal [0, 0], Rubyfight::Layout.pixel_to_grid(0, 0)
  end

  def test_grid_to_tile_center_roundtrip
    cx, cy = Rubyfight::Layout.grid_to_tile_center(8, 8)
    gx, gy = Rubyfight::Layout.pixel_to_grid(cx, cy)
    assert_equal [8, 8], [gx, gy]
  end

  def test_in_grid
    assert Rubyfight::Layout.in_grid?(0, 0)
    assert Rubyfight::Layout.in_grid?(31, 17)
    refute Rubyfight::Layout.in_grid?(32, 0)
    refute Rubyfight::Layout.in_grid?(0, 18)
  end

  def test_default_spawn_matches_reset_game
    p1 = Rubyfight::Layout.default_spawn(:p1)
    p2 = Rubyfight::Layout.default_spawn(:p2)
    assert_in_delta 170.0, p1[0], 1e-6
    assert_in_delta 170.0, p1[1], 1e-6
    assert_in_delta 470.0, p2[0], 1e-6
    assert_in_delta 170.0, p2[1], 1e-6
  end

  def test_player_position_valid_on_spawn_center
    cx, cy = Rubyfight::Layout.default_spawn(:p1)
    assert Rubyfight::Layout.player_position_valid?(cx, cy, MASK)
  end

  def test_player_position_invalid_outside_field
    refute Rubyfight::Layout.player_position_valid?(-100, -100, MASK)
  end

  def test_player_position_invalid_in_hole
    hole = nil
    MASK.each_with_index do |row, y|
      row.chars.each_with_index do |ch, x|
        if ch == ' '
          hole = [x, y]
          break
        end
      end
      break if hole
    end
    skip 'mask has no holes' unless hole

    gx, gy = hole
    ts = Rubyfight::Layout.tile_size
    cx = gx * ts + ts / 2.0
    cy = gy * ts + ts / 2.0
    refute Rubyfight::Layout.player_position_valid?(cx, cy, MASK)
  end
end
