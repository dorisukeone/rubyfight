# RUBYFIGHT

RubyKaigi 向けのブラウザ対戦（1P vs CPU / 1P vs 2P）ミニゲームです。

**ブランチ方針:** **`master` が正規ライン**です（`lib/rubyfight/` の Ruby 実装＋Opal で `build/rubyfight.js` を生成し、`index.html` が Canvas ホスト）。GitHub のデフォルトブランチも `master` に揃えています。旧来の「JS のみの本流」は置いていません。

## コンセプト — あえて Ruby で持つ理由

このリポジトリは **「ブラウザゲームだけど、正本は Ruby」** という置き方をあえて採用しています。

- **読む・直す・レビューする対象は `.rb` に寄せる**  
  スコアや領土、CPU の意思決定、状態遷移、レイアウト定数、スプライト前計算など、**ルールと数値の意味が残る部分**は `lib/rubyfight/` に書きます。生成された `build/rubyfight.js` は配布用の成果物で、手でメインのロジックを追う入口にはしません。

- **Minitest でロジックだけ検証する**  
  同じモジュールを MRI 上で `require` し、**Canvas なしで振る舞いをテスト**できます。イベントループや描画に引っ張られないので、ブース前に「ここがルールの核です」と短く示しやすいです。

- **ブラウザで動かす手段として Opal を使う**  
  Ruby VM を wasm で載せる代わりに、**トランスパイルして静的ホスティング（Firebase 等）とオフライン `file://` に寄せる**構成です。トレードオフは承知のうえで、「ソースを開けば Ruby」「ビルドすればそのまま遊べる」を両立させています。

- **JS / Canvas は「ホスト」に留める**  
  `index.html` 側は **描画・音声・キーの生イベント・画像ロード**など、ブラウザ API に直結する薄い層に寄せ、**勝敗やマス目の解釈は Ruby ブリッジ経由**にしています（ページと Ruby の JSON が噛み合わないときはフォールバックで動く安全側の設計です）。

要するに **「Ruby で作った」と言ったときに、リポジトリの主役が `.rb` である**状態を優先している、というのがコンセプトです。

技術的な内訳: [Opal](https://opalrb.com/) で `lib/rubyfight/main.rb` から `build/rubyfight.js` を生成し、先に読み込んだうえでゲームを起動します。

## 実装フェーズ（現状サマリ）

計画の全体像・レベル A/B/C の定義は **[docs/RUBY_PORT_PLAN.md](docs/RUBY_PORT_PLAN.md)** を参照。ここでは README 向けに **2026-04 時点の進捗**だけ置きます。

| フェーズ | ねらい | 状態 |
|---------|--------|------|
| **Phase 0** | `Gemfile` / `rake opal:build` / `main.rb` バナー / `build/rubyfight.js` | **完了** |
| **Phase 1** | 定数・マスク・領土・CPU・移動・セッション・グラフィックス前計算・UI レイアウト JSON などを `lib/rubyfight/` に集約し、`window.RUBYFIGHT` ブリッジ＋`RUBYFIGHT_SYNCED` で `index.html` と接続 | **ほぼ完了**（ループ内のキー解釈を Ruby の `Input` に完全移譲する部分は未） |
| **Phase 2** | 状態機械・入力 | **一部完了**（`GameState` でタイマー・タイトルメニュー・リザルト文言・点滅等。キー割り当ての集約はこれから） |
| **Phase 3** | 描画 | **ハイブリッド（3a）** — スプライト枠・シート切り出し・fit 等は Ruby、実際の `drawImage` / `fillRect` は Canvas 側 |
| **Phase 4** | 仕上げ | **一部** — Firebase デプロイは `rake hosting:deploy` 推奨。`push` / `pull_request` で GitHub Actions（テスト・`hosting:verify`）を実行 |

**ゴールの目安:** 計画書の **レベル A**（ロジックの正本は Ruby）にかなり近いです。**レベル B**（描画駆動まで Ruby）は未着手です。

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
- **`public/index.html` がルートと違うとテストが赤い場合:** `bundle exec rake hosting:prepare` で配信用ディレクトリを同期してください。

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
# Minitest → Opal ビルド → public/ に配布物のみコピー → 必須ファイル検証 → デプロイ
bundle exec rake hosting:deploy
```

`firebase.json` の `public` は **`public/` ディレクトリ**（`rake hosting:prepare` が `index.html`・`build/rubyfight.js`・`assets/` だけを同期）。リポジトリの `lib/` や `test/` はホスティングに含まれません。

**`firebase deploy` だけは実行しないでください。** 空または古い `public/` がそのまま配信されます。検証付きの `bundle exec rake hosting:deploy`、または最低でも `bundle exec rake hosting:verify` の後にデプロイしてください。

## トラブルシュート

- **`bundle install` で `racc` などネイティブ ext が失敗する**  
  → `Gemfile` の `parser` バージョンを確認（`3.2.2.0` 固定）。Ruby 3 系では Opal を上げる選択肢もあります。
- **コンソールに CONFIG 不一致**  
  → `lib/rubyfight/game_config.rb` と `index.html` のフォールバック定数がずれていないか、`rake` で再ビルドしたか確認してください。
- **`RUBYFIGHT_SYNCED` が false / Opal ブリッジが効かない**  
  → `RUBYFIGHT_*_JSON` のパース失敗やマスク行数・列数の不整合があると、ページは `FALLBACK_*` のみ使い、**ゲーム用ブリッジはオフ**になります（純 JS フォールバックで動作）。コンソールの `[RUBYFIGHT] Ruby page JSON invalid...` を確認してください。

---

*RUBYFIGHT / RUBYKAIGI*
