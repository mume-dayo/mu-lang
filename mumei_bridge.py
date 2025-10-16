#!/usr/bin/env python3
"""
Mumei言語ブリッジモジュール

Rust実装のインタプリタにPythonモジュール（mm_async、mm_http、mm_fileなど）を統合する
"""

import sys
from typing import Any, Dict, Callable

# Rust/Python統合インターフェース
from mumei_unified import evaluate, is_rust_available, get_implementation

# Mumeiモジュールのインポート
try:
    import mm_async
    HAS_ASYNC = True
except ImportError:
    HAS_ASYNC = False
    print("⚠ mm_asyncモジュールが見つかりません", file=sys.stderr)

try:
    import mm_http
    HAS_HTTP = True
except ImportError:
    HAS_HTTP = False
    print("⚠ mm_httpモジュールが見つかりません", file=sys.stderr)

try:
    import mm_file
    HAS_FILE = True
except ImportError:
    HAS_FILE = False
    print("⚠ mm_fileモジュールが見つかりません", file=sys.stderr)

try:
    import mm_discord
    HAS_DISCORD = True
except ImportError:
    HAS_DISCORD = False
    # Discordは必須ではないので警告なし


class MumeiBridge:
    """
    Rust実装とPythonモジュールを統合するブリッジクラス
    """

    def __init__(self):
        self.modules = {}
        self.native_functions = {}

        # モジュールの登録
        self._register_modules()
        self._register_native_functions()

    def _register_modules(self):
        """利用可能なモジュールを登録"""
        if HAS_ASYNC:
            self.modules['async'] = mm_async
        if HAS_HTTP:
            self.modules['http'] = mm_http
        if HAS_FILE:
            self.modules['file'] = mm_file
        if HAS_DISCORD:
            self.modules['discord'] = mm_discord

    def _register_native_functions(self):
        """ネイティブ関数を登録"""

        # 非同期関数
        if HAS_ASYNC:
            self.native_functions['async_task'] = mm_async.async_task
            self.native_functions['async_gather'] = mm_async.async_gather
            self.native_functions['sleep'] = mm_async.sleep

        # HTTP関数
        if HAS_HTTP:
            self.native_functions['http_get'] = mm_http.http_get
            self.native_functions['http_post'] = mm_http.http_post
            self.native_functions['http_request'] = mm_http.http_request

        # ファイル関数
        if HAS_FILE:
            self.native_functions['file_read'] = mm_file.file_read
            self.native_functions['file_write'] = mm_file.file_write
            self.native_functions['file_exists'] = mm_file.file_exists
            self.native_functions['file_delete'] = mm_file.file_delete
            self.native_functions['dir_list'] = mm_file.dir_list

    def get_module(self, name: str):
        """モジュールを取得"""
        return self.modules.get(name)

    def get_native_function(self, name: str) -> Callable:
        """ネイティブ関数を取得"""
        return self.native_functions.get(name)

    def has_module(self, name: str) -> bool:
        """モジュールが利用可能か"""
        return name in self.modules

    def list_modules(self) -> list:
        """利用可能なモジュール一覧"""
        return list(self.modules.keys())

    def list_native_functions(self) -> list:
        """利用可能なネイティブ関数一覧"""
        return list(self.native_functions.keys())

    def create_namespace(self) -> Dict[str, Any]:
        """
        Mumeiコード実行用の名前空間を作成

        Returns:
            ネイティブ関数を含む名前空間辞書
        """
        namespace = {}

        # ネイティブ関数を追加
        namespace.update(self.native_functions)

        # モジュールを追加
        namespace.update(self.modules)

        return namespace

    def execute_with_modules(self, source: str, namespace: Dict[str, Any] = None) -> Any:
        """
        Pythonモジュールを統合してMumeiコードを実行

        Args:
            source: Mumeiソースコード
            namespace: 追加の名前空間（オプション）

        Returns:
            実行結果
        """
        # 名前空間の作成
        exec_namespace = self.create_namespace()

        if namespace:
            exec_namespace.update(namespace)

        # TODO: Rust実装で名前空間を渡す方法を実装
        # 現時点では標準のevaluateを使用
        if is_rust_available():
            # Rust実装ではネイティブ関数の登録が必要
            # 暫定的にPython実装を使用
            print("⚠ Rust実装ではPythonモジュールの統合は未実装です。Python実装を使用します。", file=sys.stderr)

            from mm_interpreter import Interpreter
            interpreter = Interpreter()

            # 名前空間を設定
            for name, value in exec_namespace.items():
                interpreter.globals[name] = value

            return interpreter.run(source)
        else:
            # Python実装を使用
            from mm_interpreter import Interpreter
            interpreter = Interpreter()

            # 名前空間を設定
            for name, value in exec_namespace.items():
                interpreter.globals[name] = value

            return interpreter.run(source)


# グローバルブリッジインスタンス
_bridge = MumeiBridge()


def get_bridge() -> MumeiBridge:
    """ブリッジインスタンスを取得"""
    return _bridge


def execute(source: str, **kwargs) -> Any:
    """
    Pythonモジュールを統合してMumeiコードを実行

    Args:
        source: Mumeiソースコード
        **kwargs: 追加の名前空間変数

    Returns:
        実行結果
    """
    return _bridge.execute_with_modules(source, kwargs)


def list_available_features():
    """利用可能な機能一覧を表示"""
    print("=" * 60)
    print("Mumei言語 - 利用可能な機能")
    print("=" * 60)

    print(f"\n実装: {get_implementation()}")
    print(f"Rust実装: {'利用可能' if is_rust_available() else '利用不可'}")

    print("\nモジュール:")
    for module_name in _bridge.list_modules():
        print(f"  ✓ {module_name}")

    if not _bridge.list_modules():
        print("  (なし)")

    print("\nネイティブ関数:")
    functions = _bridge.list_native_functions()
    if functions:
        # カテゴリ別に表示
        categories = {
            "非同期": [f for f in functions if 'async' in f or 'sleep' in f],
            "HTTP": [f for f in functions if 'http' in f],
            "ファイル": [f for f in functions if 'file' in f or 'dir' in f],
        }

        for category, funcs in categories.items():
            if funcs:
                print(f"\n  {category}:")
                for func in funcs:
                    print(f"    - {func}")
    else:
        print("  (なし)")

    print("\n" + "=" * 60)


if __name__ == "__main__":
    # テスト実行
    print("Mumei言語ブリッジモジュール")
    print()

    list_available_features()

    print("\n" + "=" * 60)
    print("テスト実行")
    print("=" * 60)

    # ファイル操作のテスト
    if HAS_FILE:
        print("\nファイル操作テスト:")
        test_code = """
// テストファイルの作成
file_write("test_bridge.txt", "Hello from Mumei!")

// 読み込み
let content = file_read("test_bridge.txt")
print("ファイル内容: " + content)

// 存在確認
let exists = file_exists("test_bridge.txt")
print("ファイル存在: " + str(exists))

// 削除
file_delete("test_bridge.txt")
"""
        try:
            execute(test_code)
            print("✓ ファイル操作成功")
        except Exception as e:
            print(f"✗ エラー: {e}")

    # HTTP操作のテスト（実際のリクエストは行わない）
    if HAS_HTTP:
        print("\nHTTP関数テスト（dry-run）:")
        print("  ✓ http_get, http_post, http_request が利用可能")
