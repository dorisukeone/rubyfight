require 'minitest/autorun'
require 'rubyfight/game_config'
require 'rubyfight/territory'
require 'rubyfight/session'

class SessionTest < Minitest::Test
  ROWS = Rubyfight::GameConfig.to_browser_hash['GRID_ROWS']
  COLS = Rubyfight::GameConfig.to_browser_hash['GRID_COLS']

  def test_initial_time_matches_config
    exp = Rubyfight::GameConfig.to_browser_hash['GAME_TIME']
    assert_equal exp, Rubyfight::Session.initial_time_remaining
  end

  def test_spawns_match_layout
    assert_equal Rubyfight::Layout.default_spawn(:p1), Rubyfight::Session.p1_spawn_xy
    assert_equal Rubyfight::Layout.default_spawn(:p2), Rubyfight::Session.p2_spawn_xy
  end

  def test_empty_grid_dimensions_match_territory
    g = Rubyfight::Territory.empty_grid(ROWS, COLS)
    assert_equal ROWS, g.length
    assert_equal COLS, g[0].length
  end

  def test_ruby_empty_grid_pair
    a, b = Rubyfight::Session.ruby_empty_grid_pair
    assert_equal ROWS, a.length
    assert_equal 0, a[0][0]
    refute_same a, b
  end
end
