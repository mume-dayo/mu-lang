# Mumei言語 Rust実装 セットアップガイド

このガイドでは、Mumei言語のRust実装をセットアップする手順を説明します。

## 📋 前提条件

- macOS、Linux、またはWindows
- Python 3.8以上
- インターネット接続（Rustのインストールに必要）

## 🚀 セットアップ手順

### ステップ 1: Rustのインストール

```bash
# Rustの公式インストーラーを実行
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# シェルを再起動するか、環境変数を読み込む
source $HOME/.cargo/env

# インストール確認
rustc --version
cargo --version
```

**出力例:**
```
rustc 1.75.0 (82e1608df 2024-01-01)
cargo 1.75.0 (1d8b05cdd 2024-01-01)
```

### ステップ 2: Maturinのインストール

Maturinは、RustコードをPythonモジュールとしてビルドするツールです。

```bash
# pipでmaturinをインストール
pip install maturin

# インストール確認
maturin --version
```

### ステップ 3: Rust実装のビルド

#### オプション A: ビルドスクリプトを使用（推奨）

```bash
# プロジェクトルートで実行
./build_rust.sh
```

このスクリプトは以下を自動的に実行します：
- Rustのインストール確認
- リリースビルドの実行
- 成功/失敗の通知

#### オプション B: 手動ビルド

```bash
# mumei-rustディレクトリに移動
cd mumei-rust

# 開発ビルド（デバッグ情報あり、高速コンパイル）
cargo build

# リリースビルド（最適化あり、実行速度最大）
cargo build --release

# Rustテストの実行
cargo test

# Python用にインストール
maturin develop --release
```

### ステップ 4: インストール確認

Pythonでインポートできるか確認します：

```bash
python3 -c "import mumei_rust; print(mumei_rust.__version__)"
```

**出力例:**
```
0.1.0
```

### ステップ 5: テストの実行

#### 統合テスト

```bash
# Python統合テスト
python test_rust_integration.py
```

**期待される出力:**
```
╔══════════════════════════════════════════════════════════╗
║          Mumei Rust実装 統合テスト                      ║
╚══════════════════════════════════════════════════════════╝

============================================================
1. Rustモジュールのインポートテスト
============================================================
✓ mumei_rustモジュールのインポート成功
  バージョン: 0.1.0
  作者: Mumei Language Team

============================================================
2. トークン化テスト
============================================================
...
合計: 7/7 テスト成功
```

#### Mumeiコードテスト

```bash
# Mumeiコードの実行テスト（Rustがビルドされていない場合はPython実装を使用）
python mumei.py test_rust_interpreter.mu
```

### ステップ 6: ベンチマークの実行（オプション）

```bash
# パフォーマンスベンチマーク
python benchmark_rust.py
```

**期待される出力:**
```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    Mumei言語パフォーマンスベンチマーク                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

================================================================================
Rust実装のベンチマーク
================================================================================

算術演算... 平均: 12.34μs, 最小: 10.23μs, 最大: 15.67μs
変数代入... 平均: 23.45μs, 最小: 20.12μs, 最大: 28.90μs
...

================================================================================
パフォーマンス比較
================================================================================

テストケース                   Python           Rust        高速化
--------------------------------------------------------------------------------
算術演算                     123.45μs       12.34μs        10.00x
変数代入                     234.56μs       23.45μs        10.00x
...
--------------------------------------------------------------------------------
平均高速化                                                   7.50x

================================================================================
結論: Rust実装はPython実装の平均 7.50倍 高速です！
================================================================================
```

## 🔧 トラブルシューティング

### 問題 1: `cargo` コマンドが見つからない

**症状:**
```
command not found: cargo
```

**解決方法:**
```bash
# 環境変数を再読み込み
source $HOME/.cargo/env

# それでも解決しない場合は、Rustを再インストール
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 問題 2: `maturin` のインストールエラー

**症状:**
```
error: failed to compile maturin
```

**解決方法:**
```bash
# pipを最新にアップデート
pip install --upgrade pip

# maturinを再インストール
pip install --upgrade maturin
```

### 問題 3: ビルドエラー（リンカーエラー）

**症状:**
```
error: linking with `cc` failed
```

**解決方法（macOS）:**
```bash
# Xcode Command Line Toolsをインストール
xcode-select --install
```

**解決方法（Ubuntu/Debian）:**
```bash
sudo apt-get update
sudo apt-get install build-essential
```

### 問題 4: Python拡張モジュールのインポートエラー

**症状:**
```python
ImportError: cannot import name 'mumei_rust'
```

**解決方法:**
```bash
# maturin developを再実行
cd mumei-rust
maturin develop --release

# Pythonのサイトパッケージを確認
python -c "import site; print(site.getsitepackages())"
```

### 問題 5: テストが失敗する

**症状:**
```
✗ 評価テスト失敗
```

**解決方法:**
```bash
# キャッシュをクリーンして再ビルド
cd mumei-rust
cargo clean
cargo build --release
maturin develop --release

# テストを再実行
cd ..
python test_rust_integration.py
```

## 🎯 次のステップ

### 1. Mumeiコードの実行

```bash
# Mumeiファイルを実行
python mumei.py your_script.mu
```

### 2. 統合インターフェースの使用

```python
# Python スクリプトから使用
from mumei_unified import evaluate

result = evaluate("""
let x = 10
let y = 20
x + y
""")
print(result)  # "30"
```

### 3. Pythonモジュールとの統合

```python
# Pythonモジュール（async, http, fileなど）と統合して使用
from mumei_bridge import execute

result = execute("""
// HTTPリクエスト
let response = http_get("https://api.example.com/data")
print(response)

// ファイル操作
file_write("output.txt", "Hello, World!")
let content = file_read("output.txt")
print(content)
""")
```

## 📚 追加リソース

- **Rust公式サイト**: https://www.rust-lang.org/
- **Maturinドキュメント**: https://www.maturin.rs/
- **PyO3ドキュメント**: https://pyo3.rs/
- **Mumei言語ドキュメント**: `mumei-rust/README.md`

## 💡 ヒント

### Rust実装の強制使用

```bash
# 環境変数でRust実装を強制
export MUMEI_USE_RUST=true
python your_script.py
```

### Python実装の強制使用

```bash
# Rust実装を無効化
export MUMEI_USE_RUST=false
python your_script.py
```

### 開発モードでのビルド

```bash
# デバッグ情報付きでビルド（開発時）
cd mumei-rust
maturin develop

# リリースモードでビルド（本番時）
maturin develop --release
```

### ビルドの高速化

```bash
# 並列ビルドのジョブ数を指定
cargo build --release -j 4
```

## ✅ セットアップ完了チェックリスト

- [ ] Rustがインストールされている（`rustc --version`で確認）
- [ ] Maturinがインストールされている（`maturin --version`で確認）
- [ ] Rust実装がビルドされている（`cargo build --release`が成功）
- [ ] Pythonからインポートできる（`import mumei_rust`が成功）
- [ ] 統合テストが通る（`python test_rust_integration.py`が成功）
- [ ] ベンチマークが実行できる（`python benchmark_rust.py`が成功）

すべてのチェックボックスにチェックが入れば、セットアップ完了です！🎉

## 🆘 サポート

問題が解決しない場合は、以下の情報を含めて報告してください：

- OS とバージョン
- Python バージョン（`python --version`）
- Rust バージョン（`rustc --version`）
- エラーメッセージの全文
- 実行したコマンド

---

**Happy Coding with Mumei! 🚀**
