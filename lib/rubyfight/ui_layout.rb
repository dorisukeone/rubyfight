# タイトル等の UI 座標（index.html UI_LAYOUT と同一。JSON で window に渡す）
module Rubyfight
  module UiLayout
    def self.to_browser_hash
      {
        'title' => {
          'logoCenterX' => 480,
          'juggingY' => 44,
          'mainTitleY' => 126,
          'subTerritoryY' => 216,
          # サブタイトル〜メニュー〜キャラの縦バランス（2 項目メニュー想定）
          'menu' => { 'y' => 292 },
          # メニュー文案（中央）の左右の空きに寄せる。右キャラ枠 180×180（中心 686,371）
          'mascotLeft' => { 'x' => 280, 'y' => 404 },
          'mascotRight' => { 'x' => 680, 'y' => 404 },
          'mascotPixel' => 3,
          'footerControlsY' => 458,
          'footerFullscreenY' => 478,
          'parts' => {
            'background' => { 'x' => 0, 'y' => 0, 'w' => 960, 'h' => 540, 'fit' => 'cover' },
            'logo' => { 'x' => 136, 'y' => 32, 'w' => 688, 'h' => 252, 'fit' => 'contain' },
            'charLeft' => { 'x' => 190, 'y' => 281, 'w' => 180, 'h' => 180, 'fit' => 'contain' },
            'charRight' => { 'x' => 596, 'y' => 281, 'w' => 180, 'h' => 180, 'fit' => 'contain' }
          }
        }
      }
    end
  end
end
