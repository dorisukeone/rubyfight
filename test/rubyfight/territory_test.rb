require 'minitest/autorun'
require 'rubyfight/game_config'
require 'rubyfight/field_mask'
require 'rubyfight/territory'

class TerritoryTest < Minitest::Test
  MASK = Rubyfight::FieldMask::ROWS
  ROWS = Rubyfight::GameConfig.to_browser_hash['GRID_ROWS']
  COLS = Rubyfight::GameConfig.to_browser_hash['GRID_COLS']

  def test_point_in_triangle_center_of_right_triangle
    assert Rubyfight::Territory.point_in_triangle?(1, 1, 0, 0, 2, 0, 0, 2)
    refute Rubyfight::Territory.point_in_triangle?(3, 3, 0, 0, 2, 0, 0, 2)
  end

  def test_degenerate_triangle_only_vertices
    assert Rubyfight::Territory.point_in_triangle?(0, 0, 0, 0, 1, 1, 2, 2)
    refute Rubyfight::Territory.point_in_triangle?(1, 0, 0, 0, 1, 1, 2, 2)
  end

  def test_calc_scores_empty
    g = Rubyfight::Territory.empty_grid(ROWS, COLS)
    s1, s2 = Rubyfight::Territory.calc_scores(g, MASK)
    assert_equal 0, s1
    assert_equal 0, s2
  end

  def test_calc_scores_tolerates_nil_mask_row
    g = Rubyfight::Territory.empty_grid(ROWS, COLS)
    sparse = MASK.dup
    sparse[5] = nil
    s1, s2 = Rubyfight::Territory.calc_scores(g, sparse)
    assert s1.is_a?(Integer)
    assert s2.is_a?(Integer)
  end

  # マスク付きフィールドでの塗りセル数（アルゴリズム退行検知用の固定値）。
  # 三角形 [[10,8],[12,8],[11,10]] の大部分はルビー型 FIELD_MASK の外側のため
  # 実際に塗れるのはマスク内の数マスだけとなり、現状の幾何では 5 セルになる。
  REF_MASKED_TRI_FILL_COUNT = 5

  def test_fill_triangle_changes_ownership_and_score
    g = Rubyfight::Territory.empty_grid(ROWS, COLS)
    tri = [[10, 8], [12, 8], [11, 10]]
    filled = Rubyfight::Territory.fill_triangle!(g, 1, tri, MASK)
    assert_equal REF_MASKED_TRI_FILL_COUNT, filled
    s1, s2 = Rubyfight::Territory.calc_scores(g, MASK)
    assert_equal s1, filled
    assert_equal 0, s2
  end

  def test_push_flag_duplicate_returns_nil
    f = [[1, 1], [2, 2]]
    assert_nil Rubyfight::Territory.push_flag(f, 1, 1)
  end

  def test_push_flag_third_returns_three
    f = Rubyfight::Territory.push_flag([[1, 1]], 2, 2)
    f2 = Rubyfight::Territory.push_flag(f, 3, 3)
    assert_equal 3, f2.length
  end

  def test_p2_overpaint_reduces_p1_score_cells
    g = Rubyfight::Territory.empty_grid(ROWS, COLS)
    tri = [[10, 8], [12, 8], [11, 10]]
    Rubyfight::Territory.fill_triangle!(g, 1, tri, MASK)
    before1, = Rubyfight::Territory.calc_scores(g, MASK)
    Rubyfight::Territory.fill_triangle!(g, 2, tri, MASK)
    after1, after2 = Rubyfight::Territory.calc_scores(g, MASK)
    assert after1 < before1
    assert_equal before1, after2
  end
end
