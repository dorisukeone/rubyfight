require 'minitest/autorun'
require 'rubyfight/ui_layout'

class UiLayoutTest < Minitest::Test
  def test_title_shape
    h = Rubyfight::UiLayout.to_browser_hash
    t = h['title']
    assert_equal 480, t['logoCenterX']
    assert_equal 292, t['menu']['y']
    assert_equal 'contain', t['parts']['logo']['fit']
  end
end
