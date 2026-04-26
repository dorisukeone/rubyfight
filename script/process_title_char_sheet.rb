#!/usr/bin/env ruby
# frozen_string_literal: true

# 使用例:
#   bundle install
#   ruby script/process_title_char_sheet.rb path/to/strip.png [out.png] [cols]
#   KEY=black ruby script/process_title_char_sheet.rb ...
#   KEY=green ruby script/process_title_char_sheet.rb ...
#
# 環境変数: KEY=black|green|none  PAD=16  GREEN_TH=90  BLACK_MAX=12

require 'fileutils'
require_relative 'sprite_sheet_grid'

src = ARGV[0] or abort 'usage: ruby script/process_title_char_sheet.rb <input_strip> [output.png] [cols]'

out = ARGV[1] || File.expand_path('../assets/title/char_red_sheet.png', __dir__)
cols = (ARGV[2] || ENV['COLS'] || 24).to_i
key = (ENV['KEY'] || 'black').downcase
pad = (ENV['PAD'] || 16).to_i
green_th = (ENV['GREEN_TH'] || 90).to_f
black_max = (ENV['BLACK_MAX'] || 12).to_i

base = SpriteSheetGrid.load_image_via_png(src)
frames = SpriteSheetGrid.slice_horizontal_strip(base, cols)

keyed = frames.map do |frame|
  f = frame.dup
  case key
  when 'green'
    SpriteSheetGrid.chroma_key_green!(f, threshold: green_th)
  when 'black'
    SpriteSheetGrid.chroma_key_near_black!(f, max_rgb: black_max)
  when 'none'
    # そのまま（透過 PNG 想定）
  else
    abort "KEY must be black|green|none, got: #{key.inspect}"
  end
  f
end

strip = SpriteSheetGrid.process_to_grid_frames(keyed, padding: pad)
FileUtils.mkdir_p(File.dirname(out))
strip.save(out, fast_rgba: true)

cw = strip.width / cols
ch = strip.height
warn "[sprite_sheet] wrote #{out} (#{strip.width}x#{strip.height}) cell=#{cw}x#{ch} cols=#{cols}"
warn "[sprite_sheet] hint: TITLE_CHAR_RED_SHEET に frameWidth: #{cw}, frameHeight: #{ch} を設定すると固定グリッド切り出しになります。"
