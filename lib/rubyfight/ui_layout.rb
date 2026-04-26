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
          # メニュー文案（中央）の左右の空きに寄せる。480 対称: 左枠 216+128=344、右 616〜744
          'mascotLeft' => { 'x' => 280, 'y' => 404 },
          'mascotRight' => { 'x' => 680, 'y' => 404 },
          'mascotPixel' => 3,
          'footerControlsY' => 458,
          'footerFullscreenY' => 478,
          'parts' => {
            'background' => { 'x' => 0, 'y' => 0, 'w' => 960, 'h' => 540, 'fit' => 'cover' },
            'logo' => { 'x' => 136, 'y' => 32, 'w' => 688, 'h' => 252, 'fit' => 'contain' },
            'charLeft' => { 'x' => 216, 'y' => 288, 'w' => 128, 'h' => 166, 'fit' => 'contain' },
            'charRight' => { 'x' => 622, 'y' => 288, 'w' => 128, 'h' => 166, 'fit' => 'contain' }
          }
        }
      }
    end
  end
end
