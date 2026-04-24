# RUBYFIGHT — Ruby 化実装計画（RubyKaigi 向け）

「**Ruby で作成しました**」と胸を張れる状態を目指す。  
現状の `index.html` 単体・Canvas・JavaScript 実装から、**ゲームの意思決定・状態遷移・ルールの大半を Ruby で記述**し、ブラウザではビルド成果物として動かす。

---

## 1. ゴールの定義（何をもって「Ruby で作った」と言えるか）

| レベル | 内容 | RubyKaigi での説明 |
|--------|------|-------------------|
| A（推奨） | ゲームロジック・状態機械・スコア・CPU・マスク判定などを **Ruby ソースが正**。ビルドで JS に落ちるがリポのメンテ対象は Ruby。 | 「ロジックは全部 Ruby。ブラウザ用に Opal でトランスパイル」 |
| B | 同上に加え、**描画ループの駆動**も Ruby から（`Kernel#tick` 相当で Canvas API を呼ぶ）。 | 「描画まで Ruby DSL。最終的に Canvas は JS バインディング」 |
| C | **CRuby / PicoRuby.wasm** で VM ごとブラウザ実行。 | 「Ruby VM がブラウザで動いている」— 初期ロード・I/O が重めになりやすい |

本計画の**既定は A → 可能なら B**。C は「デモ用プロトタイプ」や第 2 フェーズで検討。

---

## 2. 推奨スタック：Opal（トランスパイル）

**理由**

- ブラウザ配布（Firebase Hosting・オフライン `file://`）を維持しやすい。
- 既存の「1 ページで完結」に近い形にできる（ビルドで `application.js` を生成し `index.html` から読む）。
- RubyKaigi 来場者に「ソースを見せる」とき **`.rb` がそのまま読み物**になる。
- コミュニティ実績・ドキュメントが比較的ある。

**トレードオフ**

- 標準ライブラリの一部制限、`method_missing` 周りの注意、デバッグはソースマップ前提。
- Canvas は `Native` / `x-string` または薄い JS ラッパーが必要（B を取るほどラッパー設計が重要）。

**代替：ruby.wasm（CRuby）**

- 「VM が本物 Ruby」のアピールは強い。
- 初回ロード・メモリ・Canvas との境界が重く、ブース用の安定性は別途検証が必要。

---

## 3. 目標ディレクトリ構成（案）

```
rubyfight/
├── index.html              # ビルド後: <script src="build/rubyfight.js"> のみ等
├── assets/                 # 現状維持
├── vendor/opal/            # または Gem で管理（推奨: Gem）
├── Gemfile
├── Rakefile                # opal:build, opal:server（任意）
├── lib/
│   └── rubyfight/
│       ├── version.rb
│       ├── config.rb       # 定数・色・タイル（現 CONFIG）
│       ├── field.rb        # マスク・グリッド
│       ├── game_state.rb   # TITLE / PLAY / RESULT
│       ├── players.rb
│       ├── cpu.rb
│       ├── territory.rb    # 塗り・三角形等
│       ├── title_ui.rb     # メニュー・レイアウト定数
│       └── main.rb         # エントリ: 初期化・ループ登録
├── lib/rubyfight/browser/
│   └── canvas_bridge.rb    # Canvas 2D の薄いラッパー（Opal Native）
└── docs/
    └── RUBY_PORT_PLAN.md   # 本書
```

`build/` または `dist/` に出力し、`.gitignore` に追加するか、CI で生成のみにするかはチーム方針で決定。

---

## 4. フェーズ分割

### Phase 0 — ブランチ・ビルドの骨格（1〜2 日）

- [x] 本ブランチ `feat/ruby-port-opal` で作業。
- [x] `Gemfile` に `opal`（`parser` を `3.2.2.0` にピン留め: macOS 同梱 Ruby 2.6 で `racc` ext を避ける）。
- [x] `Rakefile`: `rake opal:build` → `build/rubyfight.js`。
- [x] `lib/rubyfight/main.rb` で `require 'opal'` ＋ `puts` バナー（ブラウザコンソールに表示）。
- [x] `index.html` が `build/rubyfight.js` を読み込み（ゲーム本体 JS は当面そのまま併存）。

**ビルド手順**

```bash
bundle install --path vendor/bundle
bundle exec rake opal:build
```

`build/rubyfight.js` は配信のためコミット可（Firebase 等で `bundle` 不要にするため）。`vendor/bundle` は `.gitignore`。

### Phase 1 — データと純粋ロジックの移植（2〜4 日）

依存が Canvas に少ない順に Ruby へ。

- [ ] `CONFIG` 相当 → `Rubyfight::Config`（定数・ハッシュ）。
- [ ] フィールドマスク・タイル座標 → `Field` / `Grid`。
- [ ] フラグ配置・勢力範囲・スコア計算 → `Territory`（既存アルゴリズムをメソッド分割）。
- [ ] CPU 行動 → `CpuController`（乱数・タイマーは注入可能にするとテストしやすい）。
- [ ] **単体テスト**（`minitest` / `rspec`）：`bundle exec rake test` でロジックのみ検証可能に。

### Phase 2 — 状態機械と入力（2〜3 日）

- [ ] `GameState`: `TITLE` / `PLAY` / `RESULT` と遷移。
- [ ] キー入力: JS 側で `keydown` → Ruby の `Input` オブジェクトを更新するブリッジ（薄い層は JS でも可だが、**反応の解釈は Ruby** に寄せる）。

### Phase 3 — 描画（最も工数が読める）（4〜10 日）

方針は二段階が現実的。

1. **3a. ハイブリッド（短期）**  
   - タイル・プレイヤー・UI の `fillRect` / `drawImage` を **JS の小さな `renderer.js`** に残し、Ruby からは「描画コマンドの配列」または **Native 呼び出し**だけ行う。  
   - 「ロジックは Ruby」は満たすが、見た目のコードは半分 JS。

2. **3b. Canvas ラッパー統合（中期）**  
   - `CanvasBridge` に `fill_rect`, `draw_image`, `draw_text` を集約し、**ゲームコードからは Ruby のみ**。

- [ ] タイトル画面：レイアウト定数は `TitleLayout`（現 `UI_LAYOUT`）。
- [ ] スプライトシート描画：フレーム index 計算は Ruby、実際の `drawImage` はブリッジ。

### Phase 4 — 仕上げ（2〜3 日）

- [ ] `firebase deploy` 前に `rake opal:build` を CI / 手順に組み込む。
- [ ] README に「Ruby でビルドして遊ぶ」手順。
- [ ] パフォーマンス確認（60fps 近く維持できるか。ボトルネックは描画と GC）。

---

## 5. 「胸を張る」ための README / ブース用一言

- リポジトリの **メイン言語を Ruby** にする（GitHub Linguist 対策：生成 JS を `linguist-generated` や `vendor` 扱いにする運用も検討）。
- トップの README に **アーキテクチャ図**（Ruby コア → Opal → ブラウザ）を置く。
- 可能なら **1 ファイルのエントリ `main.rb`** を「ここから読めばゲームの流れが分かる」と示す。

---

## 6. リスクと回避

| リスク | 回避 |
|--------|------|
| Opal と既存 JS の二重管理 | 早めに `index.html` のインライン JS を削除し、ビルド一本化。 |
| デバッグ困難 | ソースマップ、小さなフェーズでの動作確認。 |
| ブースオフライン | `build/*.js` をコミットするか、オフライン用 ZIP にビルド済みを同梱。 |
| 「結局 JS が大部分」に見える | 行数・エントリ・README で Ruby を主役に定義（上記 Phase 3b）。 |

---

## 7. 次のアクション（チェックリスト）

1. 本ブランチで Phase 0 の `Gemfile` + `Rakefile` + Hello World ビルドをマージ可能な単位でコミット。  
2. Phase 1 の `Field` / `Territory` から着手（テスト付き）。  
3. 既存 `index.html` の該当ロジックを **コピペではなく** 読みながら Ruby に再実装（バグを持ち込まない）。

---

*ブランチ: `feat/ruby-port-opal`*  
*最終更新: 計画策定時点*
