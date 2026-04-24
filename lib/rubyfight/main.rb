# Opal エントリ（ビルド対象）。ゲームロジックは順次ここから require する。
# require 'opal' を先に書くとランタイム＋corelib がバンドルに含まれる（Opal 1.1 静的ビルド）
require 'opal'
require 'json'
require 'rubyfight/version'
require 'rubyfight/game_config'
require 'rubyfight/field_mask'
require 'rubyfight/layout'
require 'rubyfight/territory'

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

  # index.html から Rubyfight::Territory を呼ぶ薄いブリッジ（Opal メソッド名は $ で始まる）
  def self.attach_territory_bridge!
    t = Territory
    %x{
      window.RUBYFIGHT = window.RUBYFIGHT || {};
      var _t = #{t};
      window.RUBYFIGHT.territoryPointInTriangle = function(px, py, x0, y0, x1, y1, x2, y2) {
        return _t['$point_in_triangle$ques'](px, py, x0, y0, x1, y1, x2, y2);
      };
      window.RUBYFIGHT.territoryFillTriangle = function(grid, playerId, gx0, gy0, gx1, gy1, gx2, gy2, maskRows) {
        var tri = [[gx0, gy0], [gx1, gy1], [gx2, gy2]];
        return _t['$fill_triangle!'](grid, playerId, tri, maskRows);
      };
      window.RUBYFIGHT.territoryCalcScores = function(grid, maskRows) {
        var a = _t['$calc_scores'](grid, maskRows);
        return [a[0], a[1]];
      };
    }
  end
end

Rubyfight.expose_to_browser!
Rubyfight.attach_territory_bridge!
Rubyfight.announce!
