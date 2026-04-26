#!/usr/bin/env ruby
# frozen_string_literal: true

# 横幅を「列数で割り切れる幅」まで右側を透過で伸ばす（等分割時の列幅揺れを防ぐ）
# 例: 1365×80 + cols=24 → 57×24=1368（右 3px 透過）

require 'fileutils'
require 'chunky_png'

cols = (ENV['COLS'] || 24).to_i
path = File.expand_path('../assets/title/char_red_sheet.png', __dir__)
abort "usage: COLS=24 ruby script/pad_char_red_sheet_to_24_cols.rb — missing #{path}" unless File.file?(path)

img = ChunkyPNG::Image.from_file(path)
fw = (img.width.to_f / cols).ceil
target_w = fw * cols
if target_w <= img.width
  warn "[pad] width #{img.width} already ≤ #{cols}×#{fw}=#{target_w}, no-op"
  exit 0
end

out = ChunkyPNG::Image.new(target_w, img.height, ChunkyPNG::Color::TRANSPARENT)
img.width.times do |x|
  img.height.times do |y|
    out[x, y] = img[x, y]
  end
end
backup = "#{path}.bak"
FileUtils.cp(path, backup) unless File.file?(backup)
out.save(path, fast_rgba: true)
warn "[pad] #{File.basename(path)} #{img.width}x#{img.height} → #{target_w}x#{out.height} cell #{fw}px (backup: #{File.basename(backup)})"
