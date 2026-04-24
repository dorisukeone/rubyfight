require 'minitest/autorun'
require 'rubyfight/game_state'

class GameStateTest < Minitest::Test
  def test_tick_playing_counts_down
    tr, ev = Rubyfight::GameState.tick_playing(10.0, 3.0)
    assert_in_delta 7.0, tr, 1e-9
    assert_nil ev
  end

  def test_tick_playing_hits_result
    tr, ev = Rubyfight::GameState.tick_playing(1.0, 2.0)
    assert_in_delta 0.0, tr, 1e-9
    assert_equal Rubyfight::GameState::RESULT, ev
  end

  def test_can_advance_from_result_after_cooldown
    gs = Rubyfight::GameState
    refute gs.can_advance_from_result?(2500, 600)
    assert gs.can_advance_from_result?(2601, 600)
  end

  def test_menu_wrap
    gs = Rubyfight::GameState
    assert_equal 3, gs.menu_prev_index(0, 4)
    assert_equal 0, gs.menu_next_index(3, 4)
    assert_equal 1, gs.menu_next_index(0, 4)
  end
end
