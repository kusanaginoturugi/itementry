# itementryプロジェクト コードレビュー

**レビュー日:** 2026-04-05

---

## 1. プロジェクト概要

道具販売レシートを登録・管理・集計する Rails 8 アプリケーション。寺院等の物品販売業務を支援。

**主な用途:**
- レシート（販売履歴）の登録・管理
- 帳票（カテゴリ）別のレシート集計
- 商品種類別の明細集計とCSV/PDF出力

---

## 2. 技術スタック

| 分類 | 技術 |
|------|------|
| 言語 | Ruby 3.4.7 |
| フレームワーク | Rails 8.1.1 |
| DB | SQLite3 |
| フロントエンド | Bootstrap 5.3.3 + Stimulus.js + Turbo |
| アセット | Propshaft + ESM import maps |
| PDF | wicked_pdf 2.8 |
| デプロイ | Kamal + Docker |
| CI | rubocop, brakeman, bundler-audit, minitest |

---

## 3. アーキテクチャ評価

### モデル層

- `Book` - 帳票管理。`current()` で現在帳票取得、`use!` で互斥制御
- `Item` - 商品マスター（コード・名前・価格・可変価格フラグ）
- `Receipt` - レシート。`accepts_nested_attributes_for` で明細を一括管理
- `ReceiptDetail` - 明細。`before_validation` で価格同期・item_type 自動推定

**設計上の良い点:**
- `before_validation` コールバックで自動計算を統一
- 固定価格の強制上書き（`apply_item_value`）がモデル層に閉じている
- `Book#use!` で `UPDATE ALL + UPDATE` によるトランザクション安全な帳票切り替え

### コントローラ層

- 薄く保たれており、Rails 規約に準拠
- `params.expect()` で厳密なパラメータホワイトリスト
- `respond_to` で HTML/JSON 両対応

### JavaScript（Stimulus）

- `receipt_form_controller.js`（333行）が最も複雑：リアルタイム合計計算、商品サジェスション、値フィールドロック
- `item_filter_controller.js` は localStorage で UI 状態を永続化
- Flash animation（`flash-highlight`）でユーザーへの変更通知

---

## 4. 強み

1. **Stimulus 活用が秀逸** - リアルタイム UI 計算、サジェスション、localStorage 永続化など UX 品質が高い
2. **CI 自動化完備** - `bin/ci` でスタイル・セキュリティ・テストを一括実行
3. **セキュリティ基本対策** - CSRF、パラメータホワイトリスト、SQLi 対策（`sanitize_sql_like`）、定期スキャン
4. **集計機能の実用性** - 商品別・種類別の2方式集計、CSV/PDF/HTML の3フォーマット出力
5. **コミット履歴が明確** - 機能単位の小さいコミット、133コミットで追跡しやすい

---

## 5. 問題点・改善点

### 優先度：高

#### 5-1. モデルテストの不足

```
test/models/book_test.rb         → 空
test/models/item_test.rb         → 空
test/models/receipt_test.rb      → 空
test/models/receipt_detail_test.rb → 1個のみ
```

`before_validation` コールバック、バリデーション、エッジケースのユニットテストが皆無。
コントローラ統合テストが51個あるのに対し、モデルテストが実質1個は不均衡。

**改善案:** 各モデルにバリデーション・コールバック・境界値テストを追加する。

#### 5-2. `receipt_form_controller.js` の肥大化（333行）

1ファイルに複数の責務が混在している（合計計算、商品検索、サジェスション、フィールドロック）。
保守性・テスト性が低い。

**改善案:** 責務ごとにコントローラを分割する。
```
receipt_form_controller.js      → 合計計算のみ
item_suggestion_controller.js   → 商品サジェスション
```

#### 5-3. ITEM_TYPE_LABELS のハードコード

```ruby
# app/helpers/application_helper.rb
ITEM_TYPE_LABELS = { "0" => "聖明王院", "1" => "護摩センター", ... }
```

施設名が定数にハードコードされており、変更に弱い。

**改善案:** DB テーブル化または `config/settings.yml` に外出し。

### 優先度：中

#### 5-4. 認証・認可の欠如

ローカル利用前提だが、Web に公開する場合は全操作が無認証でアクセス可能。

**改善案:** `devise` + `cancancan` で認可層を追加。

#### 5-5. CSV/PDF 生成の同期処理

大量データ時に UI がブロックする可能性がある。

**改善案:** Active Job で非同期化、ダウンロードリンクをメールまたは通知で渡す。

#### 5-6. エラーハンドリングの粗さ

```ruby
# maintenance_controller.rb
rescue StandardError => e
```

StandardError を一括キャッチしており、本番環境での追跡が困難。

**改善案:** 例外クラスを限定し、ログ出力を詳細化する。

### 優先度：低

#### 5-7. Service Object の欠如

CSV インポートや明細再同期ロジックが Rake タスク・コントローラに直接記述されている。

**改善案:**
```ruby
# app/services/items_importer.rb
class ItemsImporter
  def initialize(csv_path) = @csv_path = csv_path
  def call = # インポートロジック
end
```

#### 5-8. キャッシング未実装

商品マスター（`Item.order(:item_code)`）は変更頻度が低いが毎回クエリ発行。
Rails.cache で短期キャッシュするとパフォーマンスが改善する。

#### 5-9. 国際化（i18n）未対応

日本語がビューにハードコードされている。将来の多言語対応を考慮するなら `config/locales/ja.yml` へ移行が望ましい。

---

## 6. セキュリティチェックリスト

| 項目 | 状態 | コメント |
|------|------|---------|
| CSRF 対策 | ✓ 実装済み | Rails デフォルト |
| パラメータホワイトリスト | ✓ 実装済み | `params.expect()` 使用 |
| SQL インジェクション対策 | ✓ 実装済み | `sanitize_sql_like` 使用 |
| XSS 対策 | ✓ 実装済み | ERB auto-escape |
| 脆弱性スキャン | ✓ CI 組み込み | brakeman, bundler-audit |
| 認証 | ✗ 未実装 | ローカル利用前提 |
| レート制限 | ✗ 未実装 | 公開環境では要対応 |

---

## 7. パフォーマンスチェックリスト

| 項目 | 状態 | コメント |
|------|------|---------|
| N+1 クエリ対策 | ✓ 部分対応 | `includes(:receipt_details)` 実装済み |
| インデックス | △ 要確認 | マイグレーションを詳細確認していない |
| キャッシング | ✗ 未実装 | 商品マスター等に有効 |
| 非同期処理 | ✗ 未実装 | CSV/PDF 生成で有効 |

---

## 8. テスト評価

| 分類 | テスト数 | 評価 |
|------|--------|------|
| コントローラ統合テスト | 43個 | ✓ 充実 |
| モデルユニットテスト | 1個 | ✗ 要強化 |
| Rake タスクテスト | 2個 | ✓ 適切 |
| システムテスト（Capybara） | 0個 | △ 必要なら追加 |

---

## 9. 総合評価

| 項目 | 評価 | コメント |
|------|------|---------|
| アーキテクチャ | ★★★★ | Rails 規約準拠、適切なレイヤー分離 |
| フロントエンド/UX | ★★★★★ | Stimulus 活用が秀逸 |
| テスト | ★★★ | 統合テスト充実、ユニットテスト不足 |
| セキュリティ | ★★★★ | 基本対策実装済み、認証は用途次第 |
| 保守性 | ★★★ | JS の肥大化と定数のハードコードが課題 |
| パフォーマンス | ★★★ | 現規模では問題なし、スケール時に要検討 |

**総評:** 明確な要件のもとで適切に構築されたRails 8プロジェクト。UX品質が高く、CI自動化も整備されている。次のフェーズとしてモデルテストの強化と `receipt_form_controller.js` のリファクタリングが最優先の改善点。

---

## 10. 推奨アクション（優先順位順）

1. **モデルユニットテストを追加** - バリデーション・コールバックのテストカバレッジ向上
2. **`receipt_form_controller.js` を分割** - 333行を責務別に複数コントローラへ
3. **`ITEM_TYPE_LABELS` を設定ファイルへ移行** - ハードコードされた施設名を外出し
4. **エラーハンドリングを精緻化** - 例外クラスを限定、ログ詳細化
5. **CSV/PDF 生成の非同期化** - Active Job で UX 改善（大量データ時）
## 2026-06-09 作業記録・引き継ぎ

- `report_groups`を追加し、商品から任意で参照する構成にした。
- グループ初期値は`db/report_groups.csv`、商品対応は`db/report_group_id.csv`から投入する。
- `report_group_id.csv`の`205002`と`201004`は重複しているため、先に記載された専用グループを採用する。
- 入金報告書は`item_type` 1・2を護摩センター、7・8を祈願会・内陣奉ト占として集計する。
- 入金報告書は帳票フィルタに対応し、HTML・CSV・PDFを出力できる。
- 検証結果: `PARALLEL_WORKERS=1 bin/rails test`は103件・298 assertions・失敗0。RuboCop違反なし。
- 本番反映時は`bin/rails db:migrate`を実行する。
## 2026-06-09 scan_ruby修正記録

- 原因は`Brakeman`ではなく`bundler-audit`による既知脆弱性検出。
- Railsを8.1.3、Pumaを8.0.2、Rackを3.2.6へ更新した。
- Nokogiri、Addressable、ERB、JSON、Loofah、net-imap、rack-sessionも安全版へ更新した。
- 最新の`ruby-advisory-db`で`No vulnerabilities found`を確認した。
- `HOME=/tmp PARALLEL_WORKERS=1 bin/ci`は全項目成功。Railsテストは103件・300 assertions・失敗0。
