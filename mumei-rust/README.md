# Mumei Language - Rust Implementation

高性能なRustベースのMumei言語インタプリタ実装

## 📋 概要

Mumei言語のPython実装から段階的にRustに移行することで、5-10倍のパフォーマンス向上を実現するプロジェクト。

## 🎯 実装状況

### ✅ 完了

#### 1. レキサー（Lexer）
- **ファイル**: `src/lexer.rs`, `src/token.rs`
- **機能**:
  - 60種類以上のトークンタイプをサポート
  - インデントベースの構文解析
  - 文字列リテラル（シングル/ダブルクォート、エスケープシーケンス）
  - 数値リテラル（整数、浮動小数点）
  - コメント処理
  - エラーハンドリング（行番号・カラム番号付き）

#### 2. パーサー（Parser）
- **ファイル**: `src/parser.rs`, `src/ast.rs`
- **機能**:
  - 再帰下降パーサー
  - 演算子優先順位の正確な処理
  - 30種類以上のASTノードタイプ
  - 式と文の完全なパース
  - エラーリカバリー

**サポートする構文**:
- リテラル: 数値、文字列、真偽値、null
- コレクション: リスト `[1, 2, 3]`、辞書 `{"key": "value"}`
- 演算子: 算術 `+, -, *, /, %, **`、比較 `<, >, <=, >=, ==, !=`、論理 `and, or, not`
- 変数: `let x = 10`, `const PI = 3.14`
- 制御構造: `if-elif-else`, `while`, `for-in`
- 関数: `fun name(params) { body }`
- クラス: `class Name { methods }`
- 例外処理: `try-catch`
- その他: `return`, `break`, `continue`

#### 3. 値システム（Value System）
- **ファイル**: `src/value.rs`
- **機能**:
  - 10種類の値タイプ
    - プリミティブ: Number, String, Boolean, Null
    - コレクション: List, Dictionary
    - 実行可能: Function, NativeFunction
    - オブジェクト指向: Class, Instance
  - 算術演算メソッド（add, subtract, multiply, divide, modulo, power）
  - 比較演算メソッド（less_than, greater_than, equals）
  - 型変換・チェック
  - Truthiness評価

#### 4. 環境管理（Environment）
- **ファイル**: `src/environment.rs`
- **機能**:
  - スコープ管理（ネストしたスコープ）
  - 変数の定義・参照・代入
  - 定数（const）のサポート
  - クロージャのサポート
  - エラーハンドリング（未定義変数、定数への代入）

#### 5. インタプリタコア（Interpreter）
- **ファイル**: `src/interpreter.rs`
- **機能**:
  - ASTの評価エンジン
  - 全てのASTノードタイプのサポート
  - 関数呼び出し（ユーザー定義・ネイティブ）
  - スコープ管理
  - エラーハンドリング

#### 6. 組み込み関数（Built-ins）
- **ファイル**: `src/builtins.rs`
- **関数一覧**:
  - **I/O**: `print`, `println`, `input`
  - **型変換**: `str`, `num`, `bool`, `type`
  - **コレクション**: `len`, `push`, `pop`, `keys`, `values`
  - **数学**: `abs`, `floor`, `ceil`, `round`, `sqrt`, `min`, `max`
  - **文字列**: `upper`, `lower`, `split`, `join`
  - **ユーティリティ**: `range`, `assert`
  - **定数**: `PI`, `E`

#### 7. Python連携（PyO3）
- **ファイル**: `src/lib.rs`
- **公開API**:
  - `tokenize(source)` - トークン化
  - `parse(source)` - パース（デバッグ出力）
  - `parse_pretty(source)` - パース（整形出力）
  - `evaluate(source)` - 完全な評価
  - `run(source)` - エイリアス

### ⏳ 残りのタスク

1. **Rustのインストールとビルド**
   - Rustをインストール: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
   - ビルド: `./build_rust.sh`

2. **Python統合のテスト**
   - PyO3バインディングの動作確認
   - Python側でのフォールバック実装

3. **パフォーマンスベンチマーク**
   - Python実装 vs Rust実装の速度比較
   - メモリ使用量の測定

4. **既存Pythonコードとの統合**
   - mm_async.py、mm_http.py、mm_file.pyとの連携
   - Discord.pyモジュールのサポート

## 🏗️ アーキテクチャ

```
Source Code (*.mu)
       ↓
   Lexer (tokenize)
       ↓
    Tokens
       ↓
   Parser (parse)
       ↓
      AST
       ↓
 Interpreter (evaluate)
       ↓
     Result
```

## 🚀 ビルド方法

### 前提条件

- Rust 1.70以上
- Python 3.8以上
- maturin（Pythonパッケージ）

### インストール

```bash
# Rustのインストール
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# maturinのインストール
pip install maturin

# ビルド
./build_rust.sh

# または直接
cd mumei-rust
cargo build --release

# Python用にインストール
maturin develop --release
```

## 🧪 テスト

```bash
# Rustのテスト
cargo test

# Python統合テスト
python test_rust_integration.py
```

## 📊 パフォーマンス目標

| 処理 | Python実装 | Rust実装 | 改善率 |
|------|-----------|----------|--------|
| レキサー | 1.0x | 8-10x | 800-1000% |
| パーサー | 1.0x | 5-7x | 500-700% |
| 評価 | 1.0x | 3-5x | 300-500% |
| 総合 | 1.0x | 5-10x | 500-1000% |

## 📝 使用例

### Python経由で使用

```python
import mumei_rust

# トークン化
tokens = mumei_rust.tokenize("let x = 42")
print(tokens)

# パース
ast = mumei_rust.parse("let x = 42")
print(ast)

# 評価
result = mumei_rust.evaluate("""
let x = 10
let y = 20
x + y
""")
print(result)  # "30"
```

### Mumei言語コード

```mumei
// 基本的な計算
let x = 10
let y = 20
print(x + y)  // 30

// 関数定義
fun factorial(n) {
    if (n <= 1) {
        return 1
    }
    return n * factorial(n - 1)
}

print(factorial(5))  // 120

// リスト操作
let numbers = [1, 2, 3, 4, 5]
for (let n in numbers) {
    print(n * 2)
}
```

## 🔧 トラブルシューティング

### Rustがインストールされていない

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### ビルドエラー

```bash
# 依存関係の更新
cargo update

# クリーンビルド
cargo clean
cargo build --release
```

### Python統合エラー

```bash
# maturinの再インストール
pip install --upgrade maturin

# 開発モードでインストール
maturin develop --release
```

## 📚 実装の詳細

### メモリ管理

- `Rc<RefCell<T>>` を使用した共有可能な可変参照
- スマートポインタによる自動メモリ管理
- クロージャのキャプチャ

### エラーハンドリング

- `Result<T, String>` による型安全なエラー処理
- 詳細なエラーメッセージ（行番号・カラム番号付き）
- パーサーのエラーリカバリー

### PyO3統合

- ゼロコピーでのデータ受け渡し
- Python例外への自動変換
- GIL（Global Interpreter Lock）の適切な処理

## 🎓 参考資料

- [Rust公式ドキュメント](https://doc.rust-lang.org/)
- [PyO3ドキュメント](https://pyo3.rs/)
- [Crafting Interpreters](https://craftinginterpreters.com/)

## 📄 ライセンス

MIT License

## 👥 Contributors

- Mumei Language Team
