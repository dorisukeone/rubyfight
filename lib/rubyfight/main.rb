# Opal エントリ（ビルド対象）。ゲームロジックは順次ここから require する。
# require 'opal' を先に書くとランタイム＋corelib がバンドルに含まれる（Opal 1.1 静的ビルド）
require 'opal'
require 'json'
require 'rubyfight/version'
require 'rubyfight/game_config'
require 'rubyfight/field_mask'
require 'rubyfight/layout'
require 'rubyfight/territory'
require 'rubyfight/cpu'
require 'rubyfight/game_state'
require 'rubyfight/movement'
require 'rubyfight/match'
require 'rubyfight/session'
require 'rubyfight/graphics'
require 'rubyfight/ui_layout'

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
    u = JSON.dump(UiLayout.to_browser_hash)
    %x{
      window.RUBYFIGHT_CONFIG_JSON = #{j};
      window.RUBYFIGHT_FIELD_MASK_JSON = #{r};
      window.RUBYFIGHT_UI_LAYOUT_JSON = #{u};
      window.RUBYFIGHT = window.RUBYFIGHT || {};
      window.RUBYFIGHT.__rbNum = function(v) {
        var n = Number(v);
        return (n === n && n !== Infinity && n !== -Infinity) ? n : 0;
      };
      window.RUBYFIGHT.__rbStr = function(v) {
        if (v == null || v === Opal.nil) return null;
        return (typeof v === 'string') ? v : String(v);
      };
    }
  end

  # index.html から Rubyfight::Territory を呼ぶ薄いブリッジ（Opal メソッド名は $ で始まる）
  def self.attach_territory_bridge!
    t = Territory
    %x{
      window.RUBYFIGHT = window.RUBYFIGHT || {};
      var _t = #{t};
      window.RUBYFIGHT.territoryPointInTriangle = function(px, py, x0, y0, x1, y1, x2, y2) {
        return _t['$point_in_triangle?'](px, py, x0, y0, x1, y1, x2, y2);
      };
      window.RUBYFIGHT.territoryFillTriangle = function(grid, playerId, gx0, gy0, gx1, gy1, gx2, gy2, maskRows) {
        var tri = [[gx0, gy0], [gx1, gy1], [gx2, gy2]];
        return window.RUBYFIGHT.__rbNum(_t['$fill_triangle!'](grid, playerId, tri, maskRows));
      };
      window.RUBYFIGHT.territoryCalcScores = function(grid, maskRows) {
        var a = _t['$calc_scores'](grid, maskRows);
        var N = window.RUBYFIGHT.__rbNum;
        return [N(a[0]), N(a[1])];
      };
      window.RUBYFIGHT.territoryPushFlag = function(pairs, gx, gy) {
        var r = _t['$push_flag'](pairs, gx, gy);
        if (r === Opal.nil) return null;
        var out = [];
        var N = window.RUBYFIGHT.__rbNum;
        for (var i = 0; i < r.length; i++) {
          out.push([N(r[i][0]), N(r[i][1])]);
        }
        return out;
      };
    }
  end

  def self.attach_layout_bridge!
    l = Layout
    %x{
      window.RUBYFIGHT = window.RUBYFIGHT || {};
      var _l = #{l};
      window.RUBYFIGHT.layoutPixelToGrid = function(px, py) {
        var a = _l['$pixel_to_grid'](px, py);
        var N = window.RUBYFIGHT.__rbNum;
        return [N(a[0]), N(a[1])];
      };
      window.RUBYFIGHT.layoutIsValidPosition = function(px, py, maskRows) {
        return _l['$player_position_valid?'](px, py, maskRows);
      };
    }
  end

  def self.attach_cpu_bridge!
    c = Cpu
    %x{
      window.RUBYFIGHT = window.RUBYFIGHT || {};
      var _c = #{c};
      window.RUBYFIGHT.cpuPickTarget = function(grid, maskRows) {
        var a = _c['$pick_target_center'](grid, maskRows);
        if (a === Opal.nil) return null;
        var N = window.RUBYFIGHT.__rbNum;
        return [N(a[0]), N(a[1])];
      };
      window.RUBYFIGHT.cpuWaitAfterFlagSec = function() {
        return window.RUBYFIGHT.__rbNum(_c['$wait_after_flag_sec']());
      };
      window.RUBYFIGHT.cpuWaitAfterStuckSec = function() {
        return window.RUBYFIGHT.__rbNum(_c['$wait_after_stuck_sec']());
      };
    }
  end

  def self.attach_graphics_bridge!
    gfx = Graphics
    %x{
      window.RUBYFIGHT = window.RUBYFIGHT || {};
      var _gfx = #{gfx};
      window.RUBYFIGHT.gfxClamp = function(v, lo, hi) {
        return window.RUBYFIGHT.__rbNum(_gfx['$clamp'](v, lo, hi));
      };
      window.RUBYFIGHT.gfxBlinkEvenPhase = function(nowMs, periodMs) {
        return _gfx['$blink_even_phase?'](nowMs, periodMs);
      };
      window.RUBYFIGHT.gfxAssetSheetCellPair = function(name) {
        var c = _gfx['$asset_sheet_cell_pair'](name);
        var N = window.RUBYFIGHT.__rbNum;
        return [N(c[0]), N(c[1])];
      };
      window.RUBYFIGHT.gfxUniformSpriteFrameRect = function(iw, ih, cols, rows, fi) {
        var r = _gfx['$uniform_sprite_frame_rect'](iw, ih, cols, rows, fi);
        var N = window.RUBYFIGHT.__rbNum;
        return [N(r[0]), N(r[1]), N(r[2]), N(r[3])];
      };
      window.RUBYFIGHT.gfxTitleCharFrameIndex = function(nowMs, fps, st, cnt, cols, rows) {
        var fi = _gfx['$title_char_frame_index'](nowMs, fps, st, cnt, cols, rows);
        return Math.floor(window.RUBYFIGHT.__rbNum(fi));
      };
      window.RUBYFIGHT.gfxSpriteFitScale = function(sw, sh, bw, bh, fit) {
        var fs = (fit == null || fit === undefined) ? 'contain' : ('' + fit);
        return window.RUBYFIGHT.__rbNum(_gfx['$sprite_fit_scale'](sw, sh, bw, bh, fs));
      };
      window.RUBYFIGHT.gfxClampSheetSource = function(iw, ih, sx, sy, sw, sh) {
        var r = _gfx['$clamp_sheet_source'](iw, ih, sx, sy, sw, sh);
        var N = window.RUBYFIGHT.__rbNum;
        return [N(r[0]), N(r[1]), N(r[2]), N(r[3])];
      };
      window.RUBYFIGHT.gfxScaleGridRectToImage = function(gx, gy, gw, gh, inw, inh, shw, shh) {
        var r = _gfx['$scale_grid_rect_to_image'](gx, gy, gw, gh, inw, inh, shw, shh);
        var N = window.RUBYFIGHT.__rbNum;
        return [N(r[0]), N(r[1]), N(r[2]), N(r[3])];
      };
      window.RUBYFIGHT.gfxSheetCellRect = function(gx, gy, gw, gh, cols, rows, col, row, ins) {
        var r = _gfx['$sheet_cell_rect'](gx, gy, gw, gh, cols, rows, col, row, ins);
        var N = window.RUBYFIGHT.__rbNum;
        return [N(r[0]), N(r[1]), N(r[2]), N(r[3])];
      };
    }
  end

  def self.attach_match_bridge!
    mt = Match
    %x{
      window.RUBYFIGHT = window.RUBYFIGHT || {};
      var _mt = #{mt};
      window.RUBYFIGHT.matchResultHeadline = function(p1s, p2s, vsCpu) {
        return window.RUBYFIGHT.__rbStr(_mt['$result_headline'](p1s, p2s, vsCpu));
      };
      window.RUBYFIGHT.matchResultTone = function(p1s, p2s) {
        return window.RUBYFIGHT.__rbStr(_mt['$result_tone'](p1s, p2s));
      };
    }
  end

  def self.attach_session_bridge!
    s = Session
    rows = Layout.grid_rows
    cols = Layout.grid_cols
    %x{
      window.RUBYFIGHT = window.RUBYFIGHT || {};
      var _ses = #{s};
      window.RUBYFIGHT.sessionInitialTimeRemaining = function() {
        return window.RUBYFIGHT.__rbNum(_ses['$initial_time_remaining']());
      };
      window.RUBYFIGHT.sessionP1Spawn = function() {
        var a = _ses['$p1_spawn_xy']();
        var N = window.RUBYFIGHT.__rbNum;
        return [N(a[0]), N(a[1])];
      };
      window.RUBYFIGHT.sessionP2Spawn = function() {
        var a = _ses['$p2_spawn_xy']();
        var N = window.RUBYFIGHT.__rbNum;
        return [N(a[0]), N(a[1])];
      };
      window.RUBYFIGHT.sessionBootstrapGrids = function() {
        function makeEmpty() {
          var g = [];
          for (var y = 0; y < #{rows}; y++) {
            var row = [];
            for (var x = 0; x < #{cols}; x++) { row.push(0); }
            g.push(row);
          }
          return g;
        }
        return [makeEmpty(), makeEmpty()];
      };
    }
  end

  def self.attach_movement_bridge!
    m = Movement
    %x{
      window.RUBYFIGHT = window.RUBYFIGHT || {};
      var _mv = #{m};
      window.RUBYFIGHT.moveSpeedForTimeRemaining = function(tr) {
        return window.RUBYFIGHT.__rbNum(_mv['$speed_for_time_remaining'](tr));
      };
      window.RUBYFIGHT.cpuMoveSpeedForTimeRemaining = function(tr) {
        return window.RUBYFIGHT.__rbNum(_mv['$cpu_speed_for_time_remaining'](tr));
      };
      window.RUBYFIGHT.cpuReachedTarget = function(dist, cpuSpd, dt) {
        return _mv['$cpu_reached_target?'](dist, cpuSpd, dt);
      };
      window.RUBYFIGHT.nudgeTowardFieldCenter = function(px, py) {
        var a = _mv['$nudge_toward_field_center'](px, py);
        var N = window.RUBYFIGHT.__rbNum;
        return [N(a[0]), N(a[1])];
      };
      window.RUBYFIGHT.rushHudBlinkPrimary = function(timeRemaining, nowMs) {
        return _mv['$rush_hud_blink_primary?'](timeRemaining, nowMs);
      };
    }
  end

  def self.attach_game_state_bridge!
    g = GameState
    %x{
      window.RUBYFIGHT = window.RUBYFIGHT || {};
      var _gs = #{g};
      window.RUBYFIGHT.gameStateTickPlaying = function(timeRemaining, delta) {
        var a = _gs['$tick_playing'](timeRemaining, delta);
        var ev = a[1];
        var nextTr = window.RUBYFIGHT.__rbNum(a[0]);
        var st = (ev === Opal.nil || ev == null) ? null : window.RUBYFIGHT.__rbStr(ev);
        return [nextTr, st];
      };
      window.RUBYFIGHT.gameStateCanAdvanceFromResult = function(nowMs, stateStartedMs) {
        return _gs['$can_advance_from_result?'](nowMs, stateStartedMs);
      };
      window.RUBYFIGHT.gameStateBlink500msPrimary = function(nowMs) {
        return _gs['$blink_500ms_primary?'](nowMs);
      };
      window.RUBYFIGHT.gameStateMenuPrevIndex = function(index, menuSize) {
        return Math.floor(window.RUBYFIGHT.__rbNum(_gs['$menu_prev_index'](index, menuSize)));
      };
      window.RUBYFIGHT.gameStateMenuNextIndex = function(index, menuSize) {
        return Math.floor(window.RUBYFIGHT.__rbNum(_gs['$menu_next_index'](index, menuSize)));
      };
      window.RUBYFIGHT.gameStateTitleConfirmAction = function(menuIndex) {
        var a = _gs['$title_confirm_action'](menuIndex);
        return (a === Opal.nil || a == null) ? null : window.RUBYFIGHT.__rbStr(a);
      };
    }
  end
end

Rubyfight.expose_to_browser!
Rubyfight.attach_layout_bridge!
Rubyfight.attach_territory_bridge!
Rubyfight.attach_cpu_bridge!
Rubyfight.attach_movement_bridge!
Rubyfight.attach_match_bridge!
Rubyfight.attach_session_bridge!
Rubyfight.attach_graphics_bridge!
Rubyfight.attach_game_state_bridge!
Rubyfight.announce!
