require 'opal/builder'
require 'opal/builder_processors'
require 'rake/testtask'

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

task default: %i[test opal:build]
