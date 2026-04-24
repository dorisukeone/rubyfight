# Opal エントリ（ビルド対象）。ゲームロジックは順次ここから require する。
# require 'opal' を先に書くとランタイム＋corelib がバンドルに含まれる（Opal 1.1 静的ビルド）
require 'opal'
require 'json'
require 'rubyfight/version'
require 'rubyfight/game_config'
require 'rubyfight/field_mask'

module Rubyfight
  def self.boot_banner
    "[RUBYFIGHT] Ruby core #{VERSION} (Opal)"
  end

  def self.announce!
    puts boot_banner
  end

  # JS 側が index.html の CONFIG / FIELD_MASK と突き合わせできるよう window に載せる
  # （Opal::String を代入しないよう、補間で JS の文字列リテラルにする）
  def self.expose_to_browser!
    j = JSON.dump(GameConfig.to_browser_hash)
    r = JSON.dump(FieldMask::ROWS)
    %x{
      window.RUBYFIGHT_CONFIG_JSON = #{j};
      window.RUBYFIGHT_FIELD_MASK_JSON = #{r};
    }
  end
end

Rubyfight.expose_to_browser!
Rubyfight.announce!
