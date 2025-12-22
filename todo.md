★は優先順位高い
★レシート登録画面で、最初の1枚を入力して保存して、次のレシートを入力する時に、自動的に次の番号が入るように
★1ヶ月でまとめたら、次の月から新しいフォルダ？になるように

・レシート一覧は、ボタンで「昇順」「降順」の切り替えができるように
・レシート一覧の「点数合計」は「道具の種類の合計」になるように
・レシートナンバーの上位に2025.4、下位に1から始まるレシートナンバーを入力できるように
・レシートナンバーを途中で追加しても、番号どおりに並ぶように
・レシート編集をすると、コードは出ても商品名が出ないので、商品名も出るように

・レシート入力して合計が出たら、貼付した還付金集計にも反映させたい。
その場合、形式は何でもよく、道具の数、合計金額、還付額、寺(御神水、観音堂、太明星)に納入する額がわかればよい。

・商品コード一覧にフリーの欄がいくつかほしい
・レシート登録画面のコード一覧を3行にする、または文字を小さくして全体が見えるようにしたい
・レシート登録画面のコード一覧を親番号ごとに分けてほしい

---

-[x] レシート登録画面で、最初の1枚を入力して保存して、次のレシートを入力する時に、自動的に次の番号が入るように
-[x] ★1ヶ月でまとめたら、次の月から新しいフォルダ？になるように
-[x] レシート一覧は、ボタンで「昇順」「降順」の切り替えができるように
-[x] レシート一覧の「点数合計」は「道具の種類の合計」になるように
-[x] レシートナンバーの上位に2025.4、下位に1から始まるレシートナンバーを入力できるように
-[x] レシートナンバーを途中で追加しても、番号どおりに並ぶように
-[x] レシート編集をすると、コードは出ても商品名が出ないので、商品名も出るように
-[x] レシート登録(/receipts/new)の商品IDを商品コード表示
-[x] 商品種類と商品コードの関連付けを修正
-[x] 種類別明細集計：商品種類毎の明細集計画面を作成
 商品種類別明細集計という画面を作って。内容的には、レシート明細集計とほぼ同じだが、帳票選択ドロップダウンリストのような商
  品種類ドロップダウンを追加して、選択した帳票・商品種類のみを集計表示する。カラムは商品コード、商品名、合計個数、合計金
  額、還付単価
-[x] レシート登録後にitems の item_type, name, refund, value を変更してしまったので、items のデータを元にreceipt_details を更新して、さらにそれを元にreceipts を更新するタスクを作成
-[x] 現状確認。レシートを保存するときに更新される情報を一覧にして
-[x] レシート名の自動採番をルール変更。利用中の帳票の中で一番大きな数字にプラス１した値を仕様する
-[x] /receipt_details/summary_by_item_type にPDF出力を追加したいが、どのgemを使えばいいと思う？




› 本番サーバのproduction.sqlite3 を開発環境のdevelopment.sqlite3 にコピーしたいので、手順を書いて


• SQLiteファイルを直接コピーする手順（安全重視の流れ）です。

  1. 本番側でアプリ停止
      - Railsサーバやジョブ実行プロセスを止め、DBファイルへの書き込みが発生しない状態にする。
  2. 本番DBを安全に取得
      - 本番サーバでダンプを作るのが壊れにくいです。例:

        cd /path/to/app
        sqlite3 db/production.sqlite3 ".backup 'production_backup.sqlite3'"
      - あるいは .dump でも:

        sqlite3 db/production.sqlite3 ".dump" > production_dump.sql
  3. 開発環境に持ってくる
      - バックアップファイル(production_backup.sqlite3)またはダンプ(production_dump.sql)を SCP/rsync で開発マシンにコピー。
  4. 開発環境で反映
      - 既存の開発DBを退避または削除（必要に応じてバックアップ）:

        mv db/development.sqlite3 db/development.sqlite3.bak   # 必要なら
      - バックアップファイルを使う場合:

        cp /path/to/production_backup.sqlite3 db/development.sqlite3
      - ダンプを使う場合は空ファイルから再構築:

        rm -f db/development.sqlite3
        sqlite3 db/development.sqlite3 < production_dump.sql
  5. マイグレーション整合性確認
      - 開発環境で bin/rails db:migrate を実行し、スキーマが開発コードと一致していることを確認。
  6. アプリ起動と動作確認
      - bin/rails db:migrate 後、bin/rails s で起動して動作確認。

  ポイント:

  - 本番データを持ち込む際は機密・個人情報の扱いに注意。
  - ダンプ方式の方が壊れにくく、SQLiteバージョン差にも強いです。
  - キャッシュ/セッション用の SQLite（例: production_cache.sqlite3）は通常コピー不要です。



レシートプリンタ

これは欲しい
TM-m30III-H
HTTP通信によるXML印刷機能（ePOS-Print）に対応
https://item.rakuten.co.jp/fksystem/tm-m303-h/

ドロア付きのプリンタもあった。値段かわらねえ
https://item.rakuten.co.jp/smaregi/a001-10401/

安くてたぶん使えそう
ESC/POS
https://item.rakuten.co.jp/tsurunooshiro/rmdy02/



 Webアプリからレシートプリンタにレシートの印刷とかできる？


• I'm summarizing key approaches: use print-friendly HTML with window.print for basic needs; for ESC/POS, generate prints
  server-side (e.g., ruby-escpos) and send via CUPS or network port; use WebUSB/WebSerial on Chrome with user permission for
  direct browser printing; Web Bluetooth is less reliable. These cover typical browser-to-receipt printer workflows.

─ Worked for 17s ───────────────────────────────────────────────────────────────────────────────────────────────────────────

• 可能です。ただしブラウザだけで直接レシートプリンタを制御するのは制約が多いので、実現方法を用途別にまとめます。

  ### 1) シンプルに「印刷ダイアログ経由」で出す方法

  - Railsで印刷用HTMLを用意し、<link media="print"> と印刷専用CSS（幅58/80mm、余白0、背景オフ）を作成。
  - 画面で window.print() を呼ぶ（「印刷」ボタン）。
      - 利点: ブラウザ標準で簡単。
      - 注意: ユーザーがプリンタを手動選択。ESC/POSコマンドは使えない。

  ### 2) サーバーからレシートプリンタへ直接送る方法（ESC/POS）

  - レシートプリンタがLAN/USBでサーバにつながっている場合、Ruby の escpos / escpos-printer gem などで ESC/POS コマンドを生
    成し、
      - LANプリンタ: socket.print で 9100/TCP に送信
      - USBプリンタ: CUPS 経由で Raw キューに送信（lp -d printer_name -o raw file.escpos）
  - Rails側で「印刷」APIを用意し、ジョブをサーバーで実行。
      - 利点: ダイアログなし、レイアウトが安定。
      - 注意: プリンタをサーバー側に常時接続する運用が必要。

  ### 3) ブラウザから直接デバイスに送る方法（実験的）

  - Chrome限定で WebUSB / WebSerial / WebHID を使い、プリンタが対応していればブラウザから ESC/POS を送る。
      - 要求: HTTPS配信、ユーザーが毎回デバイス許可、ブラウザ・OS・プリンタの相性チェックが必要。
      - 小規模・クローズド環境なら現実的だが、運用ハードルは高め。

  ### 4) ベンダーのクラウドプリントSDK

  - 一部のレシートプリンタ（EPSON ePOS SDK 等）はクラウド／ローカルSDKを提供。JSでプリンタサービスに送信して印刷。
      - 利点: 対応プリンタなら実績あり。
      - 注意: ベンダー依存・設定がやや重い。

  ———

  おすすめの始め方（運用容易さ順）

  1. まずは「印刷専用HTML + CSS + window.print()」で見た目を整える。
  2. 無人印刷・自動印刷が必要になったら、サーバー側で ESC/POS を吐いてプリンタに直接送る方式を検討（LANプリンタ + Rawキュー
     が簡単）。
  3. 店舗PCから直接出したいが自動化もしたい場合は、ローカル常駐の小さな「印刷エージェント」（Ruby/Node/Go）を作り、Webからは
     HTTPでそのエージェントに印刷ジョブを投げる構成が安定します。

  用途や設置環境（サーバーとプリンタの接続形態、ブラウザ種、セキュリティポリシー）を教えてもらえれば、もう少し具体的な手順を
  提案できます。

