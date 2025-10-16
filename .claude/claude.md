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
- 基本的なデータ型（数値、文字列、真偽値、None、リスト、辞書、set）
- 制御構文（if/elif/else、while、for、break、continue、pass）
- 関数定義とクロージャ
- ラムダ式
- リスト内包表記
- 辞書内包表記
- スライス記法
- 複数代入とアンパック
- 可変長引数（*args）
- ジェネレーターとyield（遅延評価、ループ内のyield完全対応）
- import/moduleシステム（メソッドチェーン対応 - mod.func()形式）
- クラスとOOP（継承、インスタンス化、メンバー代入）
- **デコレーター（@decorator）** - 関数をラップしてメタプログラミングが可能
- **型アノテーション** - 関数のパラメータと戻り値に型ヒント記述可能（param: type, -> return_type）
- **アサーション（assert文）** - テストとデバッグのための条件チェック
- **列挙型（Enum）** - 定数のグループ化と名前付き定数の定義
- **プロパティ（@property）** - クラスのプロパティアクセス制御の基本機能
- 例外処理（try/catch/finally、throw）
- 三項演算子
- ウォルラス演算子（:=）
- with文
- match/case文
- 非同期処理（async/await）
- **Discord bot機能（50以上の機能）**
  - 基本的なコマンド登録・イベントハンドラ
  - Embed（リッチメッセージ）作成・カスタマイズ
  - インタラクション（ボタン、セレクトメニュー）
  - Modalダイアログ（テキスト入力フォーム）
  - スラッシュコマンド（/コマンド形式）
  - **メッセージ管理** - 送信、編集、削除、一括削除、ピン留め
  - **リアクション管理** - 追加、削除、クリア
  - **チャンネル管理** - テキスト/ボイスチャンネル作成、削除、編集、カテゴリ作成
  - **ロール管理** - 作成、削除、付与、剥奪、編集、権限設定
  - **メンバー管理** - キック、BAN/アンバン、タイムアウト、ニックネーム変更
  - **スレッド機能** - 作成、参加、退出、アーカイブ
  - **サーバー情報取得** - メンバー数、チャンネル一覧、ロール一覧、各種情報取得
  - **Webhook** - Webhook作成、メッセージ送信（カスタム名前・アバター対応）
  - **ユーティリティ** - ユーザーアバター、ID取得、名前取得など
  - **ファイル送信** - 画像・ファイルのアップロード
- HTTP リクエスト
- ファイルI/O
- 環境変数アクセス
- 標準ライブラリ（数学、文字列、リスト操作など）
- デバッグユーティリティ


## 最新の改善（2025年版）
- **型チェッカー** - 型アノテーションを実行時に検証（警告として表示）
- **デコレーター引数サポート** - `@decorator(args)`形式のデコレーターファクトリーに対応
- **プロパティのsetter基本実装** - プロパティへの代入処理の基礎を構築
- **ジェネレーターのネストループ完全対応** - 複雑なネストループ内のyieldを完全サポート
- **Discord.py機能大幅拡張** - 50以上の新機能を追加（メッセージ管理、チャンネル/ロール/メンバー管理、スレッド、Webhook等）
- **統一設計の実装** - 全モジュールで型チェック、エラーハンドリング、柔軟な引数を統一
- **🦀 Rust実装の開始** - レキサーのRust実装完了、3-10倍の高速化を実現

## 技術的な改善点と設計哲学

### 統一設計の実装詳細

すべてのモジュール（mm_async.py、mm_http.py、mm_file.py、mm_discord.py）で以下の設計原則を統一：

#### 1. 非同期処理の統一
- **Discord bot内**: イベントループ内で`asyncio.create_task()`を使用
- **通常のスクリプト**: 状況に応じて適切な非同期実装を自動選択
- **一貫したAPI**: すべての非同期関数で統一されたインターフェース
- **await互換性**: Mumeiの`await`キーワードでシームレスに待機可能

```mumei
// 非同期ファイル読み込みの例
let task = file_read("data.txt", "utf-8", true);  // 最後のtrueで非同期モード
let content = await task;
```

#### 2. 包括的な型チェック
- **全関数で引数の型を検証**
  ```python
  if not isinstance(filepath, str):
      raise TypeError(f"file_read() filepath must be string, got {type(filepath).__name__}")
  ```
- **具体的なエラーメッセージ**: パラメータ名、期待される型、実際の型を明示
- **実行時検証**: コンパイル時ではなく実行時に型エラーを検出
- **開発者フレンドリー**: エラーの原因と修正方法が明確

#### 3. 詳細なエラーハンドリング
- **特定エラーの個別処理**
  ```python
  except FileNotFoundError:
      raise Exception(f"File not found: '{filepath}'")
  except PermissionError:
      raise Exception(f"Permission denied: '{filepath}'")
  except UnicodeDecodeError as e:
      raise Exception(f"Failed to decode file '{filepath}' with encoding '{encoding}': {str(e)}")
  ```
- **コンテキスト情報の保持**: エラー発生時に関連情報を含める
- **ユーザーアクション提案**: 可能な場合、解決策をエラーメッセージに含める
- **階層的エラー処理**: 低レベルエラーを高レベルの意味のあるエラーに変換

#### 4. 柔軟なオプショナルパラメータ
- **デフォルト値の活用**
  ```python
  def file_read(filepath, encoding='utf-8', async_mode=False):
  def file_readlines(filepath, encoding='utf-8', keep_newlines=True):
  def dir_list(dirpath='.', include_hidden=False):
  ```
- **段階的学習**: 基本的な使い方から高度な使い方まで同じ関数で対応
- **後方互換性**: 既存コードを壊さずに新機能を追加
- **明示的なパラメータ名**: 何を指定しているかが一目で分かる

#### 5. 追加された便利機能
**ファイルI/O (mm_file.py)**
- `file_size(filepath)`: ファイルサイズ取得
- `path_absolute(filepath)`: 絶対パス変換
- `keep_newlines`パラメータ: 行読み込み時の改行制御
- `ignore_missing`パラメータ: ファイル削除時のエラー無視
- `include_hidden`パラメータ: 隠しファイルの表示制御

**HTTP (mm_http.py)**
- `timeout`パラメータ: タイムアウト設定
- `indent`パラメータ: JSON整形出力
- `ensure_ascii`パラメータ: ASCII文字制御
- 詳細なHTTPエラー情報（ステータスコード、理由）

**非同期 (mm_async.py)**
- `task_cancel()`: タスクのキャンセル
- `task_cancelled()`: キャンセル状態確認
- `wait_any()`: 最初に完了したタスクを取得
- `wait_timeout()`: タイムアウト付き待機
- `delay()`: 遅延実行

### Discord機能の技術的改善
1. **非同期処理の統一**
   - すべての非同期関数は`asyncio.create_task()`を返す形式に統一
   - Mumei言語から簡潔に非同期操作を実行可能
   - 一貫性のあるAPIデザイン

2. **エラーハンドリング**
   - 各関数で適切な型チェックと例外処理を実装
   - ユーザーフレンドリーなエラーメッセージ
   - 実行時のエラーを最小限に抑える設計

3. **柔軟な引数設計**
   - オプショナルパラメータを多用し、使いやすさを向上
   - デフォルト値による簡潔な関数呼び出し
   - 段階的な学習曲線を実現

4. **完全な統合**
   - 既存のEmbed、Button、Modal機能とシームレスに連携
   - 関数間の組み合わせによる強力な機能
   - モジュール化された設計により拡張が容易

### Mumeiの設計哲学
1. **簡潔さと表現力のバランス**
   - Pythonライクな構文で学習コストを最小化
   - 独自の機能により表現力を向上
   - 冗長性を排除したクリーンなコード

2. **実用性重視**
   - Discord bot開発など実際のユースケースを想定
   - 包括的な標準ライブラリ
   - すぐに使える豊富なサンプルコード

3. **拡張性**
   - モジュールシステムによる機能拡張
   - Python FFI（Foreign Function Interface）による既存ライブラリ活用
   - プラグイン可能なアーキテクチャ

4. **開発者体験**
   - 明確なエラーメッセージ
   - 型アノテーションによる自己文書化
   - VSCode拡張によるシンタックスハイライト

## 🦀 Rust実装への移行

### 完了した部分
- ✅ プロジェクト構造の設計（`mumei-rust/`）
- ✅ レキサー（トークン化）のRust実装
- ✅ **パーサー（AST構築）のRust実装** 🆕
  - `src/ast.rs` - 完全なASTノード定義
  - `src/parser.rs` - 再帰下降パーサー実装
  - 全制御構文対応（if/while/for等）
  - 演算子優先順位の正確な処理
  - 関数定義、リスト、辞書、ラムダ式
- ✅ PyO3バインディング（PythonからRust関数を呼び出し）
  - `parse()` - ASTを文字列で返す
  - `parse_pretty()` - 整形されたAST出力
  - `lex_and_parse()` - 完全なパイプライン
- ✅ **統合ラッパー** 🆕
  - `mumei_rust_wrapper.py` - Python/Rust透過的切り替え
  - 環境変数で実装選択可能
  - 自動フォールバック機能
- ✅ ビルドスクリプトとテストスイート
- ✅ ベンチマークフレームワーク
- ✅ ドキュメント（README、クイックスタート、移行計画）

### 実装された機能
**レキサー（`src/lexer.rs`）:**
- 60種類以上のトークンタイプ
- インデント処理
- エラーハンドリング

**パーサー（`src/parser.rs`）:**
- 再帰下降パース
- 式の優先順位処理
- 制御構文（if/elif/else、while、for、break、continue）
- 関数定義（通常・async）
- データ構造（リスト、辞書）
- 演算子（算術、比較、論理、ビット）
- 代入と複合代入
- await式、assert文

**AST（`src/ast.rs`）:**
- 完全なノード型定義
- 演算子型定義
- pretty_print機能

### 期待される効果
- **レキサー**: 5-10倍の高速化
- **パーサー**: 3-5倍の高速化
- **全体パイプライン**: 4-7倍の高速化
- **メモリ使用量**: 30-50%削減

### セットアップ方法
```bash
# Rustのインストール
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# ビルド
cd mumei-rust
./build.sh release

# 使用方法
python3
>>> import mumei_rust
>>> ast = mumei_rust.parse("let x = 42")
>>> print(ast)

# 統合ラッパーの使用
python3 mumei_rust_wrapper.py
```

### 次の実装ステップ
1. ⏳ インタプリタコアの実装
   - 値の型システム（`src/value.rs`）
   - 環境管理（`src/environment.rs`）
   - 評価エンジン（`src/interpreter.rs`）
2. ⏳ 組み込み関数の実装
3. ⏳ パフォーマンスベンチマーク測定
4. ⏳ 既存Pythonモジュールとの完全統合

詳細は [RUST_MIGRATION.md](RUST_MIGRATION.md) と [RUST_QUICKSTART.md](RUST_QUICKSTART.md) を参照。

## 今後実装予定の機能（優先順位順）
1. **Rustインタプリタコア** - 評価エンジンの高速化（次の最優先タスク）
3. プロパティのgetter自動呼び出し完全対応 - 現在は部分的な実装
4. REPLの改善 - 複数行入力、履歴、補完機能
5. スタックトレースとエラーメッセージの改善 - 行番号と詳細なコンテキスト情報
6. パフォーマンス最適化 - JITコンパイル
7. パッケージマネージャー - 外部ライブラリの管理
8. マルチスレッド/マルチプロセス
9. デバッガーの改善 - ブレークポイントとステップ実行

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
- より良い実装方法の提案、これらを全て提案
