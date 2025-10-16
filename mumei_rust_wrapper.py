#!/usr/bin/env python3
"""
Mumei-Rust 統合ラッパー
PythonとRustの実装を透過的に切り替え
"""

import os
import sys

# 環境変数で実装を選択
USE_RUST = os.getenv('MUMEI_USE_RUST', 'true').lower() == 'true'

# Rust実装が利用可能かチェック
RUST_AVAILABLE = False
try:
    import mumei_rust
    RUST_AVAILABLE = True
except ImportError:
    pass

# Python実装をインポート
try:
    from mm_lexer import Lexer as PythonLexer
    from mm_parser import Parser as PythonParser
    PYTHON_AVAILABLE = True
except ImportError:
    PYTHON_AVAILABLE = False


class MumeiLexer:
    """統合レキサー"""

    def __init__(self, source: str):
        self.source = source
        self.use_rust = USE_RUST and RUST_AVAILABLE

    def tokenize(self):
        """トークン化"""
        if self.use_rust:
            # Rust実装
            try:
                return mumei_rust.tokenize(self.source)
            except Exception as e:
                print(f"Warning: Rust lexer failed, falling back to Python: {e}")
                self.use_rust = False

        # Python実装にフォールバック
        if PYTHON_AVAILABLE:
            lexer = PythonLexer(self.source)
            return lexer.tokenize()
        else:
            raise ImportError("No lexer implementation available")


class MumeiParser:
    """統合パーサー"""

    def __init__(self, source: str = None, tokens=None):
        self.source = source
        self.tokens = tokens
        self.use_rust = USE_RUST and RUST_AVAILABLE and source is not None

    def parse(self):
        """パース"""
        if self.use_rust and self.source:
            # Rust実装（ソースから直接パース）
            try:
                ast_str = mumei_rust.parse(self.source)
                # 注: 現在はAST文字列を返すだけ
                # 将来的にはPython互換のASTオブジェクトを返す
                return ast_str
            except Exception as e:
                print(f"Warning: Rust parser failed, falling back to Python: {e}")
                self.use_rust = False

        # Python実装にフォールバック
        if PYTHON_AVAILABLE:
            if self.tokens:
                parser = PythonParser(self.tokens)
            else:
                # ソースからトークン化
                lexer = PythonLexer(self.source)
                tokens = lexer.tokenize()
                parser = PythonParser(tokens)
            return parser.parse()
        else:
            raise ImportError("No parser implementation available")


def get_implementation_info():
    """現在使用中の実装情報を取得"""
    info = {
        'rust_available': RUST_AVAILABLE,
        'python_available': PYTHON_AVAILABLE,
        'using_rust': USE_RUST and RUST_AVAILABLE,
        'version': None,
    }

    if RUST_AVAILABLE:
        try:
            info['rust_version'] = mumei_rust.__version__
        except:
            pass

    return info


def print_implementation_info():
    """実装情報を出力"""
    info = get_implementation_info()

    print("=" * 60)
    print("Mumei Language Implementation")
    print("=" * 60)

    print(f"\nRust実装:")
    if info['rust_available']:
        print(f"  ✅ 利用可能")
        if 'rust_version' in info:
            print(f"  バージョン: {info['rust_version']}")
    else:
        print(f"  ❌ 利用不可（ビルドが必要: cd mumei-rust && ./build.sh）")

    print(f"\nPython実装:")
    if info['python_available']:
        print(f"  ✅ 利用可能")
    else:
        print(f"  ❌ 利用不可")

    print(f"\n現在使用中:")
    if info['using_rust']:
        print(f"  🦀 Rust実装（高速）")
    elif info['python_available']:
        print(f"  🐍 Python実装")
    else:
        print(f"  ❌ 実装なし")

    print("\n" + "=" * 60)


# ベンチマーク関数
def benchmark_lexer(source: str, iterations: int = 100):
    """レキサーのベンチマーク"""
    import time

    results = {}

    # Rust実装
    if RUST_AVAILABLE:
        start = time.time()
        for _ in range(iterations):
            mumei_rust.tokenize(source)
        elapsed = time.time() - start
        results['rust'] = elapsed / iterations

    # Python実装
    if PYTHON_AVAILABLE:
        start = time.time()
        for _ in range(iterations):
            lexer = PythonLexer(source)
            lexer.tokenize()
        elapsed = time.time() - start
        results['python'] = elapsed / iterations

    return results


def print_benchmark(source: str, iterations: int = 100):
    """ベンチマーク結果を出力"""
    print(f"\nベンチマーク（{iterations}回平均）")
    print(f"ソースサイズ: {len(source)} 文字")
    print("-" * 60)

    results = benchmark_lexer(source, iterations)

    for impl, time_ms in results.items():
        print(f"{impl:10s}: {time_ms * 1000:.2f}ms")

    if 'rust' in results and 'python' in results:
        speedup = results['python'] / results['rust']
        print(f"\n高速化: {speedup:.1f}x")


if __name__ == "__main__":
    print_implementation_info()

    # 簡単なテスト
    if len(sys.argv) > 1:
        source = sys.argv[1]
    else:
        source = "let x = 42"

    print(f"\nテスト: {source}")

    if RUST_AVAILABLE or PYTHON_AVAILABLE:
        lexer = MumeiLexer(source)
        tokens = lexer.tokenize()
        print(f"トークン数: {len(tokens)}")

        # ベンチマーク
        if len(source) > 10:
            test_source = source * 100
            print_benchmark(test_source, 10)
