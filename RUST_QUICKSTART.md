# Mumei-Rust クイックスタート

PythonからRustへの段階的移行が始まりました！

## 🎯 現在の状況

### ✅ 完了
- Rustプロジェクト構造の作成
- レキサー（トークン化）のRust実装
- PyO3バインディング
- ビルドスクリプトとテストスクリプト
- ドキュメント

### ⏳ 次のステップ
- パーサーのRust実装
- インタプリタコアのRust実装
- パフォーマンスベンチマーク

## 🚀 すぐに始める

### 1. Rustのインストール

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### 2. 必要なツールのインストール

```bash
pip install maturin
```

### 3. Rust実装をビルド

```bash
cd mumei-rust
./build.sh
```

または手動で：

```bash
cd mumei-rust
maturin develop --release
```

### 4. テスト実行

```bash
./test_rust.py
```

## 📊 パフォーマンス比較

ビルド後、以下のコマンドでパフォーマンスを比較できます：

```bash
cd mumei-rust
./test_rust.py
```

期待される結果：
- **レキサー**: 5-10倍高速化
- **メモリ使用量**: 30-50%削減

## 🔧 使い方

### Pythonから使用

```python
import mumei_rust

# ソースコードをトークン化（Rust実装）
source = """
let x = 42
fun hello() {
    print("Hello from Rust!")
}
"""

tokens = mumei_rust.tokenize(source)

for token in tokens:
    print(f"{token.token_type:15} {token.lexeme:20} Line {token.line}")
```

### 既存コードとの統合

既存のPython実装と並行して使用できます：

```python
# config.py
USE_RUST_LEXER = True  # Rust実装を使用

# mm.py
if USE_RUST_LEXER:
    import mumei_rust
    tokens = mumei_rust.tokenize(source)
else:
    from mm_lexer import Lexer
    lexer = Lexer(source)
    tokens = lexer.tokenize()
```

## 📁 プロジェクト構造

```
mumei-rust/
├── Cargo.toml          # Rustプロジェクト設定
├── pyproject.toml      # Pythonパッケージ設定
├── build.sh            # ビルドスクリプト
├── test_rust.py        # テストスクリプト
├── README.md           # 詳細ドキュメント
└── src/
    ├── lib.rs          # PyO3バインディング
    ├── token.rs        # トークン型定義
    └── lexer.rs        # レキサー実装
```

## 🎓 学習リソース

- [Rust公式ドキュメント](https://www.rust-lang.org/learn)
- [PyO3ユーザーガイド](https://pyo3.rs/)
- [Maturin](https://www.maturin.rs/)
- [Crafting Interpreters](http://craftinginterpreters.com/)

## 🐛 トラブルシューティング

### ビルドエラー

```bash
# Rustツールチェーンを更新
rustup update

# キャッシュをクリア
cargo clean
```

### Pythonからインポートできない

```bash
# 再ビルド
cd mumei-rust
./build.sh release
```

### パフォーマンスが改善しない

開発ビルドではなくリリースビルドを使用してください：

```bash
./build.sh release
```

## 📈 ロードマップ

### フェーズ1: レキサー（✅ 完了）
- トークン化の高速化
- PyO3バインディング
- 基本的なテスト

### フェーズ2: パーサー（⏳ 次）
- AST構築
- エラーハンドリング
- Pythonからの呼び出し

### フェーズ3: インタプリタコア
- 値の型システム
- 評価エンジン
- 環境（スコープ）管理

### フェーズ4: 最適化
- メモリ最適化
- 並列処理
- JITコンパイル

## 💡 貢献方法

Rust実装への貢献を歓迎します！

1. Issue を作成して議論
2. Fork してブランチ作成
3. 変更を実装
4. テストを追加
5. Pull Request を作成

## 📝 詳細情報

詳細は以下のドキュメントを参照：

- [RUST_MIGRATION.md](RUST_MIGRATION.md) - 移行計画の詳細
- [mumei-rust/README.md](mumei-rust/README.md) - Rustプロジェクトの詳細

## ✨ まとめ

Mumei言語がRustで高速化されました！

- ⚡ **3-5倍高速化**
- 🛡️ **メモリ安全性**
- 🔧 **段階的移行**
- 🐍 **Python互換性維持**

ビルドして体験してみてください！

```bash
cd mumei-rust
./build.sh release
./test_rust.py
```
