# frozen_string_literal: true

source 'https://rubygems.org'

# parser 3.3+ は racc のネイティブ ext 依存で、macOS 同梱 Ruby 2.6 ではビルド失敗しやすい。
gem 'parser', '3.2.2.0'
# 古いシステム Ruby 向け。Ruby 3.x 環境では opal を 1.7+ に上げ、parser の上限を外すこと。
gem 'opal', '~> 1.1.1'
gem 'rake', '~> 13.0'

group :test do
  gem 'minitest', '~> 5.25'
end

group :development do
  # タイトル用スプライトシートのオフライン処理（process_to_grid_frames）
  gem 'chunky_png', '~> 1.4'
end
