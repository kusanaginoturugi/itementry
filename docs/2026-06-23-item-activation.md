# 道具無効化と入金報告グループ登録

## 作業計画

- 入金報告グループマスタに新規登録画面と保存処理を追加する。
- 道具マスタに有効/無効状態を追加し、削除操作は無効化として扱う。
- レシート入力と道具コード一覧の候補は有効な道具だけに絞る。
- 変更に対応する controller test を追加し、関連テストと RuboCop を通す。

## 作業記録

- `report_groups` に `new/create` を追加し、フォームを partial 化した。
- `items.is_active` を追加する migration を作成し、既存道具は有効のまま移行する。
- `ItemsController#destroy` は物理削除ではなく `is_active: false` に更新する処理へ変更した。
- 無効化した道具は `items/codes`、レシート入力の候補データ、`items/lookup` から除外した。
- 道具一覧と詳細画面に状態表示、有効化/無効化操作を追加した。
- `origin/main` の CSS 更新を fast-forward で取り込んだ。

## 引き継ぎ

- DB反映には `bin/rails db:migrate` が必要。
- 全体テストは sandbox の DRb 制限を避けるため `PARALLEL_WORKERS=0 bin/rails test` で確認済み。
- 通常の `bin/rails test` はこの環境だと `/tmp/druby2.0` の UNIX socket 作成で失敗する可能性がある。
- 作業前から未追跡の `db/入金報告書記載用.ods` と `db/八大明王如意棒_20260515.csv` は今回のコミット対象外。
