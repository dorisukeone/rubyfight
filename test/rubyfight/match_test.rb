require 'minitest/autorun'
require 'rubyfight/match'

class MatchTest < Minitest::Test
  def test_headline_p1
    assert_equal 'P1 WINS!', Rubyfight::Match.result_headline(3, 1, true)
  end

  def test_headline_p2_vs_cpu
    assert_equal 'CPU WINS!', Rubyfight::Match.result_headline(1, 3, true)
  end

  def test_headline_p2_vs_human
    assert_equal 'P2 WINS!', Rubyfight::Match.result_headline(1, 3, false)
  end

  def test_headline_draw
    assert_equal 'DRAW!', Rubyfight::Match.result_headline(2, 2, true)
  end

  def test_tone
    m = Rubyfight::Match
    assert_equal 'p1', m.result_tone(5, 1)
    assert_equal 'p2', m.result_tone(1, 5)
    assert_equal 'tie', m.result_tone(3, 3)
  end
end
