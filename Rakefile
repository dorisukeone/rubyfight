require 'fileutils'
require 'opal/builder'
require 'opal/builder_processors'
require 'rake/testtask'
require_relative 'lib/rubyfight/game_config'

directory 'build'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

desc 'Opal: lib/rubyfight を 1 ファイルにバンドル → build/rubyfight.js'
task 'opal:build' => ['build'] do
  builder = Opal::Builder.new
  lib = File.expand_path('lib', __dir__)
  builder.append_paths lib
  entry = File.expand_path('lib/rubyfight/main.rb', __dir__)
  compiled = builder.build(entry).to_s
  out = File.expand_path('build/rubyfight.js', __dir__)
  File.binwrite(out, compiled)
  puts "Wrote #{out} (#{compiled.bytesize} bytes)"
end

desc 'タイトル赤キャラ用ストリップを整数スライス→キー→process_to_grid_frames（development: chunky_png + macOS sips）'
task 'assets:grid_title_char' do
  require_relative 'script/sprite_sheet_grid'
  src = ENV.fetch('SRC', File.expand_path('assets/title/char_red_sheet.png', __dir__))
  out = ENV.fetch('OUT', File.expand_path('assets/title/char_red_sheet.png', __dir__))
  cols = ENV.fetch('COLS', '24').to_i
  key = ENV.fetch('KEY', 'black').downcase
  pad = ENV.fetch('PAD', '16').to_i

  base = SpriteSheetGrid.load_image_via_png(src)
  frames = SpriteSheetGrid.slice_horizontal_strip(base, cols)
  keyed = frames.map do |frame|
    f = frame.dup
    case key
    when 'green'
      SpriteSheetGrid.chroma_key_green!(f, threshold: ENV.fetch('GREEN_TH', '90').to_f)
    when 'black'
      SpriteSheetGrid.chroma_key_near_black!(f, max_rgb: ENV.fetch('BLACK_MAX', '12').to_i)
    when 'none'
      # no-op
    else
      raise "KEY must be black|green|none, got: #{key.inspect}"
    end
    f
  end
  strip = SpriteSheetGrid.process_to_grid_frames(keyed, padding: pad)
  FileUtils.mkdir_p(File.dirname(out))
  strip.save(out, fast_rgba: true)
  cw = strip.width / cols
  ch = strip.height
  puts "Wrote #{out} (#{strip.width}x#{strip.height}) cell=#{cw}x#{ch}"
  puts "Set TITLE_CHAR_RED_SHEET frameWidth: #{cw}, frameHeight: #{ch} for fixed grid."
end

desc 'Firebase Hosting 用: public/ に index.html・build/rubyfight.js・assets/ のみコピー'
task 'hosting:prepare' do
  root = __dir__
  pub = File.join(root, 'public')
  src_assets = File.join(root, 'assets')
  src_js = File.join(root, 'build', 'rubyfight.js')
  src_html = File.join(root, 'index.html')

  raise "missing #{src_html}" unless File.file?(src_html)
  raise "missing #{src_js} (run rake opal:build)" unless File.file?(src_js)
  raise "missing #{src_assets}" unless File.directory?(src_assets)

  FileUtils.rm_rf(pub)
  FileUtils.mkdir_p(File.join(pub, 'build'))
  FileUtils.cp(src_html, File.join(pub, 'index.html'))
  FileUtils.cp(src_js, File.join(pub, 'build', 'rubyfight.js'))
  FileUtils.cp_r(src_assets, File.join(pub, 'assets'))
  Dir.glob(File.join(pub, '**', '.DS_Store'), File::FNM_DOTMATCH).each { |f| FileUtils.rm_f(f) }
  puts "Wrote #{pub}/"
end

desc 'public/ に必須ファイル・GameConfig 由来のアセットが揃っているか検証（hosting:prepare 後）'
task 'hosting:verify' => ['hosting:prepare'] do
  pub = File.join(__dir__, 'public')
  index_p = File.join(pub, 'index.html')
  js_p = File.join(pub, 'build', 'rubyfight.js')

  raise "missing #{index_p}" unless File.file?(index_p)
  raise "missing #{js_p}" unless File.file?(js_p)

  js_size = File.size(js_p)
  raise "#{js_p} too small (#{js_size} bytes); run opal:build" if js_size < 10_000

  Rubyfight::GameConfig.deploy_required_asset_paths_relative.each do |rel|
    full = File.join(pub, rel)
    raise "deploy asset missing: #{rel} (expected at #{full})" unless File.file?(full)
  end

  puts 'hosting:verify OK (index, rubyfight.js, assets from GameConfig)'
end

desc 'テスト → ビルド → public 同期・検証 → firebase deploy --only hosting'
task 'hosting:deploy' => %w[test opal:build hosting:verify] do
  sh 'firebase deploy --only hosting'
end

task default: %i[test opal:build]
