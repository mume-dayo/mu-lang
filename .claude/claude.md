# Mumei Language Project

## プロジェクト概要
Pythonベースの新しいプログラミング言語「Mumei（むめい）」の実装プロジェクト。
簡潔な構文と強力な機能を持つインタプリタ言語。

## 技術スタック
- 言語: Python 3.x
- レキサー: mm_lexer.py
- パーサー: mm_parser.py
- インタプリタ: mm_interpreter.py
- 拡張機能: Discord bot、HTTP、ファイルI/O、標準ライブラリ

## コーディング規約
- 日本語コメントを使用
- docstringは日本語で記述
- クラス名はPascalCase
- 関数名はsnake_case
- 定数は大文字のSNAKE_CASE

## 実装済み機能
- 基本的なデータ型（数値、文字列、真偽値、None、リスト、辞書）
- 制御構文（if/elif/else、while、for、break、continue、pass）
- 関数定義とクロージャ
- ラムダ式
- リスト内包表記
- 辞書内包表記
- スライス記法
- 複数代入とアンパック
- 可変長引数（*args）
- クラスとOOP（継承、インスタンス化）
- 例外処理（try/catch/finally、throw）
- 三項演算子
- ウォルラス演算子（:=）
- with文
- match/case文
- 非同期処理（async/await）
- Discord bot機能
- HTTP リクエスト
- ファイルI/O
- 環境変数アクセス
- 標準ライブラリ（数学、文字列、リスト操作など）
- デバッグユーティリティ


## 今後実装予定の機能（優先順位順）
1. ジェネレーターとyield
2. import/moduleシステム
3. デコレーター
4. 型アノテーション
5. set（集合）型
6. アサーション（assert文）
7. 列挙型（Enum）
8. REPLの実装
9. スタックトレースとエラーメッセージの改善
10. プロパティ（getter/setter）

## ワークフロー
1. 機能実装時は以下の順で作業:
   - mm_lexer.py: トークン定義
   - mm_parser.py: AST ノード定義とパース処理
   - mm_interpreter.py: 評価処理
   - vscode-mumei/syntaxes/mumei.tmLanguage.json: シンタックスハイライト
   - examples/: サンプルコード作成
   - git commit & push

2. コミットメッセージは日本語で記述する
3. コミットメッセージには署名やクレジット（🤖 Generated with... や Co-Authored-By: Claude...）を含めない
4. サンプルコードは必ず作成し、examples/フォルダに配置
5. Discord bot機能で実用的なものがあれば、examplesフォルダに追加する

## 注意事項
- 既存の機能を壊さないように注意
- 新機能追加時は必ずサンプルコードで動作確認
- Pythonの構文に近づけつつ、独自性も保つ

## タスク完了後の報告形式
実装が終了した後は、必ず以下の形式で日本語で報告すること：

### 実装した機能
- 何を実装したか詳細に説明
- どのファイルを変更したか
- どのような動作をするか

### 今後の改善点
- 次に実装すべき機能
- 現在の実装の問題点や改善案
- より良い実装方法の提案
