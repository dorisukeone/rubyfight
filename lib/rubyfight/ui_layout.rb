# タイトル等の UI 座標（index.html UI_LAYOUT と同一。JSON で window に渡す）
module Rubyfight
  module UiLayout
    def self.to_browser_hash
      {
        'title' => {
          'logoCenterX' => 480,
          'juggingY' => 44,
          'mainTitleY' => 126,
          'subRubykaigiY' => 192,
          'subTerritoryY' => 216,
          # サブタイトル〜メニュー〜キャラの縦バランス（2 項目メニュー想定）
          'menu' => { 'y' => 292 },
          'mascotLeft' => { 'x' => 124, 'y' => 306 },
          'mascotRight' => { 'x' => 836, 'y' => 306 },
          'mascotPixel' => 3,
          'footerControlsY' => 458,
          'footerFullscreenY' => 478,
          'parts' => {
            'background' => { 'x' => 0, 'y' => 0, 'w' => 960, 'h' => 540, 'fit' => 'cover' },
            'logo' => { 'x' => 136, 'y' => 32, 'w' => 688, 'h' => 252, 'fit' => 'contain' },
            # 左右同じ y/h で足元一致。w 同幅・画面中心対称。枠内は下辺=足元・水平中心（vAlign: bottom）
            'charLeft' => { 'x' => 70, 'y' => 230, 'w' => 208, 'h' => 224, 'fit' => 'contain', 'vAlign' => 'bottom' },
            'charRight' => { 'x' => 682, 'y' => 230, 'w' => 208, 'h' => 224, 'fit' => 'contain', 'vAlign' => 'bottom' }
          }
        }
      }
    end
  end
end
