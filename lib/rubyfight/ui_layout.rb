# タイトル等の UI 座標（index.html UI_LAYOUT と同一。JSON で window に渡す）
module Rubyfight
  module UiLayout
    def self.to_browser_hash
      {
        'title' => {
          'logoCenterX' => 480,
          'juggingY' => 30,
          'mainTitleY' => 108,
          'subRubykaigiY' => 172,
          'subTerritoryY' => 196,
          'menu' => { 'y' => 260 },
          'mascotLeft' => { 'x' => 124, 'y' => 308 },
          'mascotRight' => { 'x' => 836, 'y' => 308 },
          'mascotPixel' => 3,
          'footerControlsY' => 466,
          'footerFullscreenY' => 486,
          'footerCopyrightY' => 508,
          'parts' => {
            'background' => { 'x' => 0, 'y' => 0, 'w' => 960, 'h' => 540, 'fit' => 'cover' },
            'logo' => { 'x' => 136, 'y' => 18, 'w' => 688, 'h' => 252, 'fit' => 'contain' },
            'charLeft' => { 'x' => 70, 'y' => 232, 'w' => 208, 'h' => 224, 'fit' => 'contain' },
            'charRight' => { 'x' => 682, 'y' => 232, 'w' => 208, 'h' => 224, 'fit' => 'contain' }
          }
        }
      }
    end
  end
end
