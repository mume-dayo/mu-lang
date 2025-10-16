#!/usr/bin/env python3
"""
Mumei言語統合インターフェース

Rust実装とPython実装を統合し、自動的にフォールバックする
"""

import os
import sys
from typing import Optional, List, Any

# Rust実装の利用可否
USE_RUST = os.environ.get("MUMEI_USE_RUST", "auto").lower()
_rust_available = False
_rust_module = None

# Rust実装のインポートを試みる
if USE_RUST in ("auto", "true", "1", "yes"):
    try:
        import mumei_rust
        _rust_available = True
        _rust_module = mumei_rust
        if USE_RUST == "auto":
            print("✓ Rust実装を使用します（5-10倍高速）", file=sys.stderr)
    except ImportError:
        if USE_RUST in ("true", "1", "yes"):
            print("⚠ Rust実装が見つかりません。Python実装を使用します", file=sys.stderr)
        _rust_available = False


class Token:
    """トークンクラス（統合インターフェース）"""

    def __init__(self, token_type: str, lexeme: str, line: int, column: int):
        self.token_type = token_type
        self.lexeme = lexeme
        self.line = line
        self.column = column

    def __repr__(self):
        return f"Token(type='{self.token_type}', lexeme='{self.lexeme}', line={self.line}, column={self.column})"


def tokenize(source: str) -> List[Token]:
    """
    ソースコードをトークン化

    Args:
        source: Mumeiソースコード

    Returns:
        トークンのリスト
    """
    if _rust_available:
        # Rust実装を使用
        rust_tokens = _rust_module.tokenize(source)
        return [
            Token(t.token_type, t.lexeme, t.line, t.column)
            for t in rust_tokens
        ]
    else:
        # Python実装を使用
        try:
            from mm_lexer import Lexer
            lexer = Lexer(source)
            python_tokens = lexer.tokenize()
            return [
                Token(t.type, t.value, t.line, t.column)
                for t in python_tokens
            ]
        except ImportError:
            raise ImportError("Rust実装もPython実装も利用できません")


def parse(source: str) -> str:
    """
    ソースコードをパースしてASTを取得（デバッグ用）

    Args:
        source: Mumeiソースコード

    Returns:
        AST文字列表現
    """
    if _rust_available:
        return _rust_module.parse(source)
    else:
        try:
            from mm_parser import Parser
            from mm_lexer import Lexer

            lexer = Lexer(source)
            tokens = lexer.tokenize()
            parser = Parser(tokens)
            ast = parser.parse()
            return str(ast)
        except ImportError:
            raise ImportError("Rust実装もPython実装も利用できません")


def parse_pretty(source: str) -> str:
    """
    ソースコードをパースして整形されたASTを取得

    Args:
        source: Mumeiソースコード

    Returns:
        整形されたAST文字列表現
    """
    if _rust_available:
        return _rust_module.parse_pretty(source)
    else:
        # Python実装では通常のparseと同じ
        return parse(source)


def evaluate(source: str) -> Any:
    """
    ソースコードを評価して結果を取得

    Args:
        source: Mumeiソースコード

    Returns:
        評価結果
    """
    if _rust_available:
        return _rust_module.evaluate(source)
    else:
        try:
            from mm_interpreter import Interpreter

            interpreter = Interpreter()
            result = interpreter.run(source)
            return result
        except ImportError:
            raise ImportError("Rust実装もPython実装も利用できません")


def run(source: str) -> Any:
    """
    ソースコードを実行（evaluateのエイリアス）

    Args:
        source: Mumeiソースコード

    Returns:
        実行結果
    """
    return evaluate(source)


def is_rust_available() -> bool:
    """Rust実装が利用可能かどうか"""
    return _rust_available


def get_implementation() -> str:
    """現在使用している実装を取得"""
    return "rust" if _rust_available else "python"


def get_version() -> str:
    """バージョン情報を取得"""
    if _rust_available:
        return f"Mumei (Rust) v{_rust_module.__version__}"
    else:
        return "Mumei (Python) v1.0.0"


def benchmark_compare(source: str, iterations: int = 100):
    """
    RustとPythonの両方でベンチマークを実行して比較

    Args:
        source: ベンチマーク対象のコード
        iterations: 実行回数

    Returns:
        (rust_time, python_time, speedup) のタプル
    """
    import time

    rust_time = None
    python_time = None

    # Rust実装のベンチマーク
    if _rust_available:
        start = time.perf_counter()
        for _ in range(iterations):
            _rust_module.evaluate(source)
        end = time.perf_counter()
        rust_time = (end - start) / iterations

    # Python実装のベンチマーク
    try:
        from mm_interpreter import Interpreter

        start = time.perf_counter()
        for _ in range(iterations):
            interpreter = Interpreter()
            interpreter.run(source)
        end = time.perf_counter()
        python_time = (end - start) / iterations
    except ImportError:
        pass

    # 高速化率
    speedup = None
    if rust_time and python_time:
        speedup = python_time / rust_time

    return rust_time, python_time, speedup


# モジュールレベルの情報
__version__ = "1.0.0"
__implementation__ = get_implementation()


if __name__ == "__main__":
    # テスト実行
    print("Mumei言語統合インターフェース")
    print(f"実装: {get_implementation()}")
    print(f"バージョン: {get_version()}")
    print()

    # 簡単なテスト
    test_code = """
let x = 10
let y = 20
x + y
"""

    print("テストコード:")
    print(test_code)
    print()

    try:
        result = evaluate(test_code)
        print(f"結果: {result}")
    except Exception as e:
        print(f"エラー: {e}")
