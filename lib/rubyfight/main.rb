# Opal エントリ（ビルド対象）。ゲームロジックは順次ここから require する。
# require 'opal' を先に書くとランタイム＋corelib がバンドルに含まれる（Opal 1.1 静的ビルド）
require 'opal'
require 'rubyfight/version'

module Rubyfight
  def self.boot_banner
    "[RUBYFIGHT] Ruby core #{VERSION} (Opal)"
  end

  # ブラウザのコンソールで Ruby 側が生きていることを確認する
  def self.announce!
    puts boot_banner
  end
end

Rubyfight.announce!
