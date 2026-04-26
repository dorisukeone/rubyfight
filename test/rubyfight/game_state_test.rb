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

  def test_blink_500ms
    gs = Rubyfight::GameState
    assert_equal gs.blink_500ms_primary?(0), true
    assert_equal gs.blink_500ms_primary?(499), true
    assert_equal gs.blink_500ms_primary?(500), false
  end

  def test_menu_wrap
    gs = Rubyfight::GameState
    assert_equal 1, gs.menu_prev_index(0, 2)
    assert_equal 0, gs.menu_next_index(1, 2)
    assert_equal 1, gs.menu_next_index(0, 2)
  end

  def test_title_confirm_action
    gs = Rubyfight::GameState
    assert_equal 'vs_cpu', gs.title_confirm_action(0)
    assert_equal 'vs_2p', gs.title_confirm_action(1)
    assert_nil gs.title_confirm_action(2)
    assert_nil gs.title_confirm_action(99)
  end
end
