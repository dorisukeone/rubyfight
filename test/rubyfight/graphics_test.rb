require 'minitest/autorun'
require 'rubyfight/game_config'
require 'rubyfight/graphics'

class GraphicsTest < Minitest::Test
  def test_clamp
    g = Rubyfight::Graphics
    assert_equal 2, g.clamp(5, 1, 2)
    assert_equal 1, g.clamp(-3, 1, 2)
    assert_in_delta 1.5, g.clamp(1.5, 0, 3), 1e-9
  end

  def test_blink_even_phase
    g = Rubyfight::Graphics
    assert g.blink_even_phase?(0, 100)
    refute g.blink_even_phase?(100, 100)
    assert g.blink_even_phase?(399, 400)
    refute g.blink_even_phase?(400, 400)
  end

  def test_uniform_sprite_frame
    sx, sy, sw, sh = Rubyfight::Graphics.uniform_sprite_frame_rect(100, 80, 3, 2, 4)
    assert_equal 33, sx
    assert_equal 40, sy
    assert_equal 33, sw
    assert_equal 40, sh
  end

  def test_title_char_frame_wraps
    f = Rubyfight::Graphics.title_char_frame_index(0, 6, 0, 4, 4, 4)
    assert_operator f, :>=, 0
    assert_operator f, :<=, 15
  end

  def test_sprite_fit_scale
    g = Rubyfight::Graphics
    assert_operator g.sprite_fit_scale(10, 10, 100, 50, 'cover'), :>=, 5
    assert_operator g.sprite_fit_scale(10, 10, 100, 50, 'contain'), :<=, 5
    assert_in_delta g.sprite_fit_scale(10, 10, 100, 50, 'contain'),
      g.sprite_fit_scale(10, 10, 100, 50, nil), 1e-9
  end

  def test_clamp_sheet_source
    x, _y, w, _h = Rubyfight::Graphics.clamp_sheet_source(64, 64, -2, 0, 10, 10)
    assert_equal 0, x
    assert_operator w, :<=, 10
  end

  def test_scale_grid_rect
    a = Rubyfight::Graphics.scale_grid_rect_to_image(12, 54, 1000, 476, 1024, 571, 1024, 571)
    assert_equal 4, a.length
    assert_operator a[2], :>, 100
  end

  def test_sheet_cell_rect
    _sx, _sy, sw, sh = Rubyfight::Graphics.sheet_cell_rect(0, 0, 300, 200, 3, 2, 1, 0, 2)
    assert_operator sw, :>, 0
    assert_operator sh, :>, 0
  end

  def test_asset_sheet_cell_pair
    pair = Rubyfight::Graphics.asset_sheet_cell_pair('logo')
    assert_equal [0, 0], pair
  end
end
