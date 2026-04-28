# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'fallback_html_extract'
require 'rubyfight/game_config'

# index.html の FALLBACK_CONFIG が Ruby 正本とずれないよう検証
# （RUBYFIGHT_SYNCED=false 時のみページがこれを使う）
class FallbackConfigParityTest < Minitest::Test
  ROOT = File.expand_path('../..', __dir__)

  NESTED_KEYS_FOR_STRINGS = %w[
    COLORS TITLE_PARTS PLAY_P1_SHEET PLAY_P2_SHEET
    TITLE_CHAR_RED_SHEET TITLE_CHAR_BLUE_SHEET ASSET_SHEET
  ].freeze

  def setup
    path = File.join(ROOT, 'index.html')
    @html = File.read(path)
    @fallback = RubyfightTest::FallbackHtmlExtract.interior_config_object(@html)
  end

  def test_scalars_match_game_config
    h = Rubyfight::GameConfig.to_browser_hash
    keys = %w[
      WIDTH HEIGHT TILE_SIZE GRID_COLS GRID_ROWS
      PLAYER_SIZE BASE_SPEED SPEED_UP_MULTIPLIER CPU_SPEED_MULTIPLIER PLAYER_VIS_SMOOTH
      GAME_TIME RUSH_TIME PREPLAY_COUNTDOWN_SEC
      LOGO_KEY_MAX_RGB LOGO_KEY_BY_MAX_CHANNEL LOGO_REMOVE_EDGE_BLACK
      TITLE_BACKGROUND_URL TITLE_SCREEN_BACKGROUND_URL PLAY_SCREEN_BACKGROUND_URL
    ]
    keys.each do |k|
      expected = h[k]
      assert fallback_line_matches?(@fallback, k, expected),
             "FALLBACK_CONFIG #{k} must match GameConfig (#{expected.inspect})"
    end
  end

  def test_nested_string_values_from_game_config
    h = Rubyfight::GameConfig.to_browser_hash
    strings = []
    NESTED_KEYS_FOR_STRINGS.each do |k|
      collect_strings(h[k], strings)
    end
    strings.uniq.each do |s|
      next if s.empty?
      # 短い識別子は誤検知しやすいので、パス・16進色・ある程度の長さだけ
      next if s.length < 8 && !s.start_with?('#') && !s.start_with?('assets/')

      assert_includes @fallback, s, "FALLBACK_CONFIG must include #{s.inspect}"
    end
  end

  def test_common_js_literal_strings
    fb = @fallback
    assert_match(/fit:\s*['"]contain['"]/, fb)
    assert_match(/frameLayout:\s*['"]row['"]/, fb)
  end

  def test_title_char_and_asset_numeric_scalars
    h = Rubyfight::GameConfig.to_browser_hash
    fb = @fallback
    %w[TITLE_CHAR_RED_SHEET TITLE_CHAR_BLUE_SHEET].each do |name|
      sh = h[name]
      assert_match(/\bcols:\s*#{sh['cols']}\b/, fb)
      assert_match(/\bfps:\s*#{sh['fps']}\b/, fb)
      assert_match(/\bframeWidth:\s*#{sh['frameWidth']}\b/, fb)
      assert_match(/\bframeCount:\s*#{sh['frameCount']}\b/, fb)
      assert_match(/\bkeyByMaxChannel:\s*#{sh['keyByMaxChannel']}\b/, fb)
    end
    ash = h['ASSET_SHEET']
    assert_match(/\bsheetW:\s*#{ash['sheetW']}\b/, fb)
    assert_match(/\bsheetH:\s*#{ash['sheetH']}\b/, fb)
    assert_match(/\btileScale:\s*#{ash['tileScale']}\b/, fb)
  end

  def collect_strings(val, acc)
    case val
    when Hash then val.each_value { |v| collect_strings(v, acc) }
    when Array then val.each { |e| collect_strings(e, acc) }
    when String then acc << val
    end
  end

  def fallback_line_matches?(block, key, expected)
    k = Regexp.escape(key)
    case expected
    when TrueClass, FalseClass
      block.match?(/^\s+#{k}:\s*#{expected}\s*,?\s*$/m)
    when Integer
      block.match?(/^\s+#{k}:\s*#{expected}\s*,?\s*$/m)
    when Float
      block.match?(/^\s+#{k}:\s*#{Regexp.escape(expected.to_s)}\s*,?\s*$/m)
    when String
      block.match?(/^\s+#{k}:\s*['"]#{Regexp.escape(expected)}['"]\s*,?\s*$/m)
    else
      raise "unsupported type #{expected.class} for #{key}"
    end
  end
end
