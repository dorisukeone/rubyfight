# RUBYFIGHT

RubyKaigi 向けのブラウザ対戦（1P vs CPU / 1P vs 2P）ミニゲームです。  
**ゲームのルール・定数・領土ロジックなどは Ruby（`lib/rubyfight/`）がソース**で、[Opal](https://opalrb.com/) で `build/rubyfight.js` にトランスパイルし、`index.html` から読み込んでいます。描画・音声・入力の生イベントは Canvas / Web Audio 側に残しています。

## 必要な環境

- **Ruby**（2.6 以上推奨。`Gemfile` は古い macOS 同梱 Ruby でも動くよう `parser` をピン留めしています）
- **Bundler**
- ブラウザ（ローカルは `file://` でも可。フォントは Google Fonts を参照）

## セットアップ

```bash
cd rubyfight
bundle install --path vendor/bundle
```

## ビルドとテスト

デフォルトタスクは **テストのあと Opal ビルド**です。

```bash
bundle exec rake
```

- **テストのみ:** `bundle exec rake test`
- **JS のみ再生成:** `bundle exec rake opal:build`

`build/rubyfight.js` はリポジトリに含め、Firebase などでは **ホスティングだけで配信**できる想定です。ローカルで `.rb` を直したら、上記でバンドルを更新してください。

## 遊び方

1. `bundle exec rake` で `build/rubyfight.js` を生成（または既存のバンドルをそのまま利用）
2. `index.html` をブラウザで開く  
   - 先頭で `build/rubyfight.js` を読み込み、`CONFIG` / フィールドマスク / UI レイアウトは Ruby から渡した JSON を優先します（無い場合はページ内フォールバック）

開発者向け: DevTools コンソールに `[RUBYFIGHT] Ruby core …` のバナーと、Ruby との突合ログが出ます。

## ディレクトリ構成（抜粋）

| パス | 内容 |
|------|------|
| `lib/rubyfight/` | ゲームロジック・設定（MRI / Opal 共通 `require`） |
| `lib/rubyfight/main.rb` | Opal エントリ・`window` への JSON / ブリッジ |
| `build/rubyfight.js` | Opal ビルド成果物 |
| `test/rubyfight/` | Minitest |
| `docs/RUBY_PORT_PLAN.md` | Ruby 化のフェーズ計画 |
| `index.html` | Canvas ゲーム本体・薄い JS 層 |

## Firebase Hosting でデプロイ

プロジェクト例は `.firebaserc` を参照してください。

```bash
# 必ず最新の rubyfight.js をコミット／配置してから
firebase deploy
```

`firebase.json` ではリポジトリルートを `public` にしています。

## トラブルシュート

- **`bundle install` で `racc` などネイティブ ext が失敗する**  
  → `Gemfile` の `parser` バージョンを確認（`3.2.2.0` 固定）。Ruby 3 系では Opal を上げる選択肢もあります。
- **コンソールに CONFIG 不一致**  
  → `lib/rubyfight/game_config.rb` と `index.html` のフォールバック定数がずれていないか、`rake` で再ビルドしたか確認してください。
- **`RUBYFIGHT_SYNCED` が false / Opal ブリッジが効かない**  
  → `RUBYFIGHT_*_JSON` のパース失敗やマスク行数・列数の不整合があると、ページは `FALLBACK_*` のみ使い、**ゲーム用ブリッジはオフ**になります（純 JS フォールバックで動作）。コンソールの `[RUBYFIGHT] Ruby page JSON invalid...` を確認してください。

---

*RUBYFIGHT / RUBYKAIGI*
