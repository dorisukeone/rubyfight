# frozen_string_literal: true

# タイトル用ストリップシート → 整数スライス → クロマ／マット → 足元ピボット＋パディング＋偶数セルで再グリッド化
# Opal には含めない（開発時のみ require）

require 'chunky_png'

module SpriteSheetGrid
  module_function

  # index.html cellAxisStartsAndSizes と同じ（余りは先頭セルから 1px ずつ配分）
  def cell_axis_starts_and_sizes(total, n)
    n = [1, n.to_i].max
    total = [0, total.to_i].max
    base = total / n
    rem = total % n
    sizes = Array.new(n) { |i| base + (i < rem ? 1 : 0) }
    starts = []
    acc = 0
    sizes.each do |sz|
      starts << acc
      acc += sz
    end
    [starts, sizes]
  end

  def next_even(n)
    n = n.to_i
    n.odd? ? n + 1 : n
  end

  # 横 1 行ストリップを整数幅でスライス（小数ピクセルなし）
  def slice_horizontal_strip(canvas, cols)
    tw = canvas.width
    th = canvas.height
    raise ArgumentError, 'cols must be >= 1' if cols < 1

    starts, sizes = cell_axis_starts_and_sizes(tw, cols)
    cols.times.map do |i|
      sx = starts[i]
      sw = sizes[i]
      canvas.crop(sx, 0, sw, th)
    end
  end

  def chroma_key_green!(canvas, r: 0, g: 255, b: 0, threshold: 90.0)
    w = canvas.width
    h = canvas.height
    th2 = threshold * threshold
    h.times do |y|
      w.times do |x|
        p = canvas[x, y]
        pr = ChunkyPNG::Color.r(p)
        pg = ChunkyPNG::Color.g(p)
        pb = ChunkyPNG::Color.b(p)
        d = (pr - r)**2 + (pg - g)**2 + (pb - b)**2
        canvas[x, y] = ChunkyPNG::Color.rgba(pr, pg, pb, 0) if d <= th2
      end
    end
    canvas
  end

  def chroma_key_near_black!(canvas, max_rgb: 12)
    w = canvas.width
    h = canvas.height
    h.times do |y|
      w.times do |x|
        p = canvas[x, y]
        pr = ChunkyPNG::Color.r(p)
        pg = ChunkyPNG::Color.g(p)
        pb = ChunkyPNG::Color.b(p)
        next unless [pr, pg, pb].max <= max_rgb

        canvas[x, y] = ChunkyPNG::Color.rgba(pr, pg, pb, 0)
      end
    end
    canvas
  end

  def bbox_visible(canvas)
    w = canvas.width
    h = canvas.height
    min_x = w
    min_y = h
    max_x = -1
    max_y = -1
    h.times do |y|
      w.times do |x|
        a = ChunkyPNG::Color.a(canvas[x, y])
        next if a.zero?

        min_x = x if x < min_x
        min_y = y if y < min_y
        max_x = x if x > max_x
        max_y = y if y > max_y
      end
    end
    return nil if max_x < 0

    [min_x, min_y, max_x - min_x + 1, max_y - min_y + 1]
  end

  def crop_to_bbox(canvas)
    box = bbox_visible(canvas)
    return canvas unless box

    min_x, min_y, bw, bh = box
    canvas.crop(min_x, min_y, bw, bh)
  end

  # raw フレーム（各コマは既にキー済みでも可）→ 最大 bbox＋padding、足元そろえ、偶数セル、横連結
  def process_to_grid_frames(raw_canvases, padding: 16, pad_bottom: nil)
    pad = padding.to_i
    pad_b = pad_bottom.nil? ? pad : pad_bottom.to_i
    raise ArgumentError, 'frames empty' if raw_canvases.empty?

    cropped = raw_canvases.map { |c| crop_to_bbox(c) }
    max_w = cropped.map(&:width).max
    max_h = cropped.map(&:height).max

    cell_w = next_even(max_w + 2 * pad)
    cell_h = next_even(max_h + pad + pad_b)

    strip = ChunkyPNG::Image.new(cell_w * cropped.length, cell_h, ChunkyPNG::Color::TRANSPARENT)
    cropped.each_with_index do |frame, i|
      fw = frame.width
      fh = frame.height
      dx = (cell_w - fw) / 2
      dy = cell_h - pad_b - fh
      dx = 0 if dx.negative?
      dy = 0 if dy.negative?

      frame.height.times do |y|
        frame.width.times do |x|
          strip[dx + x + (i * cell_w), dy + y] = frame[x, y]
        end
      end
    end
    strip
  end

  def load_png(path)
    ChunkyPNG::Image.from_file(path)
  end

  # JPEG 等（拡張子が .png でも実体が JPEG の場合を含む）は sips で PNG に落とす（macOS）
  def load_image_via_png(path)
    path = File.expand_path(path)
    tmp = nil
    return load_png(path) if png_file?(path)

    require 'tmpdir'
    tmp = File.join(Dir.tmpdir, "rubyfight_sheet_#{Process.pid}_#{rand(1_000_000)}.png")
    ok = system('sips', '-s', 'format', 'png', path, '--out', tmp, out: File::NULL, err: File::NULL)
    raise "sips failed (need macOS): #{path}" unless ok && File.file?(tmp)

    load_png(tmp)
  ensure
    File.delete(tmp) if tmp && File.file?(tmp)
  end

  def png_file?(path)
    File.binread(path, 8).start_with?("\x89PNG\r\n\x1a\n")
  rescue StandardError
    false
  end
end
