# Mumei言語 - Rust移行計画

## 目的
PythonベースのMumei言語インタプリタをRustで再実装し、パフォーマンスを大幅に向上させる。

## 移行戦略

### なぜRustか？
1. **パフォーマンス**: C/C++並みの実行速度
2. **メモリ安全性**: ガベージコレクション不要で安全なメモリ管理
3. **並行性**: 安全な並行処理のサポート
4. **Python互換性**: PyO3によるシームレスなPythonバインディング
5. **エコシステム**: 豊富なライブラリとツール

### 段階的移行アプローチ

#### フェーズ1: 基盤構築（1-2週間）
**目標**: Rustプロジェクトのセットアップとレキサー実装

1. **環境セットアップ**
   ```bash
   # Rustのインストール（まだの場合）
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

   # PyO3のセットアップ
   pip install maturin
   ```

2. **プロジェクト構造**
   ```
   mumei-rust/
   ├── Cargo.toml              # Rustプロジェクト設定
   ├── pyproject.toml          # Pythonパッケージ設定
   ├── src/
   │   ├── lib.rs             # PyO3バインディング
   │   ├── lexer.rs           # レキサー（Rust実装）
   │   ├── parser.rs          # パーサー（Rust実装）
   │   ├── interpreter.rs     # インタプリタコア（Rust実装）
   │   ├── value.rs           # 値の型定義
   │   └── error.rs           # エラー型定義
   ├── python/
   │   └── mumei/
   │       ├── __init__.py    # Pythonラッパー
   │       ├── discord.py     # Discord機能（既存）
   │       ├── http.py        # HTTP機能（既存）
   │       └── file.py        # ファイルI/O（既存）
   └── tests/
       ├── test_lexer.rs      # Rustテスト
       └── test_integration.py # 統合テスト
   ```

3. **実装優先順位**
   - ✅ レキサー（トークン化） - 最も単純で効果大
   - ✅ パーサー（AST構築） - レキサーに依存
   - ✅ 値の型システム - インタプリタに必要
   - ✅ インタプリタコア - 評価エンジン
   - ⏳ PyO3バインディング - Pythonから呼び出し
   - ⏳ 既存モジュールとの統合

#### フェーズ2: コア機能の移行（2-3週間）
**目標**: 基本的なインタプリタ機能をRustで実装

1. **レキサー実装**
   - トークン型の定義
   - 字句解析ロジック
   - エラーハンドリング
   - パフォーマンス最適化

2. **パーサー実装**
   - AST型の定義
   - 再帰下降パーサー
   - 演算子優先順位
   - エラーリカバリー

3. **インタプリタコア実装**
   - 値の型システム（数値、文字列、真偽値、リスト、辞書等）
   - 環境（変数スコープ）管理
   - 評価エンジン
   - 組み込み関数

#### フェーズ3: PyO3統合（1-2週間）
**目標**: RustコアをPythonから呼び出せるようにする

1. **バインディング作成**
   ```rust
   use pyo3::prelude::*;

   #[pyfunction]
   fn tokenize(source: &str) -> PyResult<Vec<Token>> {
       // Rustのレキサーを呼び出し
   }

   #[pyfunction]
   fn parse(source: &str) -> PyResult<AST> {
       // Rustのパーサーを呼び出し
   }

   #[pyfunction]
   fn evaluate(source: &str) -> PyResult<Value> {
       // Rustのインタプリタを呼び出し
   }
   ```

2. **ハイブリッド実行**
   - Pythonエントリポイント（mm.py）はそのまま
   - レキサー・パーサー・インタプリタはRust実装を使用
   - Discord、HTTP等のモジュールはPythonのまま

#### フェーズ4: 最適化と拡張（進行中）
**目標**: パフォーマンス最適化と機能追加

1. **パフォーマンス最適化**
   - メモリアロケーション最適化
   - 並列処理の導入
   - JITコンパイル検討
   - ベンチマーク測定

2. **拡張機能**
   - より高度な型システム
   - ガベージコレクション改善
   - デバッガー機能
   - VSCode拡張との統合

## 期待される効果

### パフォーマンス向上
- **レキサー**: 5-10倍高速化
- **パーサー**: 3-5倍高速化
- **インタプリタ**: 2-3倍高速化
- **全体**: 3-5倍の高速化を期待

### メモリ使用量削減
- Rustの効率的なメモリ管理により30-50%削減

### 並行性の向上
- 安全な並行処理により、マルチコア活用が容易に

## 技術スタック

### Rust依存クレート
```toml
[dependencies]
pyo3 = { version = "0.20", features = ["extension-module"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
thiserror = "1.0"
anyhow = "1.0"
regex = "1.10"
```

### 開発ツール
- **maturin**: Rust-Pythonハイブリッドパッケージビルダー
- **cargo**: Rustパッケージマネージャー
- **rustfmt**: コードフォーマッター
- **clippy**: Linter

## 互換性維持

### 後方互換性
- 既存の.muファイルはすべて動作保証
- PythonAPIは変更なし
- Discord、HTTP等のモジュールは互換性維持

### 段階的な移行
1. Rustコアを内部的に使用
2. ユーザーは変更を意識しない
3. 徐々にPythonコードをRustに置き換え

## 次のステップ

### 1. Rustのインストール
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### 2. プロジェクト初期化
```bash
# Rustプロジェクト作成
cargo new --lib mumei-rust
cd mumei-rust

# PyO3セットアップ
pip install maturin
maturin init
```

### 3. レキサー実装開始
- トークン型定義
- 字句解析ロジック
- テストケース作成

## リスク管理

### 潜在的リスク
1. **開発時間**: Rust学習曲線による遅延
2. **互換性**: Python-Rust間のデータ変換コスト
3. **依存関係**: PyO3のバージョン管理

### 軽減策
1. **段階的移行**: 一度に全部変えない
2. **テスト**: 各フェーズで徹底的にテスト
3. **ドキュメント**: 実装の詳細を文書化

## まとめ

Rustへの移行により、Mumei言語は：
- ⚡ **高速**: 3-5倍のパフォーマンス向上
- 🛡️ **安全**: メモリ安全性とスレッド安全性
- 🚀 **スケーラブル**: 並行処理の活用
- 🔧 **メンテナブル**: 型安全性による保守性向上

段階的なアプローチにより、リスクを最小限に抑えながら移行を進めます。
