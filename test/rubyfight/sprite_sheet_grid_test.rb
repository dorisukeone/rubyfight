# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../script/sprite_sheet_grid'

class SpriteSheetGridTest < Minitest::Test
  def test_cell_axis_sums_to_total
    starts, sizes = SpriteSheetGrid.cell_axis_starts_and_sizes(1024, 24)
    assert_equal 1024, sizes.sum
    assert_equal 0, starts[0]
    assert_equal 1024, starts[-1] + sizes[-1]
  end

  def test_next_even
    assert_equal 4, SpriteSheetGrid.next_even(3)
    assert_equal 4, SpriteSheetGrid.next_even(4)
  end
end
