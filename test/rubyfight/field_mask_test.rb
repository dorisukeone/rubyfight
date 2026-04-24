# frozen_string_literal: true

require 'minitest/autorun'
require 'rubyfight/field_mask'

class FieldMaskTest < Minitest::Test
  def test_grid_shape_matches_js
    assert_equal 18, Rubyfight::FieldMask.row_count
    assert_equal 32, Rubyfight::FieldMask.col_count
    assert Rubyfight::FieldMask.rectangular?
  end

  def test_center_playable_corners_blocked
    assert Rubyfight::FieldMask.playable?(5, 16)
    refute Rubyfight::FieldMask.playable?(0, 0)
    refute Rubyfight::FieldMask.playable?(-1, 0)
    refute Rubyfight::FieldMask.playable?(0, 100)
  end

  def test_row_strings_match_width
    Rubyfight::FieldMask::ROWS.each_with_index do |row, i|
      assert_equal 32, row.length, "row #{i} length"
    end
  end
end
