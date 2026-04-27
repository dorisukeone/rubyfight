# frozen_string_literal: true

require 'minitest/autorun'
require 'rubyfight/game_config'

class GameConfigTest < Minitest::Test
  def test_dimensions_match_expected
    h = Rubyfight::GameConfig.to_browser_hash
    assert_equal 960, h['WIDTH']
    assert_equal 540, h['HEIGHT']
    assert_equal 32, h['GRID_COLS']
    assert_equal 18, h['GRID_ROWS']
    assert_equal 20, h['TILE_SIZE']
  end

  def test_field_derived_sizes
    assert_equal 640, Rubyfight::GameConfig.field_width
    assert_equal 360, Rubyfight::GameConfig.field_height
  end

  def test_nested_colors
    h = Rubyfight::GameConfig.to_browser_hash
    assert_equal '#e65c5c', h['COLORS']['p1']['tile']
    assert_equal '#6ea2e4', h['COLORS']['p2']['tile']
  end

  def test_verify_page_config_keys_present
    h = Rubyfight::GameConfig.to_browser_hash
    Rubyfight::GameConfig::VERIFY_PAGE_CONFIG_KEYS.each do |k|
      assert h.key?(k), "to_browser_hash must include #{k} (index.html verifyRubyCoreAligned と同期)"
    end
  end

  def test_deploy_required_paths_exist_in_repo
    root = File.expand_path('../..', __dir__)
    Rubyfight::GameConfig.deploy_required_asset_paths_relative.each do |rel|
      full = File.join(root, rel)
      assert File.file?(full), "deploy-required asset missing: #{rel}"
    end
  end

  def test_verify_page_config_keys_match_index_html
    root = File.expand_path('../..', __dir__)
    path = File.join(root, 'index.html')
    assert File.file?(path), "index.html not found at #{path}"

    html = File.read(path)
    block_m = html.match(
      %r{// BEGIN RUBYFIGHT_VERIFY_PAGE_CONFIG_KEYS\s*([\s\S]*?)\s*// END RUBYFIGHT_VERIFY_PAGE_CONFIG_KEYS}
    )
    assert block_m,
           'index.html must contain // BEGIN/END RUBYFIGHT_VERIFY_PAGE_CONFIG_KEYS around verify keys'

    block = block_m[1]
    assert_match(/GameConfig::VERIFY_PAGE_CONFIG_KEYS/, block)

    m = block.match(/var keys = \[([\s\S]*?)\];/)
    assert m, 'could not find var keys = [ ... ]; inside RUBYFIGHT_VERIFY_PAGE_CONFIG_KEYS block'

    inner = m[1]
    from_html = inner.scan(/['"]([A-Z0-9_]+)['"]/).flatten
    assert_equal Rubyfight::GameConfig::VERIFY_PAGE_CONFIG_KEYS, from_html,
                 'index.html keys[] must equal GameConfig::VERIFY_PAGE_CONFIG_KEYS (same order)'
  end
end
